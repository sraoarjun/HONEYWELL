USE [HFAMTagStore1]
GO

-- Create Function
IF OBJECT_ID('dbo.udf_GetHoursAndMinutes ') IS NOT NULL
  DROP FUNCTION dbo.udf_GetHoursAndMinutes
GO

CREATE FUNCTION dbo.udf_GetHoursAndMinutes(
    @purge_job_start_time datetime,@purge_duration varchar(50)
)
RETURNS Datetime
AS
begin
declare @num_hours int  
declare @num_minutes int
declare @dt datetime 

SET @num_hours =  REVERSE(PARSENAME(REPLACE(REVERSE(@purge_duration), ':', '.'), 1)) 
SET @num_minutes = REVERSE(PARSENAME(REPLACE(REVERSE(@purge_duration), ':', '.'), 2)) 

SET @dt = dateadd(MINUTE,@num_minutes, dateadd(HOUR, @num_hours, @purge_job_start_time)) 
RETURN @dt
END

GO

-- Table Creation 

-- Purge Error Log
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Purge_Error_Log]') AND type in (N'U'))

BEGIN
	DROP TABLE [dbo].[Purge_Error_Log]
END 
GO
CREATE TABLE [dbo].[Purge_Error_Log](
	[purge_error_log_id] [int] IDENTITY(1,1) NOT NULL,
	[purge_config_id] [int] NULL,
	[error_description] [varchar](max) NULL,
	[error_date] [datetime] NULL,
CONSTRAINT PK_Purge_Error_Log PRIMARY KEY (purge_error_log_id)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



-- Purge Execution Log 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Purge_Execution_Log]') AND type in (N'U'))
BEGIN
	DROP TABLE [dbo].[Purge_Execution_Log]
END 
GO
CREATE TABLE [dbo].[Purge_Execution_Log]
(
	id int identity(1,1) constraint pk_purge_execution_log primary key ,
	description_text varchar(4000),
	purge_config_id int,
	date_created datetime
)
GO

-- Purge_Config
IF	EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Purge_Config]') AND type in (N'U'))
BEGIN
	DROP TABLE [dbo].[Purge_Config] 
END 
GO
CREATE TABLE [dbo].[Purge_Config] 
(
	purge_config_id int identity(1,1) constraint pk_purge_config primary key,
	description_text varchar(8000),
	table_schema varchar(100),
	table_name varchar(100),
	filters varchar(4000),
	history_retention_days_override int,
	purge_status tinyint,
	is_enabled bit ,
	db_datetime_last_updated datetime,
)
GO

-- Purge_Settings_Config
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Purge_Settings_Config]') AND type in (N'U'))
BEGIN
	DROP TABLE [dbo].[Purge_Settings_Config]
END 
GO
CREATE TABLE [dbo].[Purge_Settings_Config]
(
	id int identity(1,1) constraint pk_purge_settings_config primary key,
	setting_name varchar(100),
	setting_value varchar(100),
	description_text varchar(4000),
	date_created datetime
)
GO


-- Add foreign key to Purge_Execution_Log  (purge_config_id)
ALTER TABLE dbo.Purge_Execution_Log
ADD CONSTRAINT FK_Purge_Execution_Log_Purge_Config FOREIGN KEY (purge_config_id)
REFERENCES dbo.Purge_Config (purge_config_id)
GO

-- Add foreign key to Purge_Error_Log  (purge_config_id)
ALTER TABLE dbo.Purge_Error_Log
ADD CONSTRAINT FK_Purge_Error_Log_Purge_Config FOREIGN KEY (purge_config_id)
REFERENCES dbo.Purge_Config (purge_config_id)
GO


--usp_SearchFk

IF  EXISTS (SELECT * FROM sys.Procedures WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchFk]') AND type in (N'P'))
BEGIN
	DROP PROCEDURE dbo.usp_SearchFk 
END 
GO
/*
The procedure returns the list of the tables ,their corresponding levels and the parent table for each of the table regardless of the nesting levels

Parameters : @table - The name of the parent table
           			
returns : None 
*/
CREATE PROCEDURE dbo.usp_SearchFk 
  @table varchar(256) -- use two part name convention
, @lvl int=0 -- do not change
, @ParentTable varchar(256)='' -- do not change
, @debug bit = 1
as
begin
	set nocount on;
	declare @dbg bit;
	set @dbg=@debug;
	if object_id('tempdb..#tbl', 'U') is null
		create table  #tbl  (id int identity(1,1), tablename varchar(256), lvl int, ParentTable varchar(256));
	declare @curS cursor;
	if @lvl = 0
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl, Null;
	else
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl,@ParentTable;
	if @dbg=1	
		print replicate('----', @lvl) + 'lvl ' + cast(@lvl as varchar(10)) + ' = ' + @table;
	
	--if not exists (select * from sys.foreign_keys where referenced_object_id = object_id(@table))
	--	return;
		
	--else
	--begin -- else
		set @ParentTable = @table;
		set @curS = cursor for
		select tablename=object_schema_name(parent_object_id)+'.'+object_name(parent_object_id)
		from sys.foreign_keys 
		where referenced_object_id = object_id(@table)
		and parent_object_id <> referenced_object_id; -- add this to prevent self-referencing which can create a indefinitive loop;

		open @curS;
		fetch next from @curS into @table;

		while @@fetch_status = 0
		begin --while
			set @lvl = @lvl+1;
			-- recursive call
			exec dbo.usp_SearchFk @table, @lvl, @ParentTable, @dbg;
			set @lvl = @lvl-1;
			fetch next from @curS into @table;
		end --while
		close @curS;
		deallocate @curS;
	--end -- else
	
	if not exists (select 1 from #tbl)
		begin
			insert into #tbl (tablename, lvl, ParentTable)
			values(@table, @lvl, Null)
		end
	if @lvl = 0
		--select distinct * from #tbl;
			select distinct  id , tablename, lvl, ParentTable from #tbl;
		
	return;
end
GO

--usp_Delete_From_Source
IF  EXISTS (SELECT * FROM sys.Procedures WHERE object_id = OBJECT_ID(N'[dbo].[usp_Delete_From_Source]') AND type in (N'P'))
BEGIN
	DROP PROCEDURE dbo.usp_Delete_From_Source
END 
GO

/*
Exec dbo.usp_Delete_From_Source @schemaName = 'dbo',@tableName ='Equipments',@filters = 'where Year(CreatedDate) = 2020',@pk_column_name= 'EQUIPMENT_PK_ID'
*/

CREATE PROCEDURE dbo.usp_Delete_From_Source
(
	@schemaName varchar(100),
	@tableName varchar (100),
	@filters varchar (4000),
	@pk_column_name varchar(250)
)
AS
BEGIN
SET NOCOUNT ON;
if object_id('tempdb..#tmp') is not null
	drop table #tmp;
create table  #tmp  (id int, tablename varchar(256), lvl int, ParentTable varchar(256));

declare @tbl varchar(250) = @schemaName + '.' + @tableName


insert into #tmp 
exec dbo.usp_SearchFK @table=@tbl, @debug=0;
--exec dbo.usp_SearchFK @table='dbo.Equipments', @debug=0;

declare @where varchar(max) =null

set @where = @filters

declare @curFK cursor, @fk_object_id int;
declare @sqlcmd varchar(max)='', @crlf char(2)=char(0x0d)+char(0x0a);
declare @child varchar(256), @parent varchar(256), @lvl int, @id int;
declare @i int;
declare @t table (tablename varchar(128));
declare @curT cursor;
if isnull(@where, '')= ''
begin
	set @curT = cursor for select tablename, lvl from #tmp order by lvl desc
	open @curT;
	fetch next from @curT into @child, @lvl;
	while @@fetch_status = 0
	begin -- loop @curT
		if not exists (select 1 from @t where tablename=@child)
			insert into @t (tablename) values (@child);
		fetch next from @curT into @child, @lvl;
	end -- loop @curT
	close @curT;
	deallocate @curT;

	--select  @sqlcmd = @sqlcmd + 'delete from ' + tablename + @crlf from @t ;
	select  @sqlcmd = @sqlcmd + 'delete from ' + tablename + ' where ' + @tableName +'.'+ @pk_column_name +
	' in (' + 'select ID from tempdb..Staging_IDs)' + @crlf from @t 
	--print @sqlcmd;
	exec (@sqlcmd);
end
else
begin 
	declare curT cursor for
	select  lvl, id
	from #tmp
	order by lvl desc;

	open curT;
	fetch next from curT into  @lvl, @id;
	while @@FETCH_STATUS =0
	begin
		set @i=0;
		if @lvl =0
		begin -- this is the root level
			select @sqlcmd = 'delete from ' + tablename from #tmp where id = @id;
		end -- this is the roolt level

		while @i < @lvl
		begin -- while

			select top 1 @child=TableName, @parent=ParentTable from #tmp where id <= @id-@i and lvl <= @lvl-@i order by lvl desc, id desc;
			set @curFK = cursor for
			select object_id from sys.foreign_keys 
			where parent_object_id = object_id(@child)
			and referenced_object_id = object_id(@parent)

			open @curFK;
			fetch next from @curFk into @fk_object_id
			while @@fetch_status =0
			begin -- @curFK

				if @i=0
					set @sqlcmd = 'delete from ' + @child + @crlf +
					'from ' + @child + @crlf + 'inner join ' + @parent  ;
				else
					set @sqlcmd = @sqlcmd + @crlf + 'inner join ' + @parent ;

				;with c as 
				(
					select child = object_schema_name(fc.parent_object_id)+'.' + object_name(fc.parent_object_id), child_col=c.name
					, parent = object_schema_name(fc.referenced_object_id)+'.' + object_name(fc.referenced_object_id), parent_col=c2.name
					, rnk = row_number() over (order by (select null))
					from sys.foreign_key_columns fc
					inner join sys.columns c
					on fc.parent_column_id = c.column_id
					and fc.parent_object_id = c.object_id
					inner join sys.columns c2
					on fc.referenced_column_id = c2.column_id
					and fc.referenced_object_id = c2.object_id
					where fc.constraint_object_id=@fk_object_id
				)
					select @sqlcmd =@sqlcmd +  case rnk when 1 then ' on '  else ' and ' end 
					+ @child +'.'+ child_col +'='  +  @parent   +'.' + parent_col
					from c;
					fetch next from @curFK into @fk_object_id;
			end --@curFK
			close @curFK;
			deallocate @curFK;
			set @i = @i +1;
		end --while
		--print @sqlcmd + @crlf + @where + ';';
		--set @sqlcmd = @sqlcmd + @crlf +@where + ';';

		set @sqlcmd = @sqlcmd + @crlf + ' where ' + @tableName +'.'+ @pk_column_name + ' in (' + 'select ID from tempdb..Staging_IDs)' + @crlf 
		--print @sqlcmd
		exec (@sqlcmd)
		fetch next from curT into  @lvl, @id;
	end
	close curT;
	deallocate curT;
end
END
GO



DROP PROCEDURE IF EXISTS dbo.usp_delete_from_source_without_pk
GO

CREATE PROCEDURE dbo.usp_delete_from_source_without_pk(@purge_config_id int,@batch_size INT ,@schemaname VARCHAR(100),@tablename VARCHAR(500),@filters VARCHAR(5000)
,@predicate_sql varchar(1000))
AS
 BEGIN
	
	DECLARE @dynamic_sql VARCHAR(8000),@Deleterowcount INT = 1 ,@total_number_of_records_affected int = 0

	-- Mark the status to be in-Progress (0)
	UPDATE dbo.Purge_Config set purge_status = 0 where purge_config_id = @purge_config_id

	WHILE (@Deleterowcount > 0) 
	BEGIN
		
		SET @dynamic_sql =  'delete top ('+cast(@batch_size AS VARCHAR) +')' +' ' + @schemaname+'.'+@tablename + '  from ' + @schemaname+'.'+@tablename + ' ' + @predicate_sql 	
		
		PRINT @dynamic_sql 

		EXEC (@dynamic_sql)
		SET @Deleterowcount = @@ROWCOUNT
		SET @total_number_of_records_affected += @Deleterowcount; 
		INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
		SELECT 'Number of records affected for the table - ' + @schemaname + '.'+@tablename + ' = ' + cast(@Deleterowcount as varchar(10)) + ' Filter Condition - ' + @predicate_sql ,@purge_config_id, getdate()
	END
	PRINT 'Total number of rows affected - ' + cast(@total_number_of_records_affected as varchar(10))
	-- Log only if the total number of records affected is greater than 0
		IF @total_number_of_records_affected > 0 
		BEGIN
			INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
			SELECT '[Total] - ' + @schemaname + '.'+@tablename + ' = [' + cast(@total_number_of_records_affected as varchar(10)) + ']  Filter Condition - ' + @predicate_sql , @purge_config_id,getdate()
		END 
	-- Mark the status to be Completed (1)
	UPDATE dbo.Purge_Config set purge_status = 1 where purge_config_id = @purge_config_id
	
END 
GO


--usp_StartPurge
IF  EXISTS (SELECT * FROM sys.Procedures WHERE object_id = OBJECT_ID(N'[dbo].[usp_StartPurge]') AND type in (N'P'))
BEGIN
	DROP PROCEDURE dbo.usp_StartPurge
END 
GO

/*
BEGIN TRAN
	
	EXEC dbo.usp_StartPurge 

ROLLBACK TRAN
*/
CREATE PROCEDURE dbo.usp_StartPurge
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
declare @history_data_retention_days int 
declare @history_data_retention_cut_off_date_string varchar(100)
declare @purgeOperation_Enabled_Disabled char(5)
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
	purge_config_id , table_schema,table_name,filters
FROM 
	dbo.Purge_Config
WHERE 
	purge_config_id >= @start_purge_config_id
order by 
	purge_config_id asc;

OPEN tableCursor
FETCH NEXT FROM 
			tableCursor 
	INTO  
				@purge_config_id,@schemaname,@tablename,@filters

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
									
				
				------debug statements-- STARTS-----
				if @pk_columnname is null 
				begin
					 print 'No PK found for the table - ' + @tablename
				end 
				------debug statements-- END--- 		
						
						-- If the PK is an INTEGER Column
				IF @PK_column_dataType = 'int'  OR  @PK_column_dataType = 'bigint' -- IF PK  is of Integer Data Type(int or bigint)
				BEGIN
						---- Create a staging table to Hold candidate ids
						if @PK_column_dataType = 'int'
						BEGIN
							EXEC ('CREATE TABLE tempdb..Staging_IDs(ID INT PRIMARY KEY)')
						END
						ELSE
						BEGIN
							EXEC ('CREATE TABLE tempdb..Staging_IDs(ID BIGINT PRIMARY KEY)')
						END 
						--CREATE TABLE tempdb..Staging_IDs(ID int PRIMARY KEY)

				END
				ELSE  -- if the PK is a UNIQUEIDENTIFIER
					BEGIN
						CREATE TABLE tempdb..Staging_IDs (ID uniqueidentifier PRIMARY KEY);
				END
				

				--section get all the lookup / configuration values  -- STARTS 

				SET @history_data_retention_days = (SELECT [setting_value] FROM dbo.Purge_Settings_Config WHERE [setting_name] = 'History_Retention_Days')
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
		
				SET @purge_status = 0 
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
							--BEGIN TRAN
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
								--COMMIT TRAN

						END TRY 
						BEGIN CATCH 
							--ROLLBACK TRAN
							SET @purge_status = 0 -- Mark status as not complete 
							SET @error_msg = 'Error Procedure - ' + ERROR_PROCEDURE() + ' '+ 'Error Line - ' + cast(ERROR_LINE() as varchar) + ' ' + 'Error Message - ' + ERROR_MESSAGE()
							INSERT INTO dbo.Purge_Error_Log(purge_config_id,error_description,error_date)
								SELECT @purge_config_id, @error_msg ,GETDATE()

							END CATCH 
							PRINT 'Number of rows affected - ' + cast(@numOfRowsAffected as varchar(10))

						END -- While Loop End
						--Mark the final Purge Status
						UPDATE dbo.Purge_Config set purge_status = @purge_status where purge_config_id = @purge_config_id

	FETCH NEXT FROM 
			tableCursor 
	INTO 					
		@purge_config_id,@schemaname,@tablename,@filters 

		PRINT 'Total number of rows affected - ' + cast(@total_number_of_records_affected as varchar(10))
		IF @total_number_of_records_affected > 0 -- Log only if the total number of records affected is greater than 0
		BEGIN
			INSERT INTO dbo.Purge_Execution_Log(description_text,purge_config_id,date_created)
			SELECT 'Total - ' + @schemaname + '.'+@tablename + ' = [' + cast(@total_number_of_records_affected as varchar(10)) + ']  Filter Condition - ' + @predicate_sql , @purge_config_id,getdate()
		END 

END-- Cursor Loop End
CLOSE tableCursor
DEALLOCATE tableCursor				
							
END 
GO



------------------------------------------------SEED DATA--------------------------------------------------------------------------
-- Seed Data for Purge Settings Config / Lookups and LookupTypes
-----------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO dbo.Purge_Settings_Config (
		setting_name
		,setting_value
		,description_text
		,date_created
		)
	SELECT 'Purge_Batch_Size'
		,'5000'
		,'batch size of the records being purged. This setting signifies the number of records that are purged at a time'
		,getdate()

INSERT INTO dbo.Purge_Settings_Config (
		setting_name
		,setting_value
		,description_text
		,date_created
		)
	SELECT 'Purge_Duration'
		,'02:00'
		,'The duration of the job in {HH:MM},beyond which it should terminate gracefully. The default is 2 hours {02:00}'
		,getdate()
		
INSERT INTO dbo.Purge_Settings_Config (
		setting_name
		,setting_value
		,description_text
		,date_created
		)
	SELECT 'Enable_Purge_Operation'
		,'ON'
		,'Turn Purge OFF/ON'
		,getdate()


		
INSERT INTO dbo.Purge_Settings_Config (
		setting_name
		,setting_value
		,description_text
		,date_created
		)
	SELECT 'History_Retention_Days'
		,'180'
		,'Number of days beyond which the records will be purged'
		,getdate()


GO
	

------------------------------------------------SEED DATA--------------------------------------------------------------------------
-- Seed Data for Purge_Config
-----------------------------------------------------------------------------------------------------------------------------------

--1 Analytics_Inst_NARJobRunResults
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override], [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (1, N'Purging the Analytics_Inst_NARJobRunResults table', N'HFAMSchema1', N'Analytics_Inst_NARJobRunResults', N'inner join HFAMSchema1.Analytics_Inst_NARJobRuns on HFAMSchema1.Analytics_Inst_NARJobRunResults.JobRunId = HFAMSchema1.Analytics_Inst_NARJobRuns.JobRunId where HFAMSchema1.Analytics_Inst_NARJobRuns.JobStartTime <=  {Date_Parameter}',730,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO

--2 Analytics_Staged_DistinctAlarms
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (2, N'Purging the Analytics_Staged_DistinctAlarms table', N'HFAMSchema1', N'Analytics_Staged_DistinctAlarms', N'join HFAMSchema1.Analytics_Inst_NARJobRuns on HFAMSchema1.Analytics_Staged_DistinctAlarms
.JobRunId = HFAMSchema1.Analytics_Inst_NARJobRuns.JobRunId WHERE HFAMSchema1.Analytics_Inst_NARJobRuns.JobStartTime < {Date_Parameter} ',180,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO

--3 Analytics_Staged_AlarmInstances
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (3, N'Purging the Analytics_Staged_AlarmInstances table', N'HFAMSchema1', N'Analytics_Staged_AlarmInstances', N'join HFAMSchema1.Analytics_Inst_NARJobRuns on HFAMSchema1.Analytics_Staged_AlarmInstances.JobRunId = HFAMSchema1.Analytics_Inst_NARJobRuns.JobRunId WHERE HFAMSchema1.Analytics_Inst_NARJobRuns.JobStartTime < {Date_Parameter} ',180,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO

--4 Inst_JobRunsStatusHistory
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (4, N'Purging the Inst_JobRunsStatusHistory
 table', N'HFAMSchema1', N'Inst_JobRunsStatusHistory
', N'WHERE HFAMSchema1.Inst_JobRunsStatusHistory.UpdatedOn < {Date_Parameter} ',365,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO


--5 Analytics_Inst_NARJobRuns
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (5, N'Purging the Analytics_Inst_NARJobRuns table', N'HFAMSchema1', N'Analytics_Inst_NARJobRuns', N'WHERE HFAMSchema1.Analytics_Inst_NARJobRuns.JobStartTime <= {Date_Parameter}',730,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO


--6 Logs_ParamEnforcementLogs
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (6, N'Purging the Logs_ParamEnforcementLogs table', N'HFAMSchema1', N'Logs_ParamEnforcementLogs', N'WHERE HFAMSchema1.Logs_ParamEnforcementLogs.DtTm <= {Date_Parameter}',180,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO


--7 Logs_EnforcementSessionLogs
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (7, N'Purging the Logs_EnforcementSessionLogs table', N'HFAMSchema1', N'Logs_EnforcementSessionLogs', N'WHERE HFAMSchema1.Logs_EnforcementSessionLogs.DtTm <= {Date_Parameter}',180,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO


--8 Logs_CommentsHistoryLogs
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (8, N'Purging the Logs_CommentsHistoryLogs table', N'HFAMSchema1', N'Logs_CommentsHistoryLogs', N'WHERE HFAMSchema1.Logs_CommentsHistoryLogs.DtTm <= {Date_Parameter}',180,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO

--9 SyncJobLogs
SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters],[history_retention_days_override],  [purge_status],[is_Enabled], [db_datetime_last_updated]) VALUES (9, N'Purging the SyncJobLogs table', N'HFAMSchema1', N'SyncJobLogs', N'WHERE HFAMSchema1.SyncJobLogs.DtTime <= {Date_Parameter}',180,1,1,GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO

