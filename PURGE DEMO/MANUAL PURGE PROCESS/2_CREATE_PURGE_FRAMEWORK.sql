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
	lookupName varchar(200),
	purge_status tinyint,
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
	date_created datetime
)
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
			exec dbo.SP_SEARCH_FK @table, @lvl, @ParentTable, @dbg;
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

--usp_StartPurge
IF  EXISTS (SELECT * FROM sys.Procedures WHERE object_id = OBJECT_ID(N'[dbo].[usp_StartPurge]') AND type in (N'P'))
BEGIN
	DROP PROCEDURE dbo.usp_StartPurge
END 
GO
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
declare @lookupName varchar(250)
declare @start_purge_config_id int = 0
declare @error_msg varchar(max)
declare @purge_status tinyint
declare @purge_job_start_time datetime = GETDATE() -- Purge Job start time 
declare @purge_job_end_time datetime 

SET NOCOUNT ON 

-- Get the configured value for Purge Opertion and Check if Purge is enabled(True) or not (False)
SET @purgeOperation_Enabled_Disabled = (SELECT [Value] FROM dbo.Lookups WHERE [Name] = 'Enable_Purge_Operation')

IF @purgeOperation_Enabled_Disabled <> 'True'
BEGIN
	PRINT 'Purge Operation has been set to OFF'
	RETURN ;
END 


IF EXISTS (SELECT 1 FROM dbo.Purge_Config WHERE purge_status = 0)
BEGIN
	SET @start_purge_config_id =  (SELECT MIN(@purge_config_id) FROM dbo.Purge_Config WHERE purge_status = 0)
END 
-- Get Setting Values -- STARTS--

-- Get the configured batch size for the Purge Operation
SET @batch_size = (SELECT setting_value FROM dbo.Purge_Settings_Config WHERE setting_name = 'Purge_Batch_Size')
SET @job_duration_time = (SELECT setting_value FROM dbo.Purge_Settings_Config WHERE setting_name = 'Purge_Duration')
-- Get Setting Values -- ENDS--

SET @purge_job_end_time = dbo.udf_GetHoursAndMinutes(@purge_job_start_time,@job_duration_time)

declare tableCursor cursor FAST_FORWARD FOR

SELECT  
	purge_config_id , table_schema,table_name,filters,lookupName 
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
				@purge_config_id,@schemaname,@tablename,@filters,@lookupName 

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
							--PRINT @insert_sql
							EXEC (@insert_sql);

							IF (SELECT COUNT(1) AS cnt FROM tempdb..Staging_IDs) = 0
							BEGIN 
								SET @purge_status = 1 
								BREAK ;
							END 
								
						BEGIN TRY
							BEGIN TRAN
								EXEC dbo.usp_delete_from_source @schemaname,@tablename,@filters,@pk_columnname
								
								--- Execution logging STARTS--	
								SET @numOfRowsAffected = (select count(1) as cnt from tempdb..Staging_IDs)-- Get the number of rows affected
								SET @total_number_of_records_affected = @total_number_of_records_affected + @numOfRowsAffected
								IF @numOfRowsAffected > 0 -- Log only if the number of records affected is greater than 0
								BEGIN
									INSERT INTO dbo.Purge_Execution_Log(description_text,date_created)
									SELECT 'Number of records affected for the table - ' + @schemaname + '.'+@tablename + ' = ' + cast(@numOfRowsAffected as varchar(10)) + ' Filter Condition - ' + @predicate_sql , getdate()
								END 
								--- Execution logging ENDS--
								COMMIT TRAN

						END TRY 
						BEGIN CATCH 
							ROLLBACK TRAN
							SET @purge_status = 0 -- Mark status as not complete 
							SET @error_msg = 'Error Procedure - ' + ERROR_PROCEDURE() + ' '+ 'Error Line - ' + cast(ERROR_LINE() as varchar) + ' ' + 'Error Message - ' + ERROR_MESSAGE()
							INSERT INTO dbo.Purge_Error_Log(purge_config_id,error_description,error_date)
								SELECT @purge_config_id, @error_msg , GETDATE()

							END CATCH 
							PRINT 'Number of rows affected - ' + cast(@numOfRowsAffected as varchar(10))

						END -- While Loop End
						--Mark the final Purge Status
						UPDATE dbo.Purge_Config set purge_status = @purge_status where purge_config_id = @purge_config_id

	FETCH NEXT FROM 
			tableCursor 
	INTO 					
		@purge_config_id,@schemaname,@tablename,@filters,@lookupName 

		PRINT 'Total number of rows affected - ' + cast(@total_number_of_records_affected as varchar(10))
		IF @total_number_of_records_affected > 0 -- Log only if the total number of records affected is greater than 0
		BEGIN
			INSERT INTO dbo.Purge_Execution_Log(description_text,date_created)
			SELECT 'Total - ' + @schemaname + '.'+@tablename + ' = [' + cast(@total_number_of_records_affected as varchar(10)) + ']  Filter Condition - ' + @predicate_sql , getdate()
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

GO

DELETE FROM dbo.Lookups WHERE LookupType_PK_ID = (SELECT LookupType_PK_ID FROM dbo.LookupTypes WHERE [Name] = 'History Purging Parameters')
DELETE FROM dbo.LookupTypes where Name = 'History Purging Parameters'


-- LookUpTypes
INSERT INTO dbo.LookupTypes (
		Name
		,Description
		,OWNER
		,LookupType_PK_ID
		)
	SELECT 'History Purging Parameters'
		,'The parameters that are used by the history tables purging process.'
		,'System'
		,NEWID()


-- LookUps
INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'Enable_Purge_Operation'
	,'Set to True,to enable Purge,otherwise set to False.'
	,'False'
	,'Enable_Purge_Operation'
	,'ALL'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'ALL'
GO

-- ShiftSummaryHistory Purge setting
INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'ShiftSummaryHistory_Data_Retention_Days'
	,'The number of days for which the shift summary histtory related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'ShiftSummaryHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

-- Activity History setting
INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'ActivityHistory_Data_Retention_Days'
	,'The number of days for which the Activity history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'ActivityHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'CommentHistory_Data_Retention_Days'
	,'The number of days for which the Comments history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'CommentHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'TagMonitoringHistory_Data_Retention_Days'
	,'The number of days for which the Monitoring history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'TagMonitoringHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'CrossShiftReportGeneratedLinksHistory_Data_Retention_Days'
	,'The number of days for which the CrossShiftReport history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'CrossShiftReportGeneratedLinksHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'InstructionsHistory_Data_Retention_Days'
	,'The number of days for which the Instructions history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'InstructionsHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'MeetingsHistory_Data_Retention_Days'
	,'The number of days for which the Meeting history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'MeetingsHistoryHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'StandingOrdersHistory_Data_Retention_Days'
	,'The number of days for which the StandingOrders history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'StandingOrdersHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO

INSERT INTO dbo.Lookups (
	Name
	,Description
	,Value
	,DisplayName
	,Application
	,Asset
	,Lookup_PK_ID
	,LookupType_PK_ID
	,LookupValueDataType
	,ApplicationDisplayName
	)
SELECT 'TasksHistory_Data_Retention_Days'
	,'The number of days for which the Task history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.'
	,'1825'
	,'TasksHistory_Data_Retention_Days'
	,'Logbook'
	,NULL
	,NEWID()
	,(
		SELECT LookupType_PK_ID
		FROM dbo.LookupTypes
		WHERE name = 'History Purging Parameters'
		)
	,NULL
	,'Logbook'
GO


------------------------------------------------SEED DATA--------------------------------------------------------------------------
-- Seed Data for Purge_Config
-----------------------------------------------------------------------------------------------------------------------------------


SET IDENTITY_INSERT [dbo].[Purge_Config] ON 
GO

INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (1, N'Purging the ActivityAttributeHistory table', N'dbo', N'ActivityAttributeHistory', N'INNER JOIN dbo.ActivityRemarksHistory on dbo.ActivityRemarksHistory.ActivityRemarksHistory_PK_ID = dbo.ActivityAttributeHistory.ActivityRemarksHistory_PK_ID
INNER JOIN dbo.ActivityHistory ON dbo.ActivityHistory.ActivityHistory_PK_ID = dbo.ActivityRemarksHistory.ActivityHistory_PK_ID
WHERE dbo.ActivityHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO


INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (2, N'Purging the ActivityRemarksHistory table', N'dbo', N'ActivityRemarksHistory', N'INNER JOIN dbo.ActivityHistory on dbo.ActivityRemarksHistory.ActivityHistory_PK_ID = dbo.ActivityHistory.ActivityHistory_PK_ID
WHERE dbo.ActivityHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO

INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (3, N'Purging the ActivityReasonHistory table', N'dbo', N'ActivityReasonHistory', N'INNER JOIN dbo.ActivityRemarksHistory on dbo.ActivityRemarksHistory.ActivityHistory_PK_ID = dbo.ActivityReasonHistory.ActivityRemarksHistory_PK_ID
INNER JOIN dbo.ActivityHistory ON dbo.ActivityHistory.ActivityHistory_PK_ID = dbo.ActivityRemarksHistory.ActivityHistory_PK_ID
WHERE dbo.ActivityHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO


INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (4, N'Purging the SplitActivityAttributesHistory table', N'dbo', N'SplitActivityAttributesHistory', N'INNER JOIN dbo.SplitActivityRemarksHistory on dbo.SplitActivityRemarksHistory.SplitActivityRemarksHistory_PK_ID = dbo.SplitActivityAttributesHistory.SplitActivityRemarksHistory_PK_ID
INNER JOIN dbo.SplitActivitiesHistory ON dbo.SplitActivitiesHistory.SplitActivityHistory_PK_ID = dbo.SplitActivityRemarksHistory.SplitActivityHistory_PK_ID
WHERE dbo.SplitActivitiesHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO


INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (5, N'Purging the SplitActivityRemarksHistory table', N'dbo', N'SplitActivityRemarksHistory', N'INNER JOIN dbo.SplitActivitiesHistory on dbo.SplitActivityRemarksHistory.SplitActivityHistory_PK_ID = dbo.SplitActivitiesHistory.SplitActivityHistory_PK_ID
WHERE dbo.SplitActivitiesHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO


INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (6, N'Purging the SplitActivityReasonsHistory table', N'dbo', N'SplitActivityReasonsHistory', N'INNER JOIN dbo.SplitActivityRemarksHistory on dbo.SplitActivityRemarksHistory.SplitActivityRemarksHistory_PK_ID = dbo.SplitActivityReasonsHistory.SplitActivityRemarksHistory_PK_ID INNER JOIN dbo.SplitActivitiesHistory ON dbo.SplitActivitiesHistory.SplitActivityHistory_PK_ID = dbo.SplitActivityRemarksHistory.SplitActivityHistory_PK_ID 
WHERE dbo.SplitActivitiesHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO


INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (7, N'Purging the SplitActivitiesHistory table', N'dbo', N'SplitActivitiesHistory', N'WHERE dbo.SplitActivitiesHistory.StartTime <= {Date_Parameter}',N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO


INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (8, N'Purging the ActivityHistory table', N'dbo', N'ActivityHistory', N' where StartTime <= {Date_Parameter}', N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (9, N'Purging the AssetCommentHistory table', N'dbo', N'AssetCommentHistory', N' where Shift_EndTime <= {Date_Parameter}', N'CommentHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (10, N'Purging the TagMonitoringStatusHistories table', N'dbo', N'TagMonitoringStatusHistories', N' where TagMonitoringStatusHistories.DownTimeEnd <= {Date_Parameter}', N'TagMonitoringHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (11, N'Purging the CrossShiftReportGeneratedLinksHistory table', N'dbo', N'CrossShiftReportGeneratedLinksHistory', N' where CrossShiftReportGeneratedLinksHistory.GeneratedDateTime <= {Date_Parameter}', N'CrossShiftReportGeneratedLinksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (12, N'Purging the Instructions_LimiInstructionHistory table', N'dbo', N'Instructions_LimiInstructionHistory', N'INNER JOIN dbo.InstructionsHistory  ON Instructions_LimiInstructionHistory.InstructionId=InstructionsHistory.InstructionId 
INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId inner join ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (13, N'Purging the Instructions_TextInstructionHistory table', N'dbo', N'Instructions_TextInstructionHistory', N'INNER JOIN dbo.InstructionsHistory  ON Instructions_TextInstructionHistory.InstructionId = InstructionsHistory.InstructionId INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (14, N'Purging the LimitInstructionDetailsHistory table', N'dbo', N'LimitInstructionDetailsHistory', N'INNER JOIN dbo.InstructionsHistory  ON LimitInstructionDetailsHistory.Instruction_InstructionId=InstructionsHistory.InstructionId 
	INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 
	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId  WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (15, N'Purging the InstructionsActionHistoryHistory table', N'dbo', N'InstructionsActionHistoryHistory', N'INNER JOIN dbo.InstructionsHistory  ON InstructionsActionHistoryHistory.Instructions_InstructionID=InstructionsHistory.InstructionId 
	INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 	WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (16, N'Purging the InstructionCommentsHistory table', N'dbo', N'InstructionCommentsHistory', N'INNER JOIN DBO.InstructionsHistory  ON InstructionCommentsHistory.Instruction_InstructionId=InstructionsHistory.InstructionId 
	INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 
	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
	WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND  States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (17, N'Purging the InstructionAttachmentsHistory table', N'dbo', N'InstructionAttachmentsHistory', N'INNER JOIN dbo.InstructionsHistory  ON InstructionAttachmentsHistory.Instruction_InstructionId=InstructionsHistory.InstructionId INNER JOIN States  
ON InstructionsHistory.State_StateId=States.StateId INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter}  AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (18, N'Purging the InstructionAssigneesHistory table', N'dbo', N'InstructionAssigneesHistory', N'INNER JOIN dbo.InstructionsHistory  ON InstructionAssigneesHistory.Instruction_InstructionId=InstructionsHistory.InstructionId INNER JOIN States  
ON InstructionsHistory.State_StateId=States.StateId INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter}  AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (19, N'Purging the InstructionsHistory table', N'dbo', N'InstructionsHistory', N'INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 
	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
	WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter}  AND  States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (20, N'Purging the MeetingNotesAssociationsHistory table', N'dbo', N'MeetingNotesAssociationsHistory', N'INNER JOIN dbo.MeetingsHistory on dbo.MeetingNotesAssociationsHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (21, N'Purging the TaskNotesHistory table', N'dbo', N'TaskNotesHistory', N'INNER JOIN dbo.MeetingNotesAssociationsHistory ON dbo.MeetingNotesAssociationsHistory.TaskNoteTaskNote_PK_ID = dbo.TaskNotesHistory.TaskNote_PK_ID
INNER JOIN dbo.MeetingsHistory ON dbo.MeetingNotesAssociationsHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (22, N'Purging the MeetingParticipantsHistory table', N'dbo', N'MeetingParticipantsHistory', N'INNER JOIN dbo.MeetingsHistory ON dbo.MeetingParticipantsHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID 
	WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (23, N'Purging the MeetingAttributesHistory table', N'dbo', N'MeetingAttributesHistory', N'INNER JOIN dbo.MeetingsHistory ON dbo.MeetingAttributesHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (24, N'Purging the MeetingTasksAssociationsHistory table', N'dbo', N'MeetingTasksAssociationsHistory', N'INNER JOIN dbo.MeetingsHistory ON dbo.MeetingTasksAssociationsHistory .MeetingMeeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (25, N'Purging the MeetingsHistory table', N'dbo', N'MeetingsHistory', N' WHERE StartTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (26, N'Purging the TaskAssigneesHistory table', N'dbo', N'TaskAssigneesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskAssigneesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (27, N'Purging the TaskNoteAssociationsHistory table', N'dbo', N'TaskNoteAssociationsHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
WHERE dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (28, N'Purging the TaskActionHistoriesHistory table', N'dbo', N'TaskActionHistoriesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskActionHistoriesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
WHERE dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (29, N'Purging the TaskNotesHistory table', N'dbo', N'TaskNotesHistory', N'INNER JOIN dbo.TaskNoteAssociationsHistory ON dbo.TaskNoteAssociationsHistory.TaskNote_TaskNotes_PK_ID = dbo.TaskNotesHistory.TaskNote_PK_ID
INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
WHERE dbo.TasksHistory.ActualEndTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (30, N'Purging the TasksHistory table', N'dbo', N'TasksHistory', N' WHERE  ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (31, N'Purging the ShiftSummaryDisplayDataHistory table', N'dbo', N'ShiftSummaryDisplayDataHistory', N' where Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (32, N'Purging the StandingOrderAssigneesHistory table', N'dbo', N'StandingOrderAssigneesHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderAssigneesHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID  
			WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (33, N'Purging the StandingOrderAttachmentsHistory table', N'dbo', N'StandingOrderAttachmentsHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderAttachmentsHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (34, N'Purging the StandingOrderCommentsHistory table', N'dbo', N'StandingOrderCommentsHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderCommentsHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (35, N'Purging the StandingOrderLinksHistory table', N'dbo', N'StandingOrderLinksHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderLinksHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID       
WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (36, N'Purging the StandingOrdersActionHistoryHistory table', N'dbo', N'StandingOrdersActionHistoryHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrdersActionHistoryHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID  
WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (37, N'Purging the StandingOrdersHistory table', N'dbo', N'StandingOrdersHistory', N' WHERE ActualEndTime <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (38, N'Purging the TaskLinksHistory table', N'dbo', N'TaskLinksHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskLinksHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (39, N'Purging the TaskAssigneesHistory table', N'dbo', N'TaskAssigneesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskAssigneesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (40, N'Purging the TaskActionHistoriesHistory table', N'dbo', N'TaskActionHistoriesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskActionHistoriesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (41, N'Purging the TaskAttachmentsHistory table', N'dbo', N'TaskAttachmentsHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskAttachmentsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND  dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (42, N'Purging the TaskNoteAssociationsHistory table', N'dbo', N'TaskNoteAssociationsHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND  dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (43, N'Purging the TaskNotesHistory table', N'dbo', N'TaskNotesHistory', N'INNER JOIN dbo.TaskNoteAssociationsHistory ON dbo.TaskNoteAssociationsHistory.TaskNote_TaskNotes_PK_ID = dbo.TaskNotesHistory.TaskNote_PK_ID INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (44, N'Purging the TasksHistory table', N'dbo', N'TasksHistory', N' WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (45, N'Purging the ShiftSummaryCommentHistory table', N'dbo', N'ShiftSummaryCommentHistory', N' WHERE Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (46, N'Purging the TableSnippetDataHistories table', N'dbo', N'TableSnippetDataHistories', N'INNER JOIN dbo.ShiftSummaryDisplayHistory ON  dbo.ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID =dbo.TableSnippetDataHistories.ShiftSummaryDisplayHistory_PK_ID
INNER JOIN dbo.ShiftSummaryHistory ON dbo.ShiftSummaryDisplayHistory.ShiftSummary_PK_ID = dbo.ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
WHERE dbo.ShiftSummaryHistory.Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (47, N'Purging the ShiftSummaryDisplayTagGroupDataHistory table', N'dbo', N'ShiftSummaryDisplayTagGroupDataHistory', N'INNER JOIN dbo.ShiftSummaryDisplayHistory ON  dbo.ShiftSummaryDisplayTagGroupDataHistory.ShiftSummaryDisplayHistory_PK_ID = dbo.ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID
INNER JOIN dbo.ShiftSummaryHistory ON dbo.ShiftSummaryDisplayHistory.ShiftSummary_PK_ID = dbo.ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
WHERE dbo.ShiftSummaryHistory.Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (48, N'Purging the ShiftSummaryDisplayHistory table', N'dbo', N'ShiftSummaryDisplayHistory', N'INNER JOIN dbo.ShiftSummaryHistory on dbo.ShiftSummaryDisplayHistory.ShiftSummary_PK_ID =dbo.ShiftSummaryHistory.ShiftSummaryHistory_PK_ID WHERE dbo.ShiftSummaryHistory.Shift_EndTime <= {Date_Parameter}
', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Purge_Config] ([purge_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (49, N'Purging the ShiftSummaryHistory table', N'dbo', N'ShiftSummaryHistory', N' where Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Purge_Config] OFF
GO





