USE [HFAMTagStore1]
GO

/*

begin tran 

	exec dbo.usp_startpurge

rollback tran

*/

ALTER PROCEDURE dbo.usp_StartPurge
AS
BEGIN

declare @tablename varchar(500)  
declare @schemaname varchar(100)
declare @batch_size varchar(10)
declare @purge_config_id int 
declare @job_duration_time varchar(10)
declare @tablename_suffix varchar(100)= ''
declare @filters varchar(1000)
declare @predicate_sql varchar(1000)
declare @sql varchar(5000)
declare @sqlstmt nvarchar(4000)
declare @column_list varchar(8000)=''
declare @insert_sql varchar(8000)=''
declare @delete_sql varchar(8000)=''
declare @pk_columnname varchar(100)=''
declare @PK_column_dataType varchar(100)
declare @numOfRowsAffected int = 0
declare @total_number_of_records_affected int = 0
declare @history_data_retention_days_override int = null
declare @history_data_retention_days int 
declare @history_data_retention_cut_off_date_string varchar(100)
declare @purgeOperation_Enabled_Disabled char(5)
declare @lookupName varchar(250)
declare @start_purge_config_id int = 0
declare @error_msg varchar(max)
declare @purge_status tinyint
declare @purge_job_start_time datetime = GETDATE() -- Purge Job start time 
declare @purge_job_end_time datetime 

SET NOCOUNT ON 

-- Get the configured value for Purge Opertion and Check if Purge is enabled(True) or not (False)
SET @purgeOperation_Enabled_Disabled = (SELECT [setting_value] FROM dbo.Purge_Settings_Config WHERE [setting_name] = 'Enable_Purge_Operation')

IF @purgeOperation_Enabled_Disabled <> 'ON'
BEGIN
	PRINT 'Purge Operation has been set to OFF'
	RETURN ;
END 


IF EXISTS (SELECT 1 FROM dbo.Purge_Config WHERE purge_status = 0)
BEGIN
	SET @start_purge_config_id =  (SELECT ISNULL(MIN(purge_config_id),0) FROM dbo.Purge_Config WHERE purge_status = 0)
END 
-- Get Setting Values -- STARTS--

-- Get the configured batch size for the Purge Operation
SET @batch_size = (SELECT setting_value FROM dbo.Purge_Settings_Config WHERE setting_name = 'Purge_Batch_Size')
SET @job_duration_time = (SELECT setting_value FROM dbo.Purge_Settings_Config WHERE setting_name = 'Purge_Duration')
-- Get Setting Values -- ENDS--

SET @purge_job_end_time = dbo.udf_GetHoursAndMinutes(@purge_job_start_time,@job_duration_time)

declare tableCursor cursor FAST_FORWARD FOR

SELECT  
	purge_config_id , table_schema,table_name,filters,history_retention_days_override,lookupName 
FROM 
	dbo.Purge_Config
WHERE 
	purge_config_id >= @start_purge_config_id
--WHERE purge_config_id = 1
--and purge_config_id not in (8)
--and purge_config_id = 3
order by 
	purge_config_id asc;

OPEN tableCursor
FETCH NEXT FROM 
			tableCursor 
	INTO  
				@purge_config_id,@schemaname,@tablename,@filters,@history_data_retention_days_override,@lookupName 

WHILE @@FETCH_STATUS = 0
          BEGIN


set @pk_columnname = (select distinct C.COLUMN_NAME FROM  
												INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
												JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C  
												ON C.CONSTRAINT_NAME=T.CONSTRAINT_NAME  
												WHERE  
												C.TABLE_NAME=@tablename  
												and T.CONSTRAINT_TYPE='PRIMARY KEY' 
												and C.TABLE_SCHEMA = @schemaname
					)
					
				IF OBJECT_ID(N'tempdb..Staging_IDs', N'U') IS NOT NULL  
					DROP TABLE tempdb..Staging_IDs;
					   				 

				SELECT  @PK_column_dataType =   
							ic.DATA_TYPE
						FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC 
						INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU
						INNER JOIN INFORMATION_SCHEMA.COLUMNS ic on ku.COLUMN_NAME = ic.COLUMN_NAME
							ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' 
							AND TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME 
							AND KU.table_name=@tablename
							and ic.TABLE_NAME = @tablename
						ORDER BY 
								KU.TABLE_NAME
							,KU.ORDINAL_POSITION
									
				
				IF @pk_columnname is not null 		
				BEGIN
					-- If the PK is an INTEGER Column
					IF @PK_column_dataType = 'int'  OR  @PK_column_dataType = 'bigint' -- IF PK  is of Integer Data Type(int or bigint)
					BEGIN
							---- Create a staging table to Hold candidate ids
							IF @PK_column_dataType = 'int'
							BEGIN
								EXEC ('CREATE TABLE tempdb..Staging_IDs(ID INT PRIMARY KEY)')
							END
							ELSE
							BEGIN
								EXEC ('CREATE TABLE tempdb..Staging_IDs(ID BIGINT PRIMARY KEY)')
							END 
						
					END
					ELSE  -- if the PK is a UNIQUEIDENTIFIER
						BEGIN
							CREATE TABLE tempdb..Staging_IDs (ID uniqueidentifier PRIMARY KEY);
						END
				END


				--section get all the lookup / configuration values  -- STARTS 
				SET @history_data_retention_days_override = CASE WHEN @history_data_retention_days_override <= 0 then null else @history_data_retention_days_override end
				SET @history_data_retention_days = (SELECT ISNULL(@history_data_retention_days_override,[setting_value]) FROM dbo.Purge_Settings_Config WHERE [setting_name] = 'History_Retention_Days')
				SET @history_data_retention_cut_off_date_string = CAST(DATEADD(DAY,-@history_data_retention_days,getdate()) AS VARCHAR)
				--select @history_data_retention_days as history_data_retention_days , @history_data_retention_cut_off_date_string as stringVal
				--section get all the lookup / configuration values  -- ENDS
				
				SET @insert_sql = 'insert into tempdb..Staging_IDs'+
								' select top ('+cast(@batch_size as varchar)+') '+@pk_columnname + ' from '+ @schemaname+ '.' + @tablename 
									
				
				SET @predicate_sql = case when @filters is null then ' where 1=1'
									else ' ' +replace(@filters,'{Date_Parameter}',''''+@history_data_retention_cut_off_date_string+'''') end 
				SET @insert_sql = @insert_sql + @predicate_sql
								
				SET @total_number_of_records_affected = 0 
				
				------debug statements-- STARTS-----
				print @insert_sql
				------debug statements-- END--- 
		
				------debug statements-- STARTS-----
				IF @pk_columnname is null 
				BEGIN
					PRINT 'No PK found for the table - ' + @tablename
						EXEC dbo.usp_delete_from_source_without_pk @purge_config_id,@batch_size ,@schemaname,@tablename,@filters,@predicate_sql
				END 
				------debug statements-- END--- 		

			IF @pk_columnname is not null 
			BEGIN
				SET @purge_status = 0 
				PRINT 'Purge Config -' + cast(@purge_config_id as varchar(1))
				-- Mark the status to be in-Progress
				UPDATE dbo.Purge_Config set purge_status = @purge_status where purge_config_id = @purge_config_id
				---- Process the records  (Purging of the records starts here)
				WHILE (1=1)
						BEGIN
							-- If current time is greater than the job end time 
							IF GETDATE()  >= @purge_job_end_time
							BEGIN
								BREAK;
							END 

							TRUNCATE TABLE tempdb..Staging_IDs
							PRINT @insert_sql -- Debug statement
							EXEC (@insert_sql);

							IF (SELECT COUNT(1) AS cnt FROM tempdb..Staging_IDs) = 0
							BEGIN 
								SET @purge_status = 1 
								BREAK ;
							END 
								
						BEGIN TRY
							BEGIN TRAN T1
								EXEC dbo.usp_delete_from_source @schemaname,@tablename,@filters,@pk_columnname
								
								--- Execution logging STARTS--	
								SET @numOfRowsAffected = (select count(1) as cnt from tempdb..Staging_IDs)-- Get the number of rows affected
								SET @total_number_of_records_affected = @total_number_of_records_affected + @numOfRowsAffected
								IF @numOfRowsAffected > 0 -- Log only if the number of records affected is greater than 0
								BEGIN
									INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
									SELECT 'Number of records affected for the table - ' + @schemaname + '.'+@tablename + ' = ' + cast(@numOfRowsAffected as varchar(10)) + ' Filter Condition - ' + @predicate_sql ,@purge_config_id, getdate()
								END 
								--- Execution logging ENDS--
								COMMIT TRAN T1

						END TRY 
						BEGIN CATCH 
							ROLLBACK TRAN T1
							SET @purge_status = 0 -- Mark status as not complete 
							SET @error_msg = 'Error Procedure - ' + ERROR_PROCEDURE() + ' '+ 'Error Line - ' + cast(ERROR_LINE() as varchar) + ' ' + 'Error Message - ' + ERROR_MESSAGE()
							INSERT INTO dbo.Purge_Error_Log(purge_config_id,error_description,error_date)
								SELECT @purge_config_id, @error_msg ,GETDATE()

							END CATCH 
							PRINT 'Number of rows affected - ' + cast(@numOfRowsAffected as varchar(10))

						END -- While Loop End
				--Mark the final Purge Status
					PRINT 'Purge Status - ' + cast (@purge_status as varchar(1))
					UPDATE dbo.Purge_Config set purge_status = @purge_status where purge_config_id = @purge_config_id

				END -- If @pk_columnName is not null

	FETCH NEXT FROM 
			tableCursor 
	INTO 					
		@purge_config_id,@schemaname,@tablename,@filters,@history_data_retention_days_override,@lookupName  

		PRINT 'Total number of rows affected - ' + cast(@total_number_of_records_affected as varchar(10))
		IF @total_number_of_records_affected > 0 -- Log only if the total number of records affected is greater than 0
		BEGIN
			INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
			SELECT '[Total] - ' + @schemaname + '.'+@tablename + ' = [' + cast(@total_number_of_records_affected as varchar(10)) + ']  Filter Condition - ' + @predicate_sql , @purge_config_id,getdate()
		END 

END-- Cursor Loop End
CLOSE tableCursor
DEALLOCATE tableCursor				
							
END 
GO



ALTER PROCEDURE dbo.usp_delete_from_source_without_pk(@purge_config_id int,@batch_size INT ,@schemaname VARCHAR(100),@tablename VARCHAR(500),@filters VARCHAR(5000)
,@predicate_sql varchar(1000))
AS
 BEGIN
	
	DECLARE @dynamic_sql VARCHAR(8000),@Deleterowcount INT = 1 ,@total_number_of_records_affected int = 0,@error_msg varchar(8000)
	,@purge_status tinyint = 1

	-- Mark the status to be in-Progress (0)
	UPDATE dbo.Purge_Config set purge_status = 0 where purge_config_id = @purge_config_id

	WHILE (@Deleterowcount > 0) 
	BEGIN
		
		SET @dynamic_sql =  'delete top ('+cast(@batch_size AS VARCHAR) +')' +' ' + @schemaname+'.'+@tablename + '  from ' + @schemaname+'.'+@tablename + ' ' + @predicate_sql 	
		
		PRINT @dynamic_sql 
		
		BEGIN TRY 
			BEGIN TRAN T2
				EXEC (@dynamic_sql)
				SET @Deleterowcount = @@ROWCOUNT
			COMMIT TRAN T2
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN T2
				SET @purge_status = 0;
				PRINT 'Error occured for Purge config id -' + cast(@purge_config_id as varchar(10))
				SET @error_msg = 'Error Procedure - ' + ISNULL(ERROR_PROCEDURE(),'usp_delete_from_source_without_pk') + ' '+ 'Error Line - ' + cast(ERROR_LINE() as varchar) + ' ' + 'Error Message - ' + ERROR_MESSAGE()
				INSERT INTO dbo.Purge_Error_Log(purge_config_id,error_description,error_date)
				SELECT @purge_config_id, @error_msg ,GETDATE()
				BREAK;
		END CATCH

		PRINT '@Deleterowcount -' +cast(@Deleterowcount as varchar(10))
		SET @total_number_of_records_affected += @Deleterowcount; 
		INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
		SELECT 'Number of records affected for the table - ' + @schemaname + '.'+@tablename + ' = ' + cast(@Deleterowcount as varchar(10)) + ' Filter Condition - ' + @predicate_sql ,@purge_config_id, getdate()
	END -- End of While Loop
	
	PRINT 'Total number of rows affected - ' + cast(@total_number_of_records_affected as varchar(10))
	-- Log only if the total number of records affected is greater than 0
		IF @total_number_of_records_affected > 0 
		BEGIN
			INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
			SELECT '[Total] - ' + @schemaname + '.'+@tablename + ' = [' + cast(@total_number_of_records_affected as varchar(10)) + ']  Filter Condition - ' + @predicate_sql , @purge_config_id,getdate()
		END 
	-- Mark the status to be Completed (1)
	UPDATE dbo.Purge_Config set purge_status = @purge_status where purge_config_id = @purge_config_id
	
END 

