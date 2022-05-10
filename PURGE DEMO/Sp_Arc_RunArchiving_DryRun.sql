USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
/*

begin tran
exec dbo.Sp_Arc_RunArchiving_DryRun

rollback tran


*/

DROP PROCEDURE IF EXISTS dbo.Sp_Arc_RunArchiving_DryRun
GO
CREATE PROCEDURE dbo.Sp_Arc_RunArchiving_DryRun
AS
BEGIN

declare @tablename varchar(500)  
declare @schemaname varchar(100)
declare @batch_size varchar(10)
declare @archival_config_id int 
declare @job_end_time time 
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
declare @history_data_retention_days int 
declare @history_data_retention_cut_off_date_string varchar(100)
declare @purgeOperation_Enabled_Disabled char(5)
declare @lookupName varchar(250)
declare @start_archival_config_id int = 0
declare @error_msg varchar(max)
declare @purge_status tinyint

SET NOCOUNT ON 

-- Get the configured value for Purge Opertion and Check if Purge is enabled(True) or not (False)
SET @purgeOperation_Enabled_Disabled = (SELECT [Value] FROM dbo.Lookups WHERE [Name] = 'Enable_Purge_Operation')

IF @purgeOperation_Enabled_Disabled <> 'True'
BEGIN
	PRINT 'Purge Operation has been set to OFF'
	RETURN ;
END 


IF EXISTS (SELECT 1 FROM dbo.Archival_Config WHERE purge_status = 0)
BEGIN
	SET @start_archival_config_id =  (SELECT MIN(archival_config_id)FROM dbo.Archival_Config WHERE purge_status = 0)
END 
-- Get Setting Values -- STARTS--

-- Get the configured batch size for the Purge Operation
SET @batch_size = (SELECT setting_value FROM dbo.Archival_Settings_Config WHERE setting_name = 'purge_batch_size')
SET @job_end_time = (SELECT setting_value FROM dbo.Archival_Settings_Config WHERE setting_name = 'Purge_Job_End_Time')
-- Get Setting Values -- ENDS--

declare tableCursor cursor FAST_FORWARD FOR

SELECT  
	archival_config_id , table_schema,table_name,filters,lookupName 
FROM 
	dbo.Archival_Config
WHERE 
	archival_config_id >= @start_archival_config_id
order by 
	archival_config_id asc;

OPEN tableCursor
FETCH NEXT FROM 
			tableCursor 
	INTO  
				@archival_config_id,@schemaname,@tablename,@filters,@lookupName 

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

					 Select @column_list =  SUBSTRING( 
									( 
										 SELECT ',' + Column_Name AS 'data()'
											 FROM INFORMATION_SCHEMA.COLUMNS where  TABLE_SCHEMA = @schemaname  AND TABLE_NAME = @tablename FOR XML PATH('') 
									), 2 , 9999) 

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
									
						
						
						-- If the PK is an INTEGER Column
				IF @PK_column_dataType = 'int' -- IF PK  is of Integer Data Type
				BEGIN
						---- Create a staging table to Hold candidate ids
						CREATE TABLE tempdb..Staging_IDs(ID int PRIMARY KEY)
				END
				ELSE  -- if the PK is a UNIQUEIDENTIFIER
					BEGIN
						CREATE TABLE tempdb..Staging_IDs (ID uniqueidentifier PRIMARY KEY);
				END


				--section get all the lookup / configuration values  -- STARTS 

				SET @history_data_retention_days = (SELECT [Value] FROM dbo.Lookups WHERE [Name] = @lookupName)
				SET @history_data_retention_cut_off_date_string = CAST(DATEADD(DAY,-@history_data_retention_days,getdate()) AS VARCHAR)
				
				--section get all the lookup / configuration values  -- ENDS
				
				SET @insert_sql = 'insert into tempdb..Staging_IDs'+
								' select top ('+cast(@batch_size as varchar)+') '+@pk_columnname + ' from '+ @schemaname+ '.' + @tablename 
									
				
				SET @predicate_sql = case when @filters is null then ' where 1=1'
									else ' ' +replace(@filters,'{Date_Parameter}',''''+@history_data_retention_cut_off_date_string+'''') end 
				SET @insert_sql = @insert_sql + @predicate_sql
				
				SET @total_number_of_records_affected = 0 
				---- Process the records  (Archiving of the records starts here)
				SET @purge_status = 0
				UPDATE dbo.Archival_Config set purge_status = @purge_status where archival_config_id = @archival_config_id
					WHILE (1=1)
						BEGIN
							-- If current time is greater than the configured time , then exit the job
							IF CONVERT(VARCHAR(5),GETDATE(),108) >= @job_end_time 
							BEGIN
								BREAK;
							END 

							TRUNCATE TABLE tempdb..Staging_IDs
							--PRINT @insert_sql
							EXEC (@insert_sql);
	
						BEGIN TRY
							BEGIN TRAN
								--EXEC dbo.sp_Arc_Delete_from_source @schemaname,@tablename,@filters,@pk_columnname
								
								WAITFOR DELAY '00:00:05:000' -- Simulating a delete operation
								SET @purge_status = 1 
								--- Execution logging STARTS--	
								SET @numOfRowsAffected = (select count(1) as cnt from tempdb..Staging_IDs)-- Get the number of rows affected
								SET @total_number_of_records_affected = @total_number_of_records_affected + @numOfRowsAffected
								IF @numOfRowsAffected > 0 -- Log only if the number of records affected is greater than 0
								BEGIN
									INSERT INTO dbo.Archival_Execution_Log(description_text,date_created)
									SELECT 'Number of records affected for the table - ' + @schemaname + '.'+@tablename + ' = ' + cast(@numOfRowsAffected as varchar(10)) + ' Filter Condition - ' + @predicate_sql , getdate()
								END 
								--- Execution logging ENDS--
								COMMIT TRAN
								BREAK;-- Count = 0 Break statement	
						END TRY 
						BEGIN CATCH 
								ROLLBACK TRAN
								PRINT 'In Catch Block'
								SET @error_msg = 'Error Procedure - ' + ERROR_PROCEDURE() + ' '+ 'Error Line - ' + cast(ERROR_LINE() as varchar) + ' ' + 'Error Message - ' + ERROR_MESSAGE()
								INSERT INTO dbo.Archival_Error_Log(archival_config_id,error_description,error_date)
								SELECT @archival_config_id, @error_msg , GETDATE()
						END CATCH 
							PRINT 'Number of rows affected - ' + cast(@numOfRowsAffected as varchar(10))

						END -- While Loop End
					UPDATE dbo.Archival_Config set purge_status = @purge_status where archival_config_id = @archival_config_id

	FETCH NEXT FROM 
			tableCursor 
	INTO 					
		@archival_config_id,@schemaname,@tablename,@filters,@lookupName 

		PRINT 'Total number of rows affected - ' + cast(@total_number_of_records_affected as varchar(10))
		IF @total_number_of_records_affected > 0 -- Log only if the total number of records affected is greater than 0
		BEGIN
			INSERT INTO dbo.Archival_Execution_Log(description_text,date_created)
			SELECT 'Total - ' + @schemaname + '.'+@tablename + ' = [' + cast(@total_number_of_records_affected as varchar(10)) + ']  Filter Condition - ' + @predicate_sql , getdate()
		END 



END-- Cursor Loop End
CLOSE tableCursor
DEALLOCATE tableCursor				
							
END 





dbcc opentran