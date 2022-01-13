/*
	The function converts a string to a table given the delimter 

	test case : select * from [dbo].[fnSplitStringAsTable]  ('EmployeeID,OrderID,ProductID',',')
	
	parameters : @inputString  - the input string with the delimter
				@delimeter	   - the delimeter upon on which the string needs to be split 
	output : table variable Result set 
*/
CREATE FUNCTION [dbo].[fnSplitStringAsTable] 
(
    @inputString varchar(MAX),
    @delimiter char(1) = ','
)
RETURNS 
@Result TABLE 
(
    Value varchar(MAX)
)
AS
BEGIN
    DECLARE @chIndex int
    DECLARE @item varchar(100)

    -- While there are more delimiters...
    WHILE CHARINDEX(@delimiter, @inputString, 0) <> 0
        BEGIN
            -- Get the index of the first delimiter.
            SET @chIndex = CHARINDEX(@delimiter, @inputString, 0)

            -- Get all of the characters prior to the delimiter and insert the string into the table.
            SELECT @item = SUBSTRING(@inputString, 1, @chIndex - 1)

            IF LEN(@item) > 0
                BEGIN
                    INSERT INTO @Result(Value)
                    VALUES (@item)
                END

            -- Get the remainder of the string.
            SELECT @inputString = SUBSTRING(@inputString, @chIndex + 1, LEN(@inputString))
        END

    -- If there are still characters remaining in the string, insert them into the table.
    IF LEN(@inputString) > 0
        BEGIN
            INSERT INTO @Result(Value)
            VALUES (@inputString)
        END

    RETURN 
END
GO

/*
The function returns the correct value given the index seperated by a comma .

Paramaters : @string - The string from which a given substring value needs to be extracted
			 @index	 - the index of the substring in the given comma delimited string
*/
CREATE FUNCTION [dbo].[SplitString] (@string varchar(MAX), @index int=0)
RETURNS VARCHAR(MAX)
AS
BEGIN
Declare @retrunString Varchar(max)=''


SET @retrunString = 
(select x.i.value('.','varchar(max)') as data 
from 
(
 select CONVERT(XML,'<i>'+REPLACE(@string,',','</i><i>')+'</i>') as data 
)x1 
cross apply data.nodes('i[position()=sql:variable("@index")]')  as x(i)
)

RETURN @retrunString	
END
GO

CREATE TABLE [dbo].[QC_EGMS_ARCHIVAL_CONFIG](
[QC_EGMS_ARCHIVAL_CONFIG_ID] [int] IDENTITY(1,1) NOT NULL,
[ARCHIVAL_TABLE_NAME] [nvarchar](100) NULL,
[PRIMARY_ARCHIVAL_COLUMN_NAME] [nvarchar](max) NULL,
[JOIN_TABLE_NAMES] [nvarchar](max) NULL,
[PREDICATE_CONDITION] [nvarchar](max) NULL,
[JOIN_TYPE] [nvarchar](max) NULL,
[JOIN_COLUMNS] [nvarchar](max) NULL,
[BATCH_SIZE] [int] NULL,
[IS_RUNNING] [bit] NOT NULL,
[IS_ENABLED] [bit] NOT NULL,
[LINKED_SERVER_NAME] [nvarchar](100) NULL,
[ARCHIVE_DATABASE_NAME] [nvarchar](100) NULL,
[ARCHIVE_SCHEMA_NAME] [nvarchar](50) NULL,
[CREATED_BY] [bigint] NOT NULL,
[CREATED_DATE] [datetime] NOT NULL,
[MODIFIED_BY] [bigint] NULL,
[MODIFIED_DATE] [datetime] NULL,
[IS_APPROVED] [bit] NOT NULL,
[APPROVED_BY] [bigint] NOT NULL,
[APPROVED_DATE] [datetime] NOT NULL,
[DESCRIPTION] [nvarchar](1000) NULL,
[IS_RUNNABLE] [bit] NULL,
[EMAIL_RECIPIENTS] [nvarchar](max) NULL,
[JOB_START_TIME] [time](7) NULL,
[JOB_END_TIME] [time](7) NULL,
[SCHEDULE_FREQUENCY_IN_DAYS] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[QC_EGMS_ARCHIVAL_CONFIG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


ALTER TABLE dbo.QC_EGMS_ARCHIVAL_CONFIG ADD MAX_RECORDS_TO_ARCHIVE BIGINT 
GO
ALTER TABLE dbo.QC_EGMS_ARCHIVAL_CONFIG ADD ARCHIVE_DATE_COLUMN VARCHAR(100)
GO 

ALTER TABLE DBO.QC_EGMS_ARCHIVAL_CONFIG ADD MIN_ID BIGINT 
GO
ALTER TABLE DBO.QC_EGMS_ARCHIVAL_CONFIG ADD MAX_ID BIGINT  
GO

ALTER TABLE dbo.QC_EGMS_ARCHIVAL_CONFIG ADD RUN_PRIORITY tinyint 
GO

CREATE TABLE dbo.QC_EGMS_ARCHIVAL_EMAIL_CONFIG
(ID tinyint identity(1,1),Email Nvarchar(100),[TO] BIT,[CC] BIT)
GO


CREATE TABLE dbo.QC_EGMS_ARCHIVAL_OPERATION_TYPE_LK (OPERATION_TYPE_ID tinyint,OPERATION VARCHAR(10))
GO

CREATE TABLE dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG
(QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG_ID INT IDENTITY(1,1)
,QC_EGMS_ARCHIVAL_CONFIG_ID INT
,LAST_EXECUTION_DATE DATE 
,NEXT_EXECUTION_DATE DATE)


CREATE TABLE dbo.QC_EGMS_ARCHIVAL_SQL_QUERY_LOG(ID INT IDENTITY(1,1),QC_EGMS_ARCHIVAL_CONFIG_ID INT,SQL_QUERY VARCHAR(MAX),DATE_CREATED DATETIME)
GO

CREATE TABLE dbo.QC_EGMS_ARCHIVAL_GLOBAL_CONFIG
(
ID TINYINT NOT NULL
,CONFIG_KEY VARCHAR(100)
,CONFIG_DESCRIPTION VARCHAR(100) NOT NULL
,CONFIG_CONDITION VARCHAR(100)
,CONFIG_VALUE VARCHAR(100))
GO


CREATE TABLE [dbo].[QC_EGMS_MASTER_LOOKUP_CONFIG](
	[QC_EGMS_MASTER_LOOKUP_ID] [int] IDENTITY(1,1) NOT NULL,
	[LINK_SERVER] [varchar](200) NULL,
	[SRCDATABASE] [nvarchar](256) NOT NULL,
	[SRCSCHEMA] [nvarchar](50) NOT NULL,
	[SRCTABLE] [nvarchar](256) NOT NULL,
	[TARGETDATABASE] [nvarchar](256) NOT NULL,
	[TARGETSCHEMA] [nvarchar](50) NOT NULL,
	[TARGETTABLE] [nvarchar](256) NOT NULL,
	[PREDICATECLAUSE] [nvarchar](500) NULL,
	[ISACTIVE] [bit] NULL,
	[CREATED_BY] [int] NOT NULL,
	[CREATED_DATE] [datetime] NOT NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [datetime] NULL,
	[TARGETSERVER] [nvarchar](256) NULL,
 CONSTRAINT [PK_QC_EGMS_MASTER_LOOKUP] PRIMARY KEY CLUSTERED 
(
	[QC_EGMS_MASTER_LOOKUP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE dbo.QC_EGMS_MAX_ARCHIVAL_EXECUTION_LOG_ID(qc_egms_archival_execution_log_id bigint)
GO



----TRIGGERS ---STARTS
CREATE TRIGGER dbo.[QC_EGMS_TR_INSERT_QC_EGMS_ARCHIVAL_CONFIG] ON [QC_EGMS_ARCHIVAL_CONFIG] 
AFTER INSERT
AS            
BEGIN
    INSERT INTO dbo.[QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG] (QC_EGMS_ARCHIVAL_CONFIG_ID,NEXT_EXECUTION_DATE)
	SELECT QC_EGMS_ARCHIVAL_CONFIG_ID ,CAST(GETDATE() AS DATE) from INSERTED
	
END
GO



CREATE TRIGGER dbo.[QC_EGMS_TR_UPDATE_QC_EGMS_ARCHIVAL_CONFIG] ON [QC_EGMS_ARCHIVAL_CONFIG] 
AFTER UPDATE
AS            
BEGIN
   
		EXEC dbo.QC_EGMS_SP_RECONCILE_NEXT_EXECUTION_DATE
	
END
GO
----TRIGGERS ---ENDS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
The procedure constructs a SQL Query given the below parameters .

Parameters : @ID - The Archival config ID 
			@Batch_Size INT - the batch size which gets translated to "TOP" command so that the constructed query can limit the number of records being selected.
			
			
Returns : @ret_str - The fully constructed SQL string	that needs to be executed for the given Archival strategy.

*/
CREATE PROCEDURE dbo.QC_EGMS_SP_GET_DYNAMIC_SQLQUERY(@ID INT,@Batch_Size INT, @ret_str varchar(max) output,@Get_Total_Count bit = 0,@archive_date_column varchar(100)=NULL,@Global_Config_Condition varchar(250)= NULL)
AS
BEGIN

/*
declare ,@ret_str varchar(max)
EXEC dbo.QC_EGMS_SP_GET_DYNAMIC_SQLQUERY ,1000,@ret_str ouput
*/
SET NOCOUNT ON 
DECLARE @SQL VARCHAR(MAX) 
DECLARE @COLUMN_NAMES VARCHAR(MAX)
DECLARE @NumberofIterations INT  
DECLARE @StartIterationValue INT = 1
DECLARE @FirstTableName VARCHAR(100)
DECLARE @SecondTableName VARCHAR(100)
DECLARE @FirstJoinType VARCHAR(10)
DECLARE @FirstJoinColumnCondition VARCHAR(100)
DECLARE @crlf char(2)=char(0x0d)+char(0x0a);
DECLARE @JoinTableName VARCHAR(100)
DECLARE @JoinType VARCHAR(100)
DECLARE @JoinColumnCondition VARCHAR(MAX)
DECLARE @PredicateCondition VARCHAR(MAX)

DECLARE @Table_JOIN_COLUMNS Table (ID INT IDENTITY (1,1) ,JOIN_COLUMNS VARCHAR(MAX))
  


--DECLARE @ID INT = 1
 INSERT INTO @Table_JOIN_COLUMNS
 SELECT  d.VALUE AS [TABLE NAMES]
from [dbo].[QC_EGMS_ARCHIVAL_CONFIG] a
OUTER APPLY [dbo].[fnSplitStringAsTable](a.JOIN_COLUMNS,',') d Where QC_EGMS_ARCHIVAL_CONFIG_ID = @ID

SET @NumberofIterations = (select count(1) from @Table_JOIN_COLUMNS)


SET @FirstTableName = (SELECT  dbo.SplitString(JOIN_TABLE_NAMES,1) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)
SET @SecondTableName = (SELECT  dbo.SplitString(JOIN_TABLE_NAMES,2) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)
SET @FirstJoinType = (SELECT  dbo.SplitString(JOIN_TYPE,1) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)
SET @FirstJoinColumnCondition = (SELECT  dbo.SplitString(JOIN_COLUMNS,1) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)
SET @PredicateCondition = (SELECT  PREDICATE_CONDITION FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)

SET @COLUMN_NAMES = (SELECT PRIMARY_ARCHIVAL_COLUMN_NAME from dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)

--select @FirstTableName as firstTableName ,@SecondTableName as secondTableName , @FirstJoinType as FirstJoinType , @FirstJoinColumnCondition as FirstJoinCondition ,@PredicateCondition as predicatecondition 
--select @COLUMN_NAMES as columnNames

IF ISNULL(@SecondTableName,'')=''
BEGIN
	
	SET @SQL = CASE WHEN @Get_Total_Count = 0 THEN  'select TOP(' +CAST(@Batch_Size AS varchar(10))+') '+  @COLUMN_NAMES ELSE 'select @cnt= count(1) ' END 
	+' from ' + @FirstTableName + ' with (nolock) ' + ISNULL(' '+@PredicateCondition,'')
	+ CASE WHEN  ISNULL(@PredicateCondition,'')= '' AND  ISNULL(@archive_date_column,'') <> ''  THEN  ' WHERE ' ELSE CASE WHEN ISNULL(@archive_date_column,'') <>''  THEN ' AND ' 
	+@FirstTableName+'.'+@archive_date_column + ' '+ @Global_Config_Condition ELSE '' END END
--END 
	
	SET @ret_str = @SQL 
	RETURN; 
END

SET @SQL = CASE WHEN @Get_Total_Count = 0 THEN 'Select  TOP(' +CAST(@Batch_Size AS varchar(10))+') ' + @FirstTableName+'.'+@COLUMN_NAMES  ELSE 'select @cnt= count(1) ' END + ' from ' + @FirstTableName + ' with (nolock) ' + @FirstJoinType + ' JOIN ' + @SecondTableName +

 ' with (nolock) ON ' + @FirstJoinColumnCondition + @crlf


WHILE(@StartIterationValue < @NumberofIterations)
BEGIN

SET @StartIterationValue = @StartIterationValue +1

SET @JoinType = (SELECT  dbo.SplitString(JOIN_TYPE,@StartIterationValue) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)
SET @JoinTableName = (SELECT  dbo.SplitString(JOIN_TABLE_NAMES,@StartIterationValue+1) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)
SET @JoinColumnCondition = (SELECT  dbo.SplitString(JOIN_COLUMNS,@StartIterationValue) AS [Value] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)

SELECT @SQL = ISNULL(@SQL,'') +' ' + ISNULL(@JoinType,'') +  ' Join ' + ISNULL(@JoinTableName,'') +  ' with (nolock) ON ' + ISNULL(@JoinColumnCondition,'')

END 

SET @PredicateCondition = (SELECT  PREDICATE_CONDITION FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @ID)

SELECT @SQL = ISNULL(@SQL,'') +ISNULL(' '+@PredicateCondition,'') + CASE WHEN  ISNULL(@PredicateCondition,'') = '' AND ISNULL(@archive_date_column,'') <> '' THEN  ' WHERE ' ELSE CASE WHEN ISNULL(@archive_date_column,'')<>'' THEN ' AND ' 
	+@FirstTableName+'.'+@archive_date_column + ' '+ @Global_Config_Condition ELSE '' END END
 

SET @ret_str = @SQL
RETURN ;
--PRINT @SQL 

END 
GO
/* Description :
      Used to check if indexes are present on the foreign  keys on Acive DB and fail the strategy if not .
	  This will exclude the strategy from archival process until such time till relavent indexes are created on the tables.
	  The procedure would send out an error email notification for each of the strategy that fails to the configured recipients.
		
Paramaters : None 

*/
-- ==========================================================================================================================================
CREATE PROCEDURE dbo.QC_EGMS_SP_CHECK_INDEXES
AS
BEGIN
	SET NOCOUNT ON 

	DECLARE @Procedure_Status int = 0
	
	DECLARE @archival_table_name varchar(100),@archival_config_id int ,@email_recipients nvarchar(max) 
	,@Error_Description_old VARCHAR(MAX),@Error_Description_current VARCHAR(MAX)
	
	UPDATE dbo.QC_EGMS_ARCHIVAL_CONFIG set IS_RUNNABLE = 1		
	
	DECLARE Archival_cursor CURSOR FOR 

			SELECT QC_EGMS_ARCHIVAL_CONFIG_ID
				,ARCHIVAL_TABLE_NAME
				,EMAIL_RECIPIENTS
			FROM 
				dbo.QC_EGMS_ARCHIVAL_CONFIG 
			WHERE 
				IS_ENABLED = 1 AND IS_APPROVED = 1

OPEN Archival_cursor  

FETCH NEXT FROM Archival_cursor INTO @archival_config_id,@archival_table_name,@email_recipients
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		select top 1 @Error_Description_old =  ISNULL(ERROR_DESCRIPTION,'') from dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn 
		where QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id
		AND  CAST(ERROR_DATE AS DATE) = CAST(GETDATE() AS DATE) order by QC_EGMS_ARCHIVAL_ERROR_LOG_ID desc
		
		--- Check for missing indexes and log the error details 
		EXEC @Procedure_Status = dbo.QC_EGMS_SP_MISSING_INDEX_FOREIGN_KEY @archival_table_name,@archival_config_id  
		IF @Procedure_Status > 0
		BEGIN
			--- Update the given strategy to be marked as not Runnable
			UPDATE dbo.QC_EGMS_ARCHIVAL_CONFIG SET IS_RUNNABLE = 0 WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id 

			-- Send an error email only if there hasnt been one sent already for today's date with the same matching error description
		
			SELECT top 1 @Error_Description_current  =   ISNULL(ERROR_DESCRIPTION,'') FROM dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn WITH (NOLOCK) 
			WHERE 
				QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id AND CAST(ERROR_DATE AS DATE) = CAST(GETDATE() AS DATE)
				ORDER BY 
				QC_EGMS_ARCHIVAL_ERROR_LOG_ID DESC
			
			
			SELECT @Error_Description_old as Error_Description_old  , @Error_Description_current as Error_Description_Current
			IF ISNULL(@Error_Description_old,'') <> ISNULL(@Error_Description_current,'')
			BEGIN
					PRINT 'SENDING AN ERROR EMAIL'
					EXEC dbo.QC_EGMS_SP_SEND_DB_MAIL @email_recipients,3 -- SEND ERROR EMAIL NOTIFICATION	
			END
		END

		FETCH NEXT FROM Archival_cursor INTO @archival_config_id,@archival_table_name,@email_recipients
	END
	
	CLOSE Archival_cursor  
	DEALLOCATE Archival_cursor 

	-- If none of the archival strategy can be run , then disable the job schedule
	IF NOT EXISTS (select 1 from dbo.QC_EGMS_ARCHIVAL_CONFIG where IS_enabled = 1 and IS_RUNNABLE = 1) 
	BEGIN
		 EXEC msdb.dbo.sp_update_job @job_name='MANAGE_JOB_SCHEDULE',@enabled = 0 -- Disable the schedule 
	END
	
END
GO


/*
The procedure constructs a HTML formatted email and then send the email to the configured users .
The default list of the configured email recipients is available in the table "dbo.QC_EGMS_ARCHIVAL_EMAIL_CONFIG"
Any additional recipients at each stratgey would be appended to this list to notify the users .

Paramaters : @Email_Recipients - The configured recipients based on each strategy. 
			@email_type - 1 for Error , 2 for Information , 3 for missing Index information

Returns : none

Exec QC_EGMS_SP_SEND_DB_MAIL 'srao.arjun@gmail.com',2,1
*/
CREATE PROCEDURE dbo.QC_EGMS_SP_SEND_DB_MAIL(@Email_Recipients nvarchar(max),@email_type INT = 1,@archival_Config_Id  INT=0,@qc_egms_archival_execution_log_id_start int=0)
AS
BEGIN

BEGIN TRY


declare @toListStr nvarchar(400), @ccListStr nvarchar(400),@start_time datetime , @end_time datetime , @time_elapsed varchar(100)
,@error_message varchar(max)
,@error_description varchar(max) = ''
,@error_line int  
,@error_procedure varchar(100)
,@Mail_Profile Varchar(100)
	

--Build default email recipients for the [TO] list
SELECT @toListStr = COALESCE(@toListStr+';' ,'') + Email
FROM dbo.QC_EGMS_ARCHIVAL_EMAIL_CONFIG where [TO] = 1

-- Add the list of email recipients to the [TO] list additionally based on the archival strategy.
IF @email_recipients LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%' -- Checking if the supplied email address is in valid format or not
BEGIN
	SET @toListStr = @toListStr +';'+@Email_Recipients
END 

--Build default email recipients for the [CC] list
SELECT @ccListStr = COALESCE(@ccListStr+';' ,'') + Email
FROM dbo.QC_EGMS_ARCHIVAL_EMAIL_CONFIG where [CC] = 1


declare @emailSubject varchar(100),
       @textTitle varchar(100),
       @tableHTML nvarchar(max)

set @Mail_Profile = (select CONFIG_VALUE from dbo.QC_EGMS_ARCHIVAL_GLOBAL_CONFIG where CONFIG_KEY = 'MAIL_PROFILE')

if @email_type = 1 -- Error 

BEGIN
	SELECT @emailSubject = 'Archival Error Email',@textTitle = 'Error Information'
	SET @tableHTML = '<html><head><style>' +
		   'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;} ' +
		   '</style></head><body>' +
		   '<div style="margin-top:20px; margin-left:5px; margin-bottom:15px; font-weight:bold; font-size:1.3em; font-family:calibri;">' +
		   @textTitle + '</div>' +
		   '<div style="margin-left:50px; font-family:Calibri;"><table cellpadding=0 cellspacing=0 border=0>' +
		   '<tr bgcolor=#4b6c9e>' +
		   '<td align=center><font face="calibri" color=White><b>Archival Config Description</b></font></td>' +    -- header section
		   '<td align=center style="width:850px;"><font face="calibri" color=White><b>Error Description</b></font></td>' +     -- header section
		   '<td align=center><font face="calibri" color=White><b>Error Date</b></font></td></tr>'   -- header section
END 
ELSE IF @email_type = 2 -- Infomration 
BEGIN
	SELECT @emailSubject = 'Archival Information Email',@textTitle = 'Archive Information'
	
IF (SELECT COUNT(1) FROM dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn WHERE QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID > @qc_egms_archival_execution_log_id_start)>0
BEGIN
	
	SELECT @start_time = MIN(EXECUTION_START_TIME), @end_time = MAX(EXECUTION_END_TIME) from 
	dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn where QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_Config_Id
	and QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID > @qc_egms_archival_execution_log_id_start

	SELECT @time_elapsed =convert(varchar(5),DateDiff(s, @start_time, @end_time)/3600)+' Hours :'+convert(varchar(5),DateDiff(s, @start_time, @end_time)%3600/60)+' Minutes :'+convert(varchar(5),(DateDiff(s, @start_time, @end_time)%60)) +' Seconds' 
	SET @tableHTML = '<html><head><style>' +
		   'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;} ' +
		   '</style></head><body>' +
		   '<div style="margin-top:20px; margin-left:5px; margin-bottom:15px; font-weight:bold; font-size:1.3em; font-family:calibri;">' +
		   @textTitle + '<BR>'+
		   'Execution Time : The Archiving strategy ran from '+ CAST(@start_time as varchar(100)) + ' To ' + CAST(@end_time as varchar(100))+'<BR>'+
		   'Time Elapsed : ' + @time_elapsed +'<BR>' +'</div>' +
		   '<div style="margin-left:50px; font-family:Calibri;"><table cellpadding=0 cellspacing=0 border=0>' +
		   '<tr bgcolor=#4b6c9e>' +
		   '<td align=center><font face="calibri" color=White><b>Archival Config Description</b></font></td>' +    -- header section
		   '<td align=center><font face="calibri" color=White><b>Archival Table Name </b></font></td>' +     -- header section
		   '<td align=center><font face="calibri" color=White><b>Operation type</b></font></td>'+   -- header section
		   '<td align=center><font face="calibri" color=White><b>Number of Records Affected</b></font></td>'+   -- header section
		   '<td align=center><font face="calibri" color=White><b>Source Database Name</b></font></td>'+   -- header section
		   '<td align=center><font face="calibri" color=White><b>Archive Database Name</b></font></td></tr>'   -- header section
END


ELSE --- When there are no records for a given Archival Strategy configuration
BEGIN
		SET @tableHTML = @textTitle + '<BR>'+ 
		'<b>There are no records to be Archived for the given Archival Strategy: <BR>' + 
		'Archvial Config ID - '+ CAST(@archival_Config_Id as varchar)  +'<BR>'+
		'Archival Config Description - ' + 
		(SELECT [DESCRIPTION] FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_Config_Id)
		+'</b>'
			
END
END --@email_type = 2
ELSE IF @email_type = 3
BEGIN --@email_type = 3
	SELECT @emailSubject = 'Missing Indexes Email',@textTitle = 'Missing Indexes Information'
	SET @tableHTML = '<html><head><style>' +
		   'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;} ' +
		   '</style></head><body>' +
		   '<div style="margin-top:20px; margin-left:5px; margin-bottom:15px; font-weight:bold; font-size:1.3em; font-family:calibri;">' +
		   @textTitle + '</div>' +
		   '<div style="margin-left:50px; font-family:Calibri;"><table cellpadding=0 cellspacing=0 border=0>' +
		   '<tr bgcolor=#4b6c9e>' +
			'<td align=center><font face="calibri" color=White><b>ID</b></font></td>' +     -- header section
			'<td align=center><font face="calibri" color=White><b>ERROR DETAILS</b></font></td>'   -- header section
		   
		   
END --@email_type = 3

declare @body varchar(max)
IF @email_type = 1 -- Error 
BEGIN
select @body =
(
   select top 1 ROW_NUMBER() over(order by A.QC_EGMS_ARCHIVAL_ERROR_LOG_ID) % 2 as TRRow,
           td = B.[DESCRIPTION],     -- column names
           td = ISNULL(ERROR_DESCRIPTION,'Unknown Runtime Error'),      -- column names
           td = CAST(ERROR_DATE  as varchar(20))      -- column names
			
   from QC_EGMS_ARCHIVAL_ERROR_LOG_Syn A JOIN dbo.QC_EGMS_ARCHIVAL_CONFIG B ON A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID
  -- WHERE clause if you want to filter on some condition 
   order by QC_EGMS_ARCHIVAL_ERROR_LOG_ID desc
   for XML raw('tr'), elements
)
END

ELSE IF @email_type = 2 -- Information 
BEGIN
select @body =
(	
SELECT 
	
	ISNULL(B.[DESCRIPTION],'') AS TRRow
	,td = A.TABLE_NAME
	,td = CASE WHEN A.OPERATION_TYPE_ID = 1 THEN 'INSERTED' ELSE 'DELETED' END
	,td = SUM(A.NUMBER_OF_RECORDS_AFFECTED) 
	,td = DB_NAME()
	,td = B.ARCHIVE_DATABASE_NAME
	
FROM 
	dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn A JOIN dbo.QC_EGMS_ARCHIVAL_CONFIG B ON A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID
WHERE 
	CAST(EXECUTION_START_TIME AS DATE)= CAST(GETDATE() AS DATE) AND CAST(EXECUTION_END_TIME AS DATE)= CAST(GETDATE() AS DATE)
AND 
	B.QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_Config_Id 
AND 
	A.QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID >@qc_egms_archival_execution_log_id_start
GROUP BY 
	A.TABLE_NAME,A.OPERATION_TYPE_ID,B.[DESCRIPTION],B.ARCHIVE_DATABASE_NAME
ORDER BY 
	A.TABLE_NAME,A.OPERATION_TYPE_ID
 for XML raw('tr'), elements
 )
END


ELSE IF @email_type = 3 -- email_type = 3  
BEGIN
select @body =
(	
SELECT 
		ROW_NUMBER() over(order by ItemID) as td
		,td = Items
		 from dbo.Split_String((select top 1 error_description from dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn order by QC_EGMS_ARCHIVAL_ERROR_LOG_ID desc),'@')
		 Order by ItemId
 for XML raw('tr'), elements
 )
END


set @body = REPLACE(@body, '<td>', '<td align=center><font face="calibri">')
set @body = REPLACE(@body, '</td>', '</font></td>')
set @body = REPLACE(@body, '_x0020_', space(1))
set @body = Replace(@body, '_x003D_', '=')
set @body = Replace(@body, '<tr><TRRow>0</TRRow>', '<tr bgcolor=#F8F8FD>')
set @body = Replace(@body, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#EEEEF4>')
set @body = Replace(@body, '<TRRow>0</TRRow>', '')

set @tableHTML = @tableHTML + ISNULL(@body,'') + '</table></div></body></html>'
set @tableHTML = '<div style="color:Black; font-size:11pt; font-family:Calibri; width:100%;">' + @tableHTML + '</div>'
           
exec msdb.dbo.sp_send_dbmail
   @profile_name = @Mail_Profile,
   @recipients = @toListStr,
   @copy_recipients = @ccListStr,
   @body = @tableHTML,
   @subject = @emailSubject,
   @body_format = 'HTML'

END TRY
BEGIN CATCH
		---Error Log-- STARTS
		set @error_message = error_message()
		select @error_line = ERROR_LINE() , @error_message = ERROR_MESSAGE() , @error_procedure = ERROR_PROCEDURE()
		set @error_description = '[Error Message] - ' + @error_message + ' [Error Procedure]- ' + @error_procedure + ' [Error Line] -' + CAST(@error_line as varchar(10))
			---Error Log-- STARTS
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn 
			(
				QC_EGMS_ARCHIVAL_CONFIG_ID
				,ERROR_DESCRIPTION
				,ERROR_DATE
				)
			SELECT 
				@archival_config_id
				,@error_description
				,GETDATE()
			---Error Log-- ENDS
					
END CATCH

END
GO



/*
The procedure creates a staging table with a given table name and indexes . This table holds the IDs that are candidates for the process
of archival . The ID here represents the PK_KEY from the main Archival Table.

Paramters : @table_name_input - The table name for which the staging table needs to be created .

Returns : none
*/

CREATE PROCEDURE dbo.QC_EGMS_SP_CREATE_DYNAMIC_STAGING_TABLE
(@table_name_input varchar(100))
AS
BEGIN
declare @temp_table_sql varchar(max)
-----CREATE THE STAGING TABLE TO HOLD THE IDs FOR ARCHIVING
set @temp_table_sql = 'DROP TABLE IF EXISTS [tempdb].' +@table_Name_Input+'_Staging
CREATE TABLE [tempdb].' +@table_Name_Input+'_Staging' +' (ID int PRIMARY KEY ,InsertFlag BIT DEFAULT(0),DeleteFlag BIT DEFAULT(0),
INDEX IX_Insert NONCLUSTERED  (InsertFlag) , INDEX IX_Delete NONCLUSTERED  (DeleteFlag))'
EXEC (@temp_table_sql)
END
GO


/*
The procedure inserts records in the staging table based on the archival strategy configuration.

parameters : @table_name_input - The name of the archival table name for which the staging table needs to be populated
			@batch_size_input - The size of the table . This is to insert only the configured number of records in the staging table.
			@id_input - The archival config ID for which the table needs to be populated

Returns : none

*/
CREATE PROCEDURE dbo.QC_EGMS_SP_POPULATE_DYNAMIC_STAGING_TABLE
(@table_name_input varchar(100),@batch_size_input int,@Id_Input int,@archive_date_column varchar(100),@Global_Config_Condition varchar(250))
AS
BEGIN
SET NOCOUNT ON
	declare @temp_table_sql varchar(max), @counts int = 0 , @batch_counter_sql nvarchar(max)

	SET @temp_table_sql = 'DECLARE @ret_str NVARCHAR(MAX) 
		EXEC QC_EGMS_SP_GET_DYNAMIC_SQLQUERY ' +CAST(@Id_Input AS varchar(10))+','+CAST(@batch_size_input as varchar(10))+', @ret_str OUTPUT,0,'''+ISNULL(@archive_date_column,'')+''','''+ISNULL(@Global_Config_Condition,'')+'''
		INSERT INTO [tempdb].' +@table_Name_Input+'_Staging(ID)
		EXEC sp_executesql @ret_str'
		
		--select @temp_table_sql as sql

	EXEC (@temp_table_sql)

	
	SET @batch_counter_sql = ' select @cnt  =  count(1) from [tempdb].' + @table_name_input + '_Staging where DeleteFlag = 0' 
	
	EXECUTE sp_executesql @batch_counter_sql
	,N'@cnt int OUTPUT'
	,@cnt = @counts OUTPUT

	RETURN @counts

	
END
GO



/*
The procedure returns the list of the tables ,their corresponding levels and the parent table for each of the table regardless of the nesting levels

Parameters : @table - The name of the parent table
           			
returns : None 
*/
CREATE proc dbo.QC_EGMS_SP_SEARCH_FK 
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
			exec dbo.QC_EGMS_SP_SEARCH_FK @table, @lvl, @ParentTable, @dbg;
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
			select distinct  tablename, lvl, ParentTable from #tbl;
		
	return;
end
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
@table_name_input -- Name of the input table for archival 
@batch_size_input  -- Number of records to be batched for delete
@Id_Input -- The ID of the Archival strategy based on which the dynamic sql query is returned and the table populated
*/
CREATE PROCEDURE dbo.QC_EGMS_SP_INSERT_ARCHIVAL_DATA_IN_BATCHES
(@table_name_input varchar(100),@batch_size_input int ,@Id_Input int,@archive_database_name_input varchar(100),@linked_server_name varchar(100),@Global_Can_Archive_Child_Tables bit)
AS
BEGIN
SET XACT_ABORT ON 
SET NOCOUNT ON 

if object_id('tempdb..#tmp') is not null
	drop table #tmp;
create table  #tmp  (id int identity(1,1), tablename varchar(256), lvl int, ParentTable varchar(256));

insert into #tmp 
EXEC dbo.QC_EGMS_SP_SEARCH_FK @table=@table_name_input, @debug=0;

declare @curFK cursor, @fk_object_id int;
declare @sqlcmd varchar(max)='', @sqlcmdForRange varchar(max)='', @crlf char(2)=char(0x0d)+char(0x0a);
declare @child varchar(256), @parent varchar(256), @lvl int, @id int;
declare @i int;
declare @t table (tablename varchar(128));
declare @curT cursor;
declare @temp_table_sql varchar(max)
declare @PK_Key Varchar(100)
declare @batch_counter_sql nvarchar(max)
declare @counts int=1
declare @Table_ID INT 
declare @schema_name varchar(50)
declare @msg_description nvarchar(100) = 'Records inserted'
declare @finalSQL  varchar(MAX)=''
declare @sqlcmdExecution varchar(max)=''
declare @child_PK_Key varchar(100)
declare @has_composite_key bit =0
declare @error_message varchar(max) = ''
declare @Max_Counter_Value tinyint 	= 0


SELECT @Max_Counter_Value = CASE WHEN @Global_Can_Archive_Child_Tables = 1 THEN  1 ELSE 0 END 
set @schema_name = (select PARSENAME(@table_name_input,2)) -- Get the schema name 
set @table_name_input = (select PARSENAME(@table_name_input,1)) -- Get only the tablename without the Schema prefix 
set @linked_server_name = (Select case when @linked_server_name IS NOT NULL AND LEN(@linked_server_name)> 1 THEN '['+@linked_server_name +']'+'.' ELSE '' END)



set @PK_Key = (SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
AND TABLE_NAME = @table_name_input AND TABLE_SCHEMA = @schema_name)

BEGIN TRY
	--BEGIN TRANSACTION
		IF CURSOR_STATUS('global','curT')>=-1
			BEGIN
				DEALLOCATE curT
			END
	declare curT cursor for
	select  lvl, id
	from #tmp
	order by lvl asc;

	open curT;
	fetch next from curT into  @lvl, @id;

	while @@FETCH_STATUS =0 
	begin

			if @Global_Can_Archive_Child_Tables = 0 AND  @Max_Counter_Value = 1 
			BREAK;
		
			set @sqlcmdExecution ='DECLARE @records_inserted int = 0, @execution_log_id int = 0' +@crlf+@crlf
			+'if isnull(@MIN_VAL,0)>0' + @crlf 
			+'begin '
			+'insert into dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,EXECUTION_START_TIME,MIN_VALUE,MAX_VALUE,OPERATION_TYPE_ID)' +@crlf
			+'select '+CAST(@id_input as nvarchar(10))+',getdate(),+ isnull(@MIN_VAL,'''') , isnull(@MAX_VAL,''''),1 '+@crlf+@crlf
			--+'set @execution_log_id = IDENT_CURRENT(''dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn'') '+@crlf +'end '+@crlf+@crlf
			+'set @execution_log_id = (Select MAX(QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID) from dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn) '+@crlf +'end '+@crlf+@crlf
		
		set @i=0;
		if @lvl =0
		begin -- this is the root level
								
			select @sqlcmd ='insert into ' + @linked_server_name+@archive_database_name_input+'.'+@schema_name+ '.'+@table_name_input+ @crlf
							+'select * from ' + tablename +' with (NOLOCK) ' from #tmp where id = @id;
			Select @sqlcmdForRange='Declare @MIN_VAL BIGINT,@MAX_VAL BIGINT select @MIN_VAL = Min(' +tablename +'.'+ @PK_Key + '), 
			@MAX_VAL = Max('+ +tablename +'.'+ @PK_Key + ') from ' + tablename +' with (NOLOCK) ' from #tmp where id = @id; 							
									
												
		end -- this is the root level
	
	
		while @i < @lvl
		begin -- while
		
			select top 1 @child=TableName, @parent=ParentTable from #tmp where id <= @id-@i and lvl <= @lvl-@i order by lvl desc, id desc;
			set @curFK = cursor for
			select object_id from sys.foreign_keys 
			where parent_object_id = object_id(@child)
			and referenced_object_id = object_id(@parent)

			set @has_composite_key = CASE WHEN ( SELECT COUNT(COLUMN_NAME) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
								AND TABLE_NAME = PARSENAME(@child,1)AND TABLE_SCHEMA = PARSENAME(@child,2)) >1 THEN 1 ELSE 0 END;
					IF @has_composite_key=0

					BEGIN
						set @child_PK_Key= (SELECT COLUMN_NAME
								FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
									WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
									AND TABLE_NAME = PARSENAME(@child,1)
									AND TABLE_SCHEMA = PARSENAME(@child,2))
					END

					ELSE

						BEGIN
							select @child_PK_Key  = c1.name from sys.objects o1
							INNER JOIN sys.foreign_keys fk  ON o1.object_id = fk.parent_object_id
							INNER JOIN sys.foreign_key_columns fkc  ON fk.object_id = fkc.constraint_object_id
							INNER JOIN sys.columns c1  ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id
							INNER JOIN sys.columns c2  ON fkc.referenced_object_id = c2.object_id  AND fkc.referenced_column_id = c2.column_id
							INNER JOIN sys.objects o2 ON fk.referenced_object_id = o2.object_id
							INNER JOIN sys.key_constraints pk ON fk.referenced_object_id = pk.parent_object_id AND fk.key_index_id = pk.unique_index_id
							where  o1.name = PARSENAME(@child, 1) and o2.name=PARSENAME(@PARENT, 1) 
						END	

			

			open @curFK;
			fetch next from @curFk into @fk_object_id
			while @@fetch_status =0
			begin -- @curFK
			
				 if @i=0
				 BEGIN
					set @sqlcmdForRange =' Declare @MIN_VAL bigint,@MAX_VAL bigint' + @crlf
					+'select @MIN_VAL=min( '+@child+'.' +@child_PK_Key +'),' + ' @MAX_VAL= max( '+@child+'.' +@child_PK_Key +')' + 'from ' + @child +' with (NOLOCK) ' 
					+ @crlf + 'inner join ' + @parent  +' with (NOLOCK) ';
					
					set @sqlcmd ='insert into ' +@linked_server_name+@archive_database_name_input+'.'+ @child+ @crlf +
					'select DISTINCT '+@child+'.* from ' + @child +' with (NOLOCK) ' + @crlf + 'inner join ' + @parent  +' with (NOLOCK) ';
					END
				else
					BEGIN
						set @sqlcmdForRange = @sqlcmdForRange + @crlf + 'inner join ' + @parent ;
						set @sqlcmd = @sqlcmd + @crlf + 'inner join ' + @parent ;
					END

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
					+ @child +'.'+ child_col +'='  +  @parent   +'.' + parent_col +@crlf
					,  @sqlcmdForRange =@sqlcmdForRange +  case rnk when 1 then ' on '  else ' and ' end 
					+ @child +'.'+ child_col +'='  +  @parent   +'.' + parent_col
					from c;
					fetch next from @curFK into @fk_object_id;
				
					
			end --@curFK
			close @curFK;
			deallocate @curFK;
			set @i = @i +1;
			
	
		end --while
		
		SET @finalSQL  ='SELECT ID FROM [tempdb]..' +@table_name_input+'_Staging'
		SET @sqlcmd = @sqlcmdExecution+@sqlcmd + @crlf + 'WHERE ' + @table_name_input+'.' +@PK_Key + ' IN (' + @finalSQL  +');'+@crlf+@crlf;
		SET @sqlcmdForRange = @sqlcmdForRange + @crlf + 'WHERE ' + @table_name_input+'.' +@PK_Key + ' IN (' + @finalSQL  +');'+@crlf+@crlf;
		
		
		SET @sqlcmd = @sqlcmd
						+'set @records_inserted = @@ROWCOUNT' +@crlf
						+ ' if @records_inserted>0'+@crlf
						+'begin '
						+@crlf
						+'UPDATE dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn SET EXECUTION_END_TIME = getdate(),NUMBER_OF_RECORDS_AFFECTED = @records_inserted
						,TABLE_NAME =''' +ISNULL(@child,@table_name_input)+''' '
						+'where QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID = @execution_log_id '+@crlf + 'end'+@crlf	
						--+'GO'

		Set @sqlcmd= @sqlcmdForRange+@crlf+@crlf+ @sqlcmd ;
		--PRINT @sqlcmd;
		--PRINT '';
		EXEC (@sqlcmd); 
		set @Max_Counter_Value +=1
	fetch next from curT into  @lvl, @id;
		
	end
		
	close curT;
	deallocate curT;
	
	--	---SQL QUERY LOGGING HERE -- Refer table QC_EGMS_ARCHIVAL_SQL_QUERY_LOG 
	--IF @log_sql_query = 1 
	--	BEGIN
	--		INSERT INTO dbo.QC_EGMS_ARCHIVAL_SQL_QUERY_LOG
	--		SELECT 	@Id_Input,@sqlcmd + @crlf,GETDATE()	
	--	END

	END TRY
	
		BEGIN CATCH
			set @error_message = error_message()
			;THROW 51000,@error_message,1;
	
		END CATCH
	SET XACT_ABORT OFF 
END
GO



/*
@table_name_input -- Name of the input table for archival 
@batch_size_input  -- Number of records to be batched for delete
@Id_Input -- The ID of the Archival strategy based on which the dynamic sql query is returned and the table populated
*/
CREATE PROCEDURE dbo.QC_EGMS_SP_DELETE_ARCHIVAL_DATA_IN_BATCHES (
	@table_name_input VARCHAR(100)
	,@batch_size_input INT = 0
	,@Id_Input INT
	,@Global_Can_Archive_Child_Tables bit
	)
AS
BEGIN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	declare @error_message varchar(max) = ''
	IF object_id('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp;

	CREATE TABLE #tmp (
		id INT IDENTITY(1,1)
		,tablename VARCHAR(256)
		,lvl INT
		,ParentTable VARCHAR(256)
		);

	INSERT INTO #tmp
	EXEC dbo.QC_EGMS_SP_SEARCH_FK @table = @table_name_input
		,@debug = 0;

	DECLARE @curFK CURSOR
		,@fk_object_id INT
		,@sqlcmd VARCHAR(max) = ''
		,@sqlcmdForRange varchar(max)=''
		,@crlf CHAR(2) = CHAR(0x0D) + CHAR(0x0A)
		,@child VARCHAR(256)
		,@parent VARCHAR(256)
		,@lvl INT
		,@id INT
		,@i INT
		,@temp_table_sql VARCHAR(max)
		,@PK_Key VARCHAR(100)
		,@child_PK_Key VARCHAR(100)
		,@has_composite_key BIT
		,@Update_SQL VARCHAR(max)
		,@batch_counter_sql NVARCHAR(max)
		,@counts INT = 1
		,@sqlcmdExecution varchar(max)=''
		declare @Max_Counter_Value bit = 0
		,@msg_description nvarchar(100) = 'Records deleted'
		declare @schema_name varchar(50);
		set @schema_name = (select PARSENAME(@table_name_input,2)) -- Get the schema name 
		set @table_name_input = (select PARSENAME(@table_name_input,1)) -- Get only the tablename without the Schema prefix 
		declare @Table_ID INT;DECLARE @t TABLE (tablename VARCHAR(128)) DECLARE @curT CURSOR SET @PK_Key = (
			SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
				AND TABLE_NAME = @table_name_input
				AND TABLE_SCHEMA = @schema_name
			) 

		SELECT @Max_Counter_Value = CASE WHEN @Global_Can_Archive_Child_Tables = 1 THEN  1 ELSE 0 END 
		
		BEGIN TRY
			--BEGIN TRANSACTION

			IF CURSOR_STATUS('global', 'curT') >= - 1
			BEGIN
				DEALLOCATE curT
			END

			DECLARE curT CURSOR
			FOR
			SELECT lvl
				,id
			FROM #tmp
			ORDER BY lvl DESC;

			OPEN curT;

			FETCH NEXT
			FROM curT
			INTO @lvl
				,@id;

			WHILE @@FETCH_STATUS = 0
			BEGIN
	
			set @sqlcmdExecution ='DECLARE @records_deleted int = 0, @execution_log_id int = 0' +@crlf+@crlf
			+'if isnull(@MIN_VAL,0)>0' + @crlf 
			+'begin '
			+'insert into dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,EXECUTION_START_TIME,MIN_VALUE,MAX_VALUE,OPERATION_TYPE_ID)' +@crlf
			+'select '+CAST(@id_input as nvarchar(10))+',getdate(),@MIN_VAL,@MAX_VAL,2'+@crlf+@crlf
			--+'set @execution_log_id = IDENT_CURRENT(''dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn'') '+@crlf +'end '+@crlf+@crlf
			+'set @execution_log_id = (Select MAX(QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID) from dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn) '+@crlf +'end '+@crlf+@crlf

				SET @i = 0;

				IF @lvl = 0
				BEGIN -- this is the root level
					SELECT @sqlcmdForRange = ' DECLARE @MIN_VAL BIGINT, @MAX_VAL BIGINT'+@crlf
					+' SELECT @MIN_VAL = MIN('+tablename+'.'+@PK_Key+' ), @MAX_VAL = MAX('+tablename+'.'+@PK_Key+') FROM ' + tablename 
					FROM #tmp
					WHERE id = @id;
					SELECT @sqlcmd = 'delete from ' + tablename 
					FROM #tmp
					WHERE id = @id;
				END -- this is the root level
				
			if @Global_Can_Archive_Child_Tables = 1  -- Archive Child Tables
			BEGIN 
		
				WHILE @i < @lvl
				BEGIN -- while
					SELECT TOP 1 @child = TableName
						,@parent = ParentTable
					FROM #tmp
					WHERE id <= @id - @i
						AND lvl <= @lvl - @i
					ORDER BY lvl DESC
						,id DESC;

					SET @curFK = CURSOR
					FOR

					SELECT object_id
					FROM sys.foreign_keys
					WHERE parent_object_id = object_id(@child)
						AND referenced_object_id = object_id(@parent)

					set @has_composite_key = CASE WHEN ( SELECT COUNT(COLUMN_NAME) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
								AND TABLE_NAME = PARSENAME(@child,1)AND TABLE_SCHEMA = PARSENAME(@child,2)) >1 THEN 1 ELSE 0 END;
					IF @has_composite_key=0

					BEGIN
						set @child_PK_Key= (SELECT COLUMN_NAME
								FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
									WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
									AND TABLE_NAME = PARSENAME(@child,1)
									AND TABLE_SCHEMA = PARSENAME(@child,2))
						END

					ELSE

						BEGIN
							select @child_PK_Key  = c1.name from sys.objects o1
							INNER JOIN sys.foreign_keys fk  ON o1.object_id = fk.parent_object_id
							INNER JOIN sys.foreign_key_columns fkc  ON fk.object_id = fkc.constraint_object_id
							INNER JOIN sys.columns c1  ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id
							INNER JOIN sys.columns c2  ON fkc.referenced_object_id = c2.object_id  AND fkc.referenced_column_id = c2.column_id
							INNER JOIN sys.objects o2 ON fk.referenced_object_id = o2.object_id
							INNER JOIN sys.key_constraints pk ON fk.referenced_object_id = pk.parent_object_id AND fk.key_index_id = pk.unique_index_id
							where  o1.name = PARSENAME(@child, 1) and o2.name=PARSENAME(@PARENT, 1) 
						END	

				
					OPEN @curFK;

					FETCH NEXT
					FROM @curFk
					INTO @fk_object_id

					WHILE @@fetch_status = 0
					BEGIN -- @curFK
					
						IF @i = 0
						
						Begin
						       SET @sqlcmdForRange =  ' DECLARE @MIN_VAL BIGINT, @MAX_VAL BIGINT'+@crlf
							   +'select @MIN_VAL = Min(' + @child + '.'+ @child_PK_Key +'), @MAX_VAL = Max(' + @child + '.'+ @child_PK_Key +') FROM ' + @child + @crlf 
							   + ' WHERE '+ @child + '.'+@child_PK_Key + ' IN ( SELECT ' + @child + '.'+@child_PK_Key + ' from ' + @child +' with(nolock) ' + @crlf + 'inner join ' 
							   + @parent +' with(nolock)';
							
								SET @sqlcmd = 'delete from '+ @child + @crlf + ' WHERE '+ @child + '.'+@child_PK_Key + ' IN ( SELECT ' + @child + '.'+@child_PK_Key + ' from ' + @child +' with(nolock) '
								 + @crlf + 'inner join ' + @parent +' with(nolock)';

							--SET @sqlcmd = 'delete from ' + @child + @crlf + 'from ' + @child + @crlf + 'inner join ' + @parent +' with(nolock)';
							End
						ELSE
						begin
						set  @sqlcmdForRange = @sqlcmdForRange +  @crlf + 'inner join ' + @parent +' with(nolock)';; 
							--SET @sqlcmd = @sqlcmd + @crlf + 'inner join ' + @parent +'with(nolock)';
							SET @sqlcmd = @sqlcmd + @crlf + 'inner join ' + @parent +' with(nolock)';;
						
						end;
						WITH c
						AS (
							SELECT child = object_schema_name(fc.parent_object_id) + '.' + object_name(fc.parent_object_id)
								,child_col = c.name
								,parent = object_schema_name(fc.referenced_object_id) + '.' + object_name(fc.referenced_object_id)
								,parent_col = c2.name
								,rnk = row_number() OVER (
									ORDER BY (
											SELECT NULL
											)
									)
							FROM sys.foreign_key_columns fc
							INNER JOIN sys.columns c ON fc.parent_column_id = c.column_id
								AND fc.parent_object_id = c.object_id
							INNER JOIN sys.columns c2 ON fc.referenced_column_id = c2.column_id
								AND fc.referenced_object_id = c2.object_id
							WHERE fc.constraint_object_id = @fk_object_id
							)
						SELECT @sqlcmd = @sqlcmd + CASE rnk
								WHEN 1
									THEN ' on '
								ELSE ' and '
								END + @child + '.' + child_col + '=' + @parent + '.' + parent_col
								,@sqlcmdForRange= @sqlcmdForRange + CASE rnk
								WHEN 1
									THEN ' on '
								ELSE ' and '
								END + @child + '.' + child_col + '=' + @parent + '.' + parent_col

						FROM c;

						FETCH NEXT
						FROM @curFK
						INTO @fk_object_id;
					END --@curFK

					CLOSE @curFK;

					DEALLOCATE @curFK;

					SET @i = @i + 1;
				END --while
				END -- Archive Child Tables
				DECLARE @finalSQL VARCHAR(MAX) = 'SELECT ID FROM [tempdb]..' + @table_name_input + '_Staging'
					SET @sqlcmdForRange=@sqlcmdForRange + @crlf +  ' WHERE ' + @table_name_input + '.' + @PK_Key +
					' IN (' + @finalSQL + CASE WHEN @lvl =0  then  ');' else '));' end ;
			 					
					SET @sqlcmd =  @sqlcmdExecution+@sqlcmd + @crlf + ' WHERE ' + @table_name_input + '.' + @PK_Key +
					' IN (' + @finalSQL + CASE WHEN @lvl =0 then  ');' else '));' end ;
			 					
					set @sqlcmd = @sqlcmdForRange + @crlf +@crlf+ @sqlcmd +@crlf+'set @records_deleted = @@ROWCOUNT'+@crlf
					+ ' if @records_deleted>0'+@crlf
					+'begin '
					+@crlf
					+'UPDATE dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn SET EXECUTION_END_TIME = getdate(),NUMBER_OF_RECORDS_AFFECTED = @records_deleted
					,TABLE_NAME ='''+CASE WHEN @lvl = 0  then @table_name_input else @child end +''' '
					+'where QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID = @execution_log_id'+@crlf + 'end' +@crlf		
				--PRINT @sqlcmd
				EXEC (@sqlcmd);

				FETCH NEXT
				FROM curT
				INTO @lvl
					,@id;
			END

			--SET @Update_SQL = 'Update ' + @table_name_input + '_Staging' + ' set DeleteFlag = 1 where ID IN' + @crlf +
			--' (select ID FROM ' + @table_name_input + '_Staging' + ' where DeleteFlag = 0)'

			SET @Update_SQL = 'TRUNCATE TABLE [tempdb]..' +@table_name_input+'_Staging'

			
			--PRINT @update_sql
			EXEC (@Update_SQL)
			
			CLOSE curT;

			DEALLOCATE curT;

	---SQL QUERY LOGGING HERE -- Refer table QC_EGMS_ARCHIVAL_SQL_QUERY_LOG 
	--IF @log_sql_query = 1 
	--	BEGIN
	--		INSERT INTO dbo.QC_EGMS_ARCHIVAL_SQL_QUERY_LOG
	--		SELECT 	@Id_Input,@sqlcmd + @crlf + @Update_SQL,GETDATE()	
	--	END

		END TRY

		BEGIN CATCH
			
			set @error_message = error_message()
			;THROW 51000,@error_message,1;
		END CATCH
		SET XACT_ABORT OFF 
		
END
GO

CREATE PROCEDURE dbo.QC_EGMS_SP_VALIDATE_CONFIGURATION_DATA
AS
BEGIN

SET NOCOUNT ON 
	DECLARE @archival_table_name varchar(100),
			@batch_size int
			,@archival_config_id int 
			,@linked_server_name nvarchar(100)
			,@archive_database_name nvarchar(100)
			,@archive_schema_name nvarchar(50)
			,@schedule_frequency_in_days int
			,@email_recipients nvarchar(max)
			,@next_execution_date date
			,@job_start_time time
			,@job_end_time time
			,@remaining_records_count int = 0
			,@counter int = 0
			,@qc_egms_archival_execution_log_id_start int = 0
			,@error_description varchar(max) = ''
			,@error_line int  
			,@error_message varchar(max)='' 
			,@error_procedure varchar(100)
			,@is_error tinyint =0
			,@max_number_of_records_to_archive bigint = 0
			,@Predicate_Condition varchar(500)
			,@archive_date_column varchar(100)
			,@global_config_condition varchar(250)
			,@retrun_Count bigint = 0
			,@ret_str nvarchar(max)=''
	
	DECLARE ArchivalValidation_cursor CURSOR  FOR 

		SELECT 
			A.QC_EGMS_ARCHIVAL_CONFIG_ID
			,A.ARCHIVAL_TABLE_NAME
			,A.BATCH_SIZE
			,A.EMAIL_RECIPIENTS
			,A.JOB_START_TIME
			,A.JOB_END_TIME
			,B.NEXT_EXECUTION_DATE
			,A.SCHEDULE_FREQUENCY_IN_DAYS
			,A.MAX_RECORDS_TO_ARCHIVE
			,A.ARCHIVE_DATE_COLUMN
			,A.PREDICATE_CONDITION
		FROM 
			dbo.QC_EGMS_ARCHIVAL_CONFIG A 
		JOIN 
			dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B 
		ON 
			A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID
		WHERE 
			IS_ENABLED = 1 AND IS_RUNNABLE = 1 AND IS_APPROVED = 1


OPEN ArchivalValidation_cursor  

FETCH NEXT FROM ArchivalValidation_cursor INTO 
									@archival_config_id
									,@archival_table_name
									,@batch_size
									,@email_recipients
									,@job_start_time
									,@job_end_time
									,@next_execution_date 
									,@schedule_frequency_in_days 
									,@max_number_of_records_to_archive
									,@archive_date_column
									,@Predicate_Condition


	WHILE @@FETCH_STATUS = 0  
	BEGIN 
	BEGIN TRY 
		SET @is_error = 0;
		SET @global_config_condition = (select CONFIG_CONDITION from dbo.QC_EGMS_ARCHIVAL_GLOBAL_CONFIG where CONFIG_KEY = 'SERVER_DATE')
		-- Validate column "ARCHIVAL_TABLE_NAME"
		IF RTRIM(LTRIM(REPLACE(REPLACE(@archival_table_name,'.',''),'_',''))) LIKE '%[^a-zA-Z0-9]%'
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'The column "ARCHIVAL_TABLE_NAME" is not correctly configured.',GETDATE())
			SET @is_error = 1
		END
		-- Validate columns "JOB_START_TIME" AND "JOB_END_TIME"
		IF CONVERT(VARCHAR(26),@job_start_time,108) >= CONVERT(VARCHAR(26),@job_end_time,108)	
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'The columns "JOB_START_TIME" and "JOB_END_TIME" are not correctly configured.Please check to see if End time is greater than start time',GETDATE())
			SET @is_error = 1
		END
		
		-- Validate column "BATCH_SIZE" 
		IF ISNULL(@batch_size,0) <=0
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'The columns "BATCH_SIZE" is not correctly configured.Please check to see if "BATCH_SIZE" is greater than 0',GETDATE())
			SET @is_error = 1
		END
		-- Validate column "EMAIL CONFIG TABLE" 
		IF (SELECT COUNT(1) from dbo.QC_EGMS_ARCHIVAL_EMAIL_CONFIG where [TO] = 1) =0
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'At least one value should be configured as a [TO] address in the Table "QC_EGMS_ARCHIVAL_EMAIL_CONFIG"',GETDATE())
			SET @is_error = 1
		END

		-- Validate column "SCHEDULE_FREQUENCY_IN_DAYS" 
		IF ISNULL(@schedule_frequency_in_days,0) <=0
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'The columns "SCHEDULE_FREQUENCY_IN_DAYS" is not correctly configured.Please check to see if "SCHEDULE_FREQUENCY_IN_DAYS" is greater than 0',GETDATE())
			SET @is_error = 1
		END

		-- Validate column "SCHEDULE_FREQUENCY_IN_DAYS" 
		IF ISNULL(@schedule_frequency_in_days,0) <=0
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'The columns "SCHEDULE_FREQUENCY_IN_DAYS" is not correctly configured.Please check to see if "SCHEDULE_FREQUENCY_IN_DAYS" is greater than 0',GETDATE())
			SET @is_error = 1
		END
		-- Validate column "SCHEDULE_FREQUENCY_IN_DAYS" 
		IF ISNULL(@Predicate_Condition,'') =''
		BEGIN
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			VALUES(@archival_config_id,'The columns "PREDICATE_CONDITION" Cannot be empty',GETDATE())
			SET @is_error = 1
		END

		
			--EXEC dbo.QC_EGMS_SP_GET_DYNAMIC_SQLQUERY @archival_config_id,@batch_size, @ret_str output,0,@archive_date_column,@global_config_condition
			--EXEC (@ret_str) -- Execute the dynamic sql to check the dynamic compilation of the query
		
			 --paramter value of 1 is to get the count of the query condition for Archival
			--EXEC dbo.QC_EGMS_SP_GET_DYNAMIC_SQLQUERY @archival_config_id,@batch_size, @ret_str output,1,@archive_date_column,@global_config_condition
			--EXECUTE sp_executesql @ret_str, N'@cnt bigint OUTPUT', @cnt=@retrun_Count OUTPUT

			--IF @retrun_Count > @max_number_of_records_to_archive
			--BEGIN
			--	INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
			--	VALUES(@archival_config_id,'The query condition results in more number of records to be Archived than is configured.Please check the value of "MAX_RECORDS_TO_ARCHIVE"',GETDATE())
			--	SET @is_error = 1
			--END



	END TRY 
	BEGIN CATCH
				INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(QC_EGMS_ARCHIVAL_CONFIG_ID,ERROR_DESCRIPTION,ERROR_DATE)
				VALUES(@archival_config_id,ERROR_MESSAGE(),GETDATE())
				SET @is_error = 1
				EXEC dbo.QC_EGMS_SP_SEND_DB_MAIL @email_recipients,1 -- SEND ERROR EMAIL NOTIFICATION
	END CATCH 
	IF @is_error = 1 
	BEGIN
		Update dbo.QC_EGMS_ARCHIVAL_CONFIG set IS_RUNNABLE = 0 Where QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id 
	END
FETCH NEXT FROM ArchivalValidation_cursor INTO  
										@archival_config_id
										,@archival_table_name
										,@batch_size
										,@email_recipients
										,@job_start_time
										,@job_end_time
										,@next_execution_date 
										,@schedule_frequency_in_days 
										,@max_number_of_records_to_archive
										,@archive_date_column
										,@Predicate_Condition
	END -- Cursor Loop end

	IF CURSOR_STATUS('global','ArchivalValidation_cursor')>=-1
	BEGIN
		CLOSE ArchivalValidation_cursor  
		DEALLOCATE ArchivalValidation_cursor 
	END

return  @is_error
END
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================
/* Description :
      Used to recursively call the procedure for inserting the Archive data in batches to Archive DB and then delete the data from 
	  the Active DB.
	  In case of an error , the procedure would exit and send out an error email notification to the configured recipients.
		
Paramaters : None Comments
*/
CREATE PROCEDURE dbo.QC_EGMS_SP_RUN_ARCHIVING
AS
BEGIN
	
	EXEC dbo.QC_EGMS_SP_VALIDATE_CONFIGURATION_DATA
	
	SET NOCOUNT ON 
	DECLARE @archival_table_name varchar(100),
			@primary_archival_column varchar(100),
			@batch_size int
			,@archival_config_id int 
			,@linked_server_name nvarchar(100)
			,@archive_database_name nvarchar(100)
			,@archive_schema_name nvarchar(50)
			,@schedule_frequency_in_days int
			,@email_recipients nvarchar(max)
			,@next_execution_date date
			,@job_start_time time
			,@job_end_time time
			--,@remaining_records_count int = 0
			--,@counter int = 0
			,@max_Id_Return bigint
			,@qc_egms_archival_execution_log_id_start int = 0
			,@archive_date_column varchar(100)
			,@error_description varchar(max) = ''
			,@error_line int  
			,@error_message varchar(max)='' 
			,@error_procedure varchar(100)
			,@Global_Config_Condition Varchar(100)
			,@Global_Can_Archive_Child_Tables bit=1
			,@last_max_id BIGINT 
			,@min_id BIGINT
			,@max_id BIGINT
	
	-- Get the global Config condition for Archival Date 
	SET @Global_Config_Condition = (select CONFIG_CONDITION from dbo.QC_EGMS_ARCHIVAL_GLOBAL_CONFIG where CONFIG_KEY = 'SERVER_DATE')
	SET @Global_Can_Archive_Child_Tables = (Select case when CONFIG_VALUE = 'Y' THEN 1 ELSE 0 END from dbo.QC_EGMS_ARCHIVAL_GLOBAL_CONFIG 
											where CONFIG_KEY = 'ARCHIVE_CHILD_TABLES')

	DECLARE Archival_cursor CURSOR  FOR 

		SELECT 
			A.QC_EGMS_ARCHIVAL_CONFIG_ID
			,A.ARCHIVAL_TABLE_NAME
			,A.PRIMARY_ARCHIVAL_COLUMN_NAME
			,A.BATCH_SIZE
			,A.LINKED_SERVER_NAME
			,A.ARCHIVE_DATABASE_NAME
			,A.ARCHIVE_SCHEMA_NAME 
			,A.SCHEDULE_FREQUENCY_IN_DAYS
			,A.EMAIL_RECIPIENTS
			,A.JOB_START_TIME
			,A.JOB_END_TIME
			,B.NEXT_EXECUTION_DATE
			,A.ARCHIVE_DATE_COLUMN
			,A.Min_ID
			,A.Max_ID
		FROM 
			dbo.QC_EGMS_ARCHIVAL_CONFIG A 
		JOIN 
			dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B 
		ON 
			A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID
		WHERE 
			IS_ENABLED = 1 AND IS_RUNNABLE = 1 AND IS_APPROVED = 1
		ORDER BY 
				RUN_PRIORITY ASC;

OPEN Archival_cursor  

FETCH NEXT FROM Archival_cursor INTO 
									@archival_config_id
									,@archival_table_name
									,@primary_archival_column
									,@batch_size
									,@linked_server_name
									,@archive_database_name
									,@archive_schema_name
									,@schedule_frequency_in_days
									,@email_recipients
									,@job_start_time
									,@job_end_time
									,@next_execution_date 
									,@archive_date_column
									,@min_id
									,@max_id

	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		
		IF CONVERT(VARCHAR(5),GETDATE(),108) BETWEEN @job_start_time AND  @job_end_time AND  @next_execution_date = CAST(GETDATE() AS DATE)
		BEGIN
		--print 'create dynamic staging table starts'
		--EXEC dbo.QC_EGMS_SP_CREATE_DYNAMIC_STAGING_TABLE @archival_table_name --- Create dynamic staging table to hold ParentIDs
		EXEC dbo.QC_EGMS_SP_CREATE_DYNAMIC_STAGING_TABLE_V2 @archival_table_name --- Create dynamic staging table to hold ParentIDs
		-- set the flag to true to indicate that a job is running for a given startegy
		UPDATE dbo.QC_EGMS_ARCHIVAL_CONFIG SET IS_RUNNING = 1 WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id 
		--SET @counter = 0;
		SET @qc_egms_archival_execution_log_id_start = (select ISNULL(max(QC_EGMS_ARCHIVAL_EXECUTION_LOG_ID),0) from dbo.QC_EGMS_ARCHIVAL_EXECUTION_LOG_Syn with (nolock))
		---Log the current max archival execution log id -- This is required for generating reports should an error occur or the job is stopped midway.
		TRUNCATE TABLE dbo.QC_EGMS_MAX_ARCHIVAL_EXECUTION_LOG_ID
		INSERT INTO dbo.QC_EGMS_MAX_ARCHIVAL_EXECUTION_LOG_ID
		VALUES(@qc_egms_archival_execution_log_id_start)
		
		WHILE (1=1)
			BEGIN
					--SET @counter +=1;
					/*If the current time is past the configured strategy Schedule JOB_END_TIME , update the next schedule and 
					pick the next strategy based on the date and time configuration	
					*/
					IF CONVERT(VARCHAR(5),GETDATE(),108) >= (SELECT JOB_END_TIME FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id)
					BEGIN
						BREAK;
					END
				
				-- if there are no more records 
				BEGIN TRY
				--EXEC @remaining_records_count =  dbo.QC_EGMS_SP_POPULATE_DYNAMIC_STAGING_TABLE_V2 @archival_table_name,@batch_size,@archival_config_id,@archive_date_column,@Global_Config_Condition,@primary_archival_column,@min_id,@max_id,@last_max_id OUTPUT
				EXEC @max_Id_Return =  dbo.QC_EGMS_SP_POPULATE_DYNAMIC_STAGING_TABLE_V2 @archival_table_name,@batch_size,@archival_config_id,@archive_date_column,@Global_Config_Condition,@primary_archival_column,@min_id,@max_id
					IF @max_Id_Return = 0
						BREAK;
					ELSE 
						SET @min_id = @max_Id_Return;
				
			BEGIN TRANSACTION
				EXEC dbo.QC_EGMS_SP_INSERT_ARCHIVAL_DATA_IN_BATCHES @archival_table_name,@batch_size,@archival_config_id,@archive_database_name,@linked_server_name,@Global_Can_Archive_Child_Tables
				EXEC dbo.QC_EGMS_SP_DELETE_ARCHIVAL_DATA_IN_BATCHES @archival_table_name,@batch_size,@archival_config_id,@Global_Can_Archive_Child_Tables
			COMMIT TRANSACTION
				
				END TRY 
				
				
				BEGIN CATCH
					IF @@TRANCOUNT > 0
					BEGIN
						ROLLBACK TRANSACTION
					END
				select @error_line = ERROR_LINE() , @error_message = ERROR_MESSAGE() , @error_procedure = ERROR_PROCEDURE()
				set @error_description = '[Error Message] - ' + @error_message + ' [Error Procedure]- ' + @error_procedure + ' [Error Line] -' + CAST(@error_line as varchar(10))
					---Error Log-- STARTS
					INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn 
					(
						QC_EGMS_ARCHIVAL_CONFIG_ID
						,ERROR_DESCRIPTION
						,ERROR_DATE
						)
					SELECT 
						@archival_config_id
						,@error_description
						,GETDATE()
					---Error Log-- ENDS
					
					EXEC dbo.QC_EGMS_SP_SEND_DB_MAIL @email_recipients,1 -- SEND ERROR EMAIL NOTIFICATION
					BREAK;
				END CATCH 
				--WAITFOR DELAY '00:01:00'; --Simulating long running process
				
			END -- While Loop end

			EXEC ('DROP TABLE IF EXISTS [tempdb].' +@archival_table_name+'_Staging')
			EXEC ('DROP TABLE IF EXISTS [tempdb].' +@archival_table_name)
		
		-- Update the flag to mark the completion of the strategy.
			UPDATE dbo.QC_EGMS_ARCHIVAL_CONFIG SET IS_RUNNING = 0 , MIN_ID = @min_id WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id 
			
			UPDATE dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG SET LAST_EXECUTION_DATE = GETDATE(),NEXT_EXECUTION_DATE = DATEADD(dd,@schedule_frequency_in_days,NEXT_EXECUTION_DATE)
			WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = @archival_config_id
			
		
			EXEC dbo.QC_EGMS_SP_SEND_DB_MAIL @email_recipients,2,@archival_config_id,@qc_egms_archival_execution_log_id_start -- SEND STRATEGY COMPLETION EMAIL NOTIFICATION 
		

		END -- IF Condition end
		FETCH NEXT FROM Archival_cursor INTO  
										@archival_config_id
										,@archival_table_name
										,@primary_archival_column
										,@batch_size
										,@linked_server_name
										,@archive_database_name
										,@archive_schema_name
										,@schedule_frequency_in_days
										,@email_recipients
										,@job_start_time
										,@job_end_time
										,@next_execution_date 
										,@archive_date_column
										,@min_id
										,@max_id
	END -- Cursor Loop end


IF CURSOR_STATUS('global','Archival_cursor')>=-1
	BEGIN
		CLOSE Archival_cursor  
		DEALLOCATE Archival_cursor 
	END

			
END -- Procedure End
GO


/*
The procedure returns a string containing the script to be executed for the tables that need to be created.
the script generated contains the schema of the source table (@fulltablename) except the identity column and foriegn key indexes.

Paramaters : @fulltablename - the name of the table along with its schema name
			 @DESTINATIONDB - the destination DB on which the script needs  to be executed
			 @script_Indexes -- By default its always false , however we can turn it to on for creating 
			 other non clustered and unique indexes and constraints
Returns : @TableScript - the final table script 
*/

CREATE PROCEDURE [dbo].[QC_EGMS_SP_GENERATE_DYNAMIC_TABLE]      
 @fulltablename Nvarchar(1000),     
 @DESTINATIONDB NVARCHAR(100),
 @script_Indexes bit = 0, -- default to always false unless otherwise specified    
 @TableScript VARCHAR(MAX)  OUTPUT      
AS      
BEGIN      
      
SET NOCOUNT ON;      
        
 declare @table varchar(100)      
 declare @schema varchar(100)      
 set @table= (select PARSENAME(@fulltablename,1))      
 set @schema= (select PARSENAME(@fulltablename,2))      
 declare @sql table( id int identity,s Nvarchar(max))      

   
-- create statement      
insert into  @sql(s) values ('USE '+ @DESTINATIONDB + '  CREATE  TABLE [' + @table + '] (')      
      
-- column list      
insert into @sql(s)      
select       
    '  ['+column_name+'] ' +     

	    data_type +   CASE when data_type='NTEXT' or data_type='TEXT' or data_type = 'XML' or data_type = 'IMAGE'  then '' 

		 WHEN data_type='NUMERIC' or data_type='FLOAT' or data_type = 'DECIMAL'  THEN
		+'('+cast(NUMERIC_PRECISION as varchar)  + ','+ cast(NUMERIC_SCALE as varchar) +')' ELSE 

	 coalesce( '('+ CASE WHEN cast(character_maximum_length as varchar) =-1 THEN 'MAX' ELSE cast(character_maximum_length as varchar) END+')','') end   +  ' ' + 

  --  data_type +   CASE when data_type='NTEXT' or data_type='TEXT' or data_type = 'XML' or data_type = 'IMAGE'  then '' else ''+
	 --coalesce( '('+ CASE WHEN cast(character_maximum_length as varchar) =-1 THEN 'MAX' ELSE cast(character_maximum_length as varchar) END+')','') end   +  ' ' +       
   
    ( case when IS_NULLABLE = 'No' then 'NOT ' else '' end ) + 'NULL ' +       
    coalesce('DEFAULT '+COLUMN_DEFAULT,'') + ','      
      
 from information_schema.columns where table_name = @table      
 order by ordinal_position      
      
-- primary key      
declare @pkname varchar(100)      
select @pkname = constraint_name from information_schema.table_constraints      
where table_name = @table and constraint_type='PRIMARY KEY'      
      
if ( @pkname is not null ) begin      
    insert into @sql(s) values('CONSTRAINT ' + @pkname +' PRIMARY KEY (')      
    insert into @sql(s)      
        select '   ['+COLUMN_NAME+'],' from information_schema.key_column_usage      
        where constraint_name = @pkname      
        order by ordinal_position      
    -- remove trailing comma      
    update @sql set s=left(s,len(s)-1) where id=@@identity      
    insert into @sql(s) values ('  )')      
end      
else begin      
    -- remove trailing comma      
    update @sql set s=left(s,len(s)-1) where id=@@identity      
end      
      
-- closing bracket      
insert into @sql(s) values( ')' )      
         
   If @script_Indexes = 1  -- Section Create Indexes and Constraints - STARTS
   BEGIN   
      
    --create other indexes      
    DECLARE @IndexId int, @IndexName nvarchar(255), @IsUnique bit, @IsUniqueConstraint bit, @FilterDefinition nvarchar(max)      
      
    DECLARE indexcursor CURSOR FOR      
    SELECT index_id, name, is_unique, is_unique_constraint, filter_definition FROM sys.indexes WHERE type = 2 and object_id = object_id('[' + @Schema + '].[' + @Table + ']')      
    OPEN indexcursor;      
    FETCH NEXT FROM indexcursor INTO @IndexId, @IndexName, @IsUnique, @IsUniqueConstraint, @FilterDefinition;      
    WHILE @@FETCH_STATUS = 0      
       BEGIN      
  
     
            DECLARE @Unique nvarchar(255)      
            SET @Unique = CASE WHEN @IsUnique = 1 THEN ' UNIQUE ' ELSE '' END      
      
            DECLARE @KeyColumns nvarchar(max), @IncludedColumns nvarchar(max)      
   SET @KeyColumns = ''      
            SET @IncludedColumns = ''      
      
            select @KeyColumns = @KeyColumns + '[' + c.name + '] ' + CASE WHEN is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END + ',' from sys.index_columns ic      
            inner join sys.columns c ON c.object_id = ic.object_id and c.column_id = ic.column_id      
            where index_id = @IndexId and ic.object_id = object_id('[' + @Schema + '].[' + @Table + ']') and key_ordinal > 0      
            order by index_column_id      
      
            select @IncludedColumns = @IncludedColumns + '[' + c.name + '],' from sys.index_columns ic      
            inner join sys.columns c ON c.object_id = ic.object_id and c.column_id = ic.column_id      
            where index_id = @IndexId and ic.object_id = object_id('[' + @Schema + '].[' + @Table + ']') and key_ordinal = 0      
            order by index_column_id      
      
            IF LEN(@KeyColumns) > 0      
                SET @KeyColumns = LEFT(@KeyColumns, LEN(@KeyColumns) - 1)      
      
            IF LEN(@IncludedColumns) > 0      
            BEGIN      
                SET @IncludedColumns = ' INCLUDE (' + LEFT(@IncludedColumns, LEN(@IncludedColumns) - 1) + ')'      
            END      
      
            IF @FilterDefinition IS NULL      
                SET @FilterDefinition = ''      
            ELSE      
                SET @FilterDefinition = 'WHERE ' + @FilterDefinition + ' '      
      
            if @IsUniqueConstraint = 0      
   insert into @sql(s) values(      
                'CREATE ' + @Unique + ' NONCLUSTERED INDEX [' + @IndexName + '] ON [' + @Schema + '].[' + @Table + '] (' + @KeyColumns + ')' + @IncludedColumns + @FilterDefinition)      
            ELSE      
                BEGIN      
                    SET @IndexName = REPLACE(@IndexName, @Table, @Table)      
     insert into @sql(s) values('ALTER TABLE [' + @Schema + '].[' + @Table + '] ADD  CONSTRAINT [' + @IndexName + '] UNIQUE NONCLUSTERED (' + @KeyColumns + ')');      
                END      
      
            FETCH NEXT FROM indexcursor INTO @IndexId, @IndexName, @IsUnique, @IsUniqueConstraint, @FilterDefinition;      
       END;      
    CLOSE indexcursor;      
    DEALLOCATE indexcursor;      
      
    --create constraints      
    DECLARE @ConstraintName nvarchar(max), @CheckClause nvarchar(max)      
    DECLARE constraintcursor CURSOR FOR      
        SELECT REPLACE(c.CONSTRAINT_NAME, @Table, @Table), CHECK_CLAUSE from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE t      
        INNER JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS c ON c.CONSTRAINT_SCHEMA = TABLE_SCHEMA AND c.CONSTRAINT_NAME = t.CONSTRAINT_NAME      
         WHERE TABLE_SCHEMA = @Schema AND TABLE_NAME = @Table      
    OPEN constraintcursor;      
    FETCH NEXT FROM constraintcursor INTO @ConstraintName, @CheckClause;      
    WHILE @@FETCH_STATUS = 0      
       BEGIN      
           insert into @sql(s) values('ALTER TABLE [' + @Schema + '].[' + @Table + '] WITH CHECK ADD  CONSTRAINT [' + @ConstraintName + '] CHECK ' + @CheckClause)      
          insert into @sql(s) values('ALTER TABLE [' + @Schema + '].[' + @Table + '] CHECK CONSTRAINT [' + @ConstraintName + ']')      
            FETCH NEXT FROM constraintcursor INTO @ConstraintName, @CheckClause;      
       END;      
    CLOSE constraintcursor;      
    DEALLOCATE constraintcursor;    
END -- Section Create Indexes and Constraints - ENDS
	  
select @TableScript =  CAST(COALESCE(@TableScript + ' ' + s, s) AS nvarchar(MAX))   From @sql      
select @TableScript =  replace(@TableScript, '''', '''''')
END
GO
/*  
The procedure creates the entire schema of a table along with its child dependencies (tables) given the Destination DB name.  
Should there be a linked server instance on which the Destination DB is present , the script will execute the script for each of the tables on   
the Linked server , however the script does not make sure if a linked server is already set up or not   
  
If the linked server is present in the configuration table and the linked server is not created, 
then the query will fail and the tables would not get created.  
  
EXEC QC_EGMS_SP_CHK_TBLCREATION   
select * from QC_EGMS_Archival_Config  
select * from QC_EGMS_ARCHIVAL_ERROR_LOG_Syn order by 1 desc  
update QC_EGMS_Archival_Config set Archive_database_name ='NEW2'  
parameters :@DESTINATIONDB - The name of the destination DB on which the script needs to be executed .  
         
Retruns : none  
*/  
CREATE PROC dbo.QC_EGMS_SP_CHK_TBLCREATION   
AS  
BEGIN  
SET NOCOUNT ON   
BEGIN TRY  

if object_id('tempdb..#TMPPARENT') is not null  
drop table #TMPPARENT;  
create table  #TMPPARENT  (ID INT IDENTITY(1,1),tablename varchar(256),Linked_Server_Name varchar(100),ARCHIVE_DATABASE_NAME varchar(100));  
INSERT INTO #TMPPARENT SELECT  DISTINCT ARCHIVAL_TABLE_NAME ,LINKED_SERVER_NAME,ARCHIVE_DATABASE_NAME from dbo.QC_EGMS_ARCHIVAL_CONFIG  where is_enabled = 1  and is_approved = 1
and is_runnable = 1
if object_id('tempdb..#tmp') is not null  
drop table #tmp;  
create table  #tmp  (id int IDENTITY(1,1), tablename varchar(256), lvl int, ParentTable varchar(256));  
  
DECLARE @MAXCOUNT INT, @COUNTS INT , @formatted_Linked_Server_Name varchar(200)
Declare @NAMEOFTBL NVARCHAR(1000), @sqlstmt NVARCHAR (max),@chktable_Name NVARCHAR(1000),@full_table_Name NVARCHAR(1000)
Declare @tablescript VARCHAR(max),@linked_server_name NVARCHAR(100),@DESTINATIONDB NVARCHAR(100),@Count int, @Error_Description varchar(max)
  
DECLARE @EXISTSCOUNT INT=0  
  
SET @Counts = 1  
SELECT @MAXCOUNT = COUNT(*) FROM #TMPPARENT  
  
WHILE (@COUNTS <= @MAXCOUNT)  
BEGIN  
SET @NAMEOFTBL='';  
SELECT @NAMEOFTBL = TABLENAME, @Linked_Server_Name = Linked_Server_Name , @DESTINATIONDB =ARCHIVE_DATABASE_NAME FROM  #TMPPARENT  WHERE ID = @COUNTS  
set @formatted_Linked_Server_Name = (Select case when @linked_server_name IS NOT NULL AND LEN(@linked_server_name)> 1 THEN '['+@linked_server_name +']'+'.' ELSE NULL END)  
TRUNCATE TABLE #tmp  
  
INSERT INTO #tmp   
EXEC dbo.QC_EGMS_SP_SEARCH_FK @table=@NAMEOFTBL, @debug=0;  

  
DECLARE @MAXID INT, @Counter INT  
  
SET @COUNTER = 1  
SELECT @MAXID = COUNT(*) FROM #tmp  
  
WHILE (@COUNTER <= @MAXID)  
BEGIN  
--    --DO THE PROCESSING HERE   
set @chktable_Name=''  


SELECT @chktable_Name =	PARSENAME(TEMP.tablename,1) , @full_table_Name = TEMP.tablename	FROM 
#tmp AS TEMP WHERE ID = @COUNTER

SET @sqlstmt='SELECT @CNT=COUNT(1) FROM ' + coalesce(@formatted_Linked_Server_Name,'')+@DESTINATIONDB +'.sys.objects WHERE Name = ''' +@chktable_Name +''' AND type in (N''U'')'  




EXECUTE sp_executesql @sqlstmt  ,N'@cnt INT OUTPUT'  ,@cnt = @EXISTSCOUNT OUTPUT  
IF  @EXISTSCOUNT=0   -- If the table does not exists in Archive DB then create it 
BEGIN  
  
SET @tablescript = ''  
EXEC dbo.QC_EGMS_SP_GENERATE_DYNAMIC_TABLE @full_table_Name,@DESTINATIONDB, 1, @tablescript output   


IF @linked_server_name<>''   
BEGIN   
	SET   @tablescript = 'Exec (''' + @tablescript +  CASE when @linked_server_name is null then ''')' else ''') at ' + '['+ @linked_server_name + ']'  end   
END  
ELSE
BEGIN
	SET   @tablescript = 'Exec (''' + @tablescript +''')' 
END
 
EXEC(@tablescript);    
END
	
	EXEC dbo.QC_EGMS_SYNC_ARCHIVING_DB_SCHEMA_CHANGES @full_table_Name, @DESTINATIONDB , @linked_server_name
	 


SET @COUNTER = @COUNTER + 1  
END  
  
SET @COUNTS = @COUNTS + 1  

END  

END TRY  
BEGIN CATCH  


SET @Error_Description = ERROR_MESSAGE()
INSERT INTO QC_EGMS_ARCHIVAL_ERROR_LOG_Syn(ERROR_DESCRIPTION,ERROR_DATE) VALUES  
('Error Procedure - QC_EGMS_SP_CHK_TBLCREATION ' + 'Error Message -'  + @Error_Description,GETDATE())  

END CATCH  
END  
GO

CREATE PROCEDURE dbo.QC_EGMS_SP_RECONCILE_NEXT_EXECUTION_DATE
AS
BEGIN
WHILE EXISTS 
(
SELECT 1 
	FROM 
		dbo.QC_EGMS_ARCHIVAL_CONFIG A WITH (NOLOCK)  
	JOIN 
		dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B WITH (NOLOCK)  
	ON 
		A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID
WHERE 
	A.IS_ENABLED = 1 AND B.NEXT_EXECUTION_DATE < CAST(GETDATE() AS DATE)
	)
BEGIN
	
	UPDATE 
		B 
	SET 
		B.NEXT_EXECUTION_DATE = DATEADD(dd,A.SCHEDULE_FREQUENCY_IN_DAYS,B.NEXT_EXECUTION_DATE)
	FROM
			dbo.QC_EGMS_ARCHIVAL_CONFIG A 
		 JOIN 
			dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B  
		ON 
			A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID 
	WHERE
		B.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG_ID IN 
		(
		SELECT 
			B.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG_ID 
		FROM 
			dbo.QC_EGMS_ARCHIVAL_CONFIG A WITH (NOLOCK)  
		JOIN 
			dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B WITH (NOLOCK)  
		ON 
			A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID
		WHERE 
			A.IS_ENABLED = 1 AND B.NEXT_EXECUTION_DATE < CAST(GETDATE() AS DATE)
		)
	
END-- WHILE LOOP END
END
GO

-- =======================================================================================================================================
/* Description :
     This procedure is used to check the status of main archiving job "RUN_ARCHIVING"
	 The job is used to start the Archiving job based on the Time and Date configuration. 
	 		
Paramaters : None 
Return : None.
*/
-- ==========================================================================================================================================
CREATE PROCEDURE dbo.QC_EGMS_SP_MANAGE_JOB_SCHEDULE
AS
BEGIN
DECLARE @job_name VARCHAR(100)='RUN_ARCHIVING'
SET NOCOUNT ON 
	--Exit from the procedure if the job is already running
	 IF (SELECT COUNT(1) FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WITH (NOLOCK) WHERE IS_RUNNING =1) > 0
	 BEGIN
		RETURN;
	 END

-- If there is any stratgey that needs to run as per the configured schedule START_TIME and the job is not running as yet,then 
--start the job
IF EXISTS (
SELECT  1 FROM 
	dbo.QC_EGMS_ARCHIVAL_CONFIG A WITH (NOLOCK)  
JOIN 
	dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B WITH (NOLOCK)  on a.QC_EGMS_ARCHIVAL_CONFIG_ID = b.QC_EGMS_ARCHIVAL_CONFIG_ID
WHERE  
	CONVERT(VARCHAR(5),GETDATE(),108) BETWEEN A.JOB_START_TIME AND  A.JOB_END_TIME AND B.NEXT_EXECUTION_DATE = CAST(GETDATE() AS DATE)
AND
	 A.IS_RUNNING = 0 AND A.IS_ENABLED = 1)
BEGIN
	EXEC msdb.dbo.sp_start_job @job_name -- Start the job 
END
END --Procedure End
GO

--EXEC QC_EGMS_SP_FK_ENABLE_DISABLE 'ENABLE', 'dbo','Qwikcilver_Automation_Archive','ENGGDEVDB'  
--EXEC QC_EGMS_SP_FK_ENABLE_DISABLE 'DISABLE', 'dbo','Qwikcilver_Automation_Archive','ENGGDEVDB'  
--- Enable, Disable, Drop and Recreate FKs based on Primary Key table    
---- Written 2018-09-26  
CREATE PROCEDURE QC_EGMS_SP_FK_ENABLE_DISABLE  
(  
  @operation VARCHAR(10)   
 ,@schemaName sysname    
 ,@DESTINATIONDATABASE VARCHAR(100)  
 ,@linked_server_name VARCHAR(100)  
 )  
 AS  
BEGIN
SET NOCOUNT ON    
DECLARE @cmd NVARCHAR(MAX)   ='', @cmd_new NVARCHAR(MAX)=''
  
IF OBJECT_ID('tempdb..#ENABLE_DISABLE_FK_Temp_TBL') IS NOT NULL  
    DROP TABLE #ENABLE_DISABLE_FK_Temp_TBL  
set @linked_server_name = (Select case when @linked_server_name IS NOT NULL AND LEN(@linked_server_name)> 1 THEN '['+@linked_server_name +']'+'.' ELSE NULL END)  
  
  
  
  
  
CREATE TABLE #ENABLE_DISABLE_FK_Temp_TBL  
(  
    FK_name Varchar(200),   
     FK_OBJECT_ID BIGINT,   
    IS_DISABLED BIT,   
    IS_NOT_FOR_REPLICATION BIT ,   
    delete_referential_action BIT,  
    update_referential_action BIT,  
    Fk_table_name VARCHAR(200),   
    Fk_table_schema VARCHAR(200),   
    Pk_table_name VARCHAR(200),  
 Pk_table_schema VARCHAR(200)  
)  
  
   Declare @sqlcmd NVARCHAR(MAX)  
   SET @sqlcmd ='SELECT  Fk.name,    
           Fk.OBJECT_ID,     
           Fk.is_disabled,     
           Fk.is_not_for_replication,     
           Fk.delete_referential_action,     
           Fk.update_referential_action,    
      (select name FROM '+coalesce(@linked_server_name,'')+ @DESTINATIONDATABASE + '.sys.objects WHERE  object_id =Fk.parent_object_id) as Fk_table_name,   
           schema_name(Fk.schema_id) AS Fk_table_schema,     
           TbR.name AS Pk_table_name,     
           schema_name(TbR.schema_id) Pk_table_schema    
   FROM  '  
    +coalesce(@linked_server_name,'') + @DESTINATIONDATABASE +'.sys.foreign_keys Fk LEFT OUTER JOIN '    
      +coalesce(@linked_server_name,'')   + @DESTINATIONDATABASE +'.sys.tables TbR ON TbR.OBJECT_ID = Fk.referenced_object_id --inner join     
   WHERE    schema_name(TbR.schema_id) =''' + @schemaName   + ''''  
  
--select  @sqlcmd  
insert INTO #ENABLE_DISABLE_FK_Temp_TBL  
EXEC (@SQLCMD)  

  
  
  
DECLARE     
   @FK_NAME sysname,    
   @FK_OBJECTID INT,    
   @FK_DISABLED INT,    
   @FK_NOT_FOR_REPLICATION INT,    
   @DELETE_RULE smallint,       
   @UPDATE_RULE smallint,       
   @FKTABLE_NAME sysname,    
   @FKTABLE_OWNER sysname,    
   @PKTABLE_NAME sysname,    
   @PKTABLE_OWNER sysname,    
   @FKCOLUMN_NAME sysname,    
   @PKCOLUMN_NAME sysname,    
   @CONSTRAINT_COLID INT    
  
  
DECLARE cursor_fkeys CURSOR FOR     
   SELECT  FK_name,    
          FK_OBJECT_ID,     
           is_disabled,     
          is_not_for_replication,     
           delete_referential_action,     
           update_referential_action,     
            Fk_table_name,     
   Fk_table_schema,     
           Pk_table_name,     
           Pk_table_schema    
  
   FROM    #ENABLE_DISABLE_FK_Temp_TBL  
  
OPEN cursor_fkeys    
  
FETCH NEXT FROM cursor_fkeys     
   INTO @FK_NAME,@FK_OBJECTID,    
       @FK_DISABLED,    
       @FK_NOT_FOR_REPLICATION,    
       @DELETE_RULE,       
       @UPDATE_RULE,       
       @FKTABLE_NAME,    
       @FKTABLE_OWNER,    
       @PKTABLE_NAME,    
       @PKTABLE_OWNER    
  
    --select * from #ENABLE_DISABLE_FK_Temp_TBL  
  
WHILE @@FETCH_STATUS = 0    
BEGIN     
  
   -- create statement for enabling FK    
   IF @operation = 'ENABLE'     
   BEGIN    
       SET @cmd = 'ALTER TABLE '+'['+@DESTINATIONDATABASE + '].['++ @FKTABLE_OWNER + '].[' + @FKTABLE_NAME     
           + ']  CHECK CONSTRAINT [' + @FK_NAME + ']'  
	
     --PRINT @cmd    
   END    
  
   -- create statement for disabling FK    
   IF @operation = 'DISABLE'    
   BEGIN     
  SET @cmd = 'ALTER TABLE '+'['+@DESTINATIONDATABASE + '].['++ @FKTABLE_OWNER + '].[' + @FKTABLE_NAME     
           + ']  NOCHECK CONSTRAINT [' + @FK_NAME + ']'    
  
      --PRINT @cmd    
	 
	 
   END    
  
   SET @cmd_new = @cmd_new + @cmd + CHAR(13)
	
  
   FETCH NEXT FROM    cursor_fkeys     
      INTO @FK_NAME,@FK_OBJECTID,    
           @FK_DISABLED,    
           @FK_NOT_FOR_REPLICATION,    
           @DELETE_RULE,       
           @UPDATE_RULE,       
           @FKTABLE_NAME,    
           @FKTABLE_OWNER,    
           @PKTABLE_NAME,    
           @PKTABLE_OWNER    

		   
END   -- CURSOR END

if @cmd_new = ''
return ;
	
if @linked_server_name IS NOT NULL   
	begin   
	 --SET   @cmd = 'Exec (''' + @cmd +  CASE when @linked_server_name is null then ''')' else ''') at ' +  REPLACE(@linked_server_name,'.','')  end 
	 SET   @cmd_new = 'Exec (''' + @cmd_new +  CASE when @linked_server_name is null then ''')' else ''') at ' +  REPLACE(@linked_server_name,'.','')  end     
	end  
	
	--EXEC( @cmd )  
	--PRINT @cmd   
	EXEC(@cmd_new)
	

CLOSE cursor_fkeys     
DEALLOCATE cursor_fkeys  
END
GO

   
CREATE PROCEDURE dbo.QC_EGMS_SP_MERGE_MASTER_LOOKUP_DATA    
AS     
BEGIN    
    
SET NOCOUNT ON;    
 DECLARE  @SourceServer NVARCHAR(256),    
 @SourceDatabase  NVARCHAR(256),    
 @SourceSchema NVARCHAR(200),    
 @SourceTable NVARCHAR(256),    
 @SrcType NVarchar ='SQL',    
 @TargetServer NVARCHAR(256),    
 @TargetDatabase NVARCHAR(256),    
 @Targetschema NVARCHAR(200),    
 @TargetTable NVARCHAR(256)    
   
    
    
Declare @sqlstmnt Nvarchar(max)    
DECLARE Master_lookup_cursor  CURSOR FOR    
 --@link_server, @SourceDatabase,@SourceSchema,@SourceTable,@TargetDatabase,@TargetDatabase,@TargetTable,@IsActive          
SELECT link_server, srcDatabase,SrcSchema,SrcTable,TargetDatabase,TargetSchema,TargetTable,Targetserver FROM QC_EGMS_Master_Lookup_Config where isactive=1    
    
    
OPEN Master_lookup_cursor        
      
FETCH NEXT FROM Master_lookup_cursor         
INTO @SourceServer, @SourceDatabase,@SourceSchema,@SourceTable,@TargetDatabase,@Targetschema,@TargetTable ,@TargetServer       
      
 --select @SourceServer, @SourceDatabase,@SourceSchema,@SourceTable,@TargetDatabase,@Targetschema,@TargetTable,@TargetServer    
 --select @SourceTable as sourceTable , @TargetTable as TargetTable     
    
WHILE @@FETCH_STATUS = 0        
BEGIN      
     
  SET @sqlstmnt = '';    
     
 SET @sqlstmnt = 'exec QC_EGMS_SP_MERGE_MASTER_LOOKUP @SourceServer='+ coalesce(''''+@SourceServer +'''','NULL') + ' ,     
  @SourceDatabase= ''' + @SourceDatabase +''' ,     
  @SourceSchema= ''' + @SourceSchema + ''',    
  @SourceTable= ''' + @SourceTable + ''',    
  @TargetServer= ' + coalesce(''''+@TargetServer+'''','NULL') + ',    
  @TargetDatabase= ''' + @TargetDatabase + ''',    
  @TargetSchema=''' + @Targetschema+ ''',    
  @TargetTable= ''' +@TargetTable+ ''''    
   
    
BEGIN TRY    
--PRINT @sqlstmnt
 EXEC (@sqlstmnt)    
END TRY    
BEGIN CATCH    
INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn     
 (    
  ERROR_DESCRIPTION    
  ,ERROR_DATE    
  )    
 SELECT     
  'Master Merge Look Up data failure : ' + ERROR_MESSAGE()     
  ,GETDATE()    
         
END CATCH    
          
FETCH NEXT FROM Master_lookup_cursor         
INTO @SourceServer, @SourceDatabase,@SourceSchema,@SourceTable,@TargetDatabase,@Targetschema,@TargetTable,@TargetServer        
END      
       
CLOSE Master_lookup_cursor;        
DEALLOCATE Master_lookup_cursor;     
END    
GO


CREATE PROCEDURE [dbo].[QC_EGMS_SP_MERGE_MASTER_LOOKUP] (      
 @SourceServer varchar(100),      
 @SourceDatabase varchar(100),      
 @SourceSchema varchar(100),      
 @SourceTable varchar(100),      
 @TargetServer varchar(100),      
 @TargetDatabase varchar(100),      
 @TargetSchema varchar(100),      
 @TargetTable varchar(100)     
      
 )      
AS      
BEGIN      
SET NOCOUNT ON      
      
      
DECLARE @MergeSQLStr varchar(max),       
 @TempSQLStr varchar(max),       
 @Str varchar(500),       
 @Counter int,      
 @PK_Available int=0   ,    
 @HasIdentityInsert bit =0,  
 @IdentityInsertON varchar (1000),  
 @IdentityInsertOFF varchar (1000)  
       
 /*--      
 Created table to hold the source column and primary key column      
 --*/      
       
CREATE TABLE #TblSourceColumns (SelectedColumn varchar(100), PrimaryColumn varchar(100))      
CREATE TABLE #TblSourcePrimaryKey (PrimaryColumn varchar(100))  
CREATE TABLE #HASIDENTITYINSERT (HASIDENTITYINSERT INT)      
   
      
 /*--      
 If  value of database and table is not supplied  send a error and come out from the execution      
 --*/      
      
IF @SourceDatabase is null or      
 @SourceTable is null       
 BEGIN      
 RAISERROR('Invalid input parameters',16,1)      
 RETURN -1      
 END      
      
      
  /*--      
 Suppling the source and target server  if it is null then it will take the default server      
 --*/      
set @SourceServer = (Select case when replace(@SourceServer,'''','') IS NOT NULL AND LEN(@SourceServer)> 1 THEN '['+@SourceServer +']'+'.' ELSE NULL END)        
set @TargetServer = (Select case when replace(@TargetServer,'''','') IS NOT NULL AND LEN(@TargetServer)> 1 THEN '['+@TargetServer +']'+'.' ELSE NULL END)        
      
/*--      
If the Target is not a input then considering the Source as target table  and dbo as a default schema.       
--*/      
IF @TargetTable IS NULL SELECT @TargetTable = @SourceTable      
IF @TargetSchema IS NULL SELECT @TargetSchema = 'dbo'      
IF @TargetDatabase IS NULL SELECT @TargetDatabase = DB_NAME()      
IF @SourceSchema IS NULL SELECT @SourceSchema = 'dbo'      
      
/*-------------------------------      
 step 1 Merge statement started from here      
*/-----------------------------------      
   
  
  
  
  
  
SELECT @Str = 'Starting MERGE from '+@SourceDatabase+'.'+@SourceSchema+'.'+@SourceTable+' to '      
 + @TargetDatabase+'.'+@TargetSchema+'.'+@TargetTable+'.'      
     
    
      
 /*-------------------------------      
 step 2 fetch the  column from the information schema of the source table and insert into temporary table       
*/-----------------------------------      
      
      
SELECT @TempSQLStr = ' select COLUMN_NAME as SelectedColumn, COLUMN_NAME as PrimaryColumn '+      
 ' from '+COALESCE(@SourceServer,'')+'['+@SourceDatabase+'].INFORMATION_SCHEMA.COLUMNS '+      
 ' where TABLE_NAME = '''+@SourceTable+''''+      
 ' and TABLE_SCHEMA = '''+@SourceSchema+''''      
      
  
 /*-------------------------------      
 Inserting the source column to temporary table to hold the column value      
*/-----------------------------------      
      
      
INSERT INTO #TblSourceColumns exec(@TempSQLStr)      
      
 /*-------------------------------      
 if the column doesn't exist for the provided table then come out of execution      
*/-----------------------------------      
      
IF NOT EXISTS (SELECT 1 FROM #TblSourceColumns)      
BEGIN      
SELECT @Str = 'No column information found for table '+@SourceTable+'. Exiting...'      
--PRINT @Str      
SELECT @Str = 'usp_merge: '+@Str      
RAISERROR(@Str,16,1)      
RETURN -1      
END      
       
 /*-------------------------------      
 Step 3 : Get the primary column of the table for comparing  and if doesn't have primary key the at source else at destination       
*/-----------------------------------      
      
      
SELECT @TempSQLStr = ' select b.COLUMN_NAME as PrimaryColumn from ['+@SourceDatabase+'].information_schema.TABLE_CONSTRAINTS a '+      
 ' JOIN '+COALESCE(@SourceServer,'')+'['+@SourceDatabase+'].information_schema.CONSTRAINT_COLUMN_USAGE b on a.CONSTRAINT_NAME=b.CONSTRAINT_NAME '+      
 ' where a.CONSTRAINT_SCHEMA='''+@SourceSchema+''' and a.TABLE_NAME = '''+@SourceTable+''''+      
 ' and a.CONSTRAINT_TYPE = ''PRIMARY KEY'''      
      
INSERT INTO #TblSourcePrimaryKey exec(@TempSQLStr)      
      
 IF NOT EXISTS(SELECT 1 from #TblSourcePrimaryKey)       
 BEGIN      
 SELECT @TempSQLStr = ' select b.COLUMN_NAME as PrimaryColumn from '+COALESCE(@TargetServer,'')+'['+@TargetDatabase+'].information_schema.TABLE_CONSTRAINTS a '+      
 ' JOIN '+COALESCE(@TargetServer,'')+'['+@TargetDatabase+'].information_schema.CONSTRAINT_COLUMN_USAGE b on a.CONSTRAINT_NAME=b.CONSTRAINT_NAME '+      
 ' where a.CONSTRAINT_SCHEMA='''+@TargetSchema+''' and a.TABLE_NAME = '''+@TargetTable+''''+      
 ' and a.CONSTRAINT_TYPE = ''PRIMARY KEY'''      
       
 INSERT INTO #TblSourcePrimaryKey exec(@TempSQLStr)      
 /*-------------------------------      
 Step 4 : If it doesn't exists at source as well as destination need to insert from the temporary sourcecoulmn  table       
*/-----------------------------------      
      
       
 IF NOT EXISTS(SELECT 1 from #TblSourcePrimaryKey)       
 BEGIN      
       
 INSERT INTO #TblSourcePrimaryKey SELECT PrimaryColumn FROM #TblSourceColumns      
 SELECT @PK_Available = 1       
 END      
END      
 /*-------------------------------      
 Step 5 : dynamically merge statement starts from  here      
*/-----------------------------------      
  
--DECLARE @SQL nvarchar(max) = N'SELECT   1  from ' + @TargetServer + @TargetDatabase + '.SYS.syscolumns where id = Object_ID(''' + @TargetDatabase+'.'+@TargetSchema+'.'+@TargetTable + ''') and colstat & 1 = 1'  
--DECLARE @SQL nvarchar(max) = N'SELECT   1  from ' + @TargetServer + @TargetDatabase + '.SYS.syscolumns where id = Object_ID(''' +@TargetTable + ''') and colstat & 1 = 1'  

DECLARE @SQL nvarchar(max) = N'SELECT 1 FROM '+ISNULL(@TargetServer,'') +@TargetDatabase+   '.INFORMATION_SCHEMA.TABLES tables 
WHERE OBJECTPROPERTY(OBJECT_ID(tables.TABLE_SCHEMA + ''.'' + tables.TABLE_NAME), 
	''TableHasIdentity'') = 1
AND tables.TABLE_TYPE = ''BASE TABLE''
AND TABLE_NAME ='''+ @TargetTable+''''
 

INSERT #HASIDENTITYINSERT  
EXEC (@SQL)   
SET @HasIdentityInsert =(SELECT  HASIDENTITYINSERT FROM #HASIDENTITYINSERT)  
  
 SET @IdentityInsertON = 'SET IDENTITY_INSERT ' +  @TargetDatabase+'.'+@TargetSchema+'.'+@TargetTable +' ON;'    
 SET @IdentityInsertOFF = 'SET IDENTITY_INSERT ' +  @TargetDatabase+'.'+@TargetSchema+'.'+@TargetTable +' OFF;'   
  
--Debug
--SELECT @SQL AS insertIdentitySQL
--SELECT @HasIdentityInsert AS HasIdentityInsert  
--Debug
 SELECT @MergeSQLStr = CASE WHEN  @HasIdentityInsert = 1 THEN @IdentityInsertON ELSE '' END   
      
SELECT @MergeSQLStr =   @MergeSQLStr + CHAR(13)+ ' MERGE '+COALESCE(@TargetServer,'')+ '['+@TargetDatabase+'].['+@TargetSchema+'].['+@TargetTable+'] T USING ('      
      
SELECT @TempSQLStr =''      
      
SELECT @TempSQLStr = @TempSQLStr + SelectedColumn + ',' from #TblSourceColumns      
select @TempSQLStr = substring(@TempSQLStr,1,len(@TempSQLStr)-1)      
select @TempSQLStr = replace(@TempSQLStr,'"','''''')      
select @TempSQLStr = ' select '+@TempSQLStr+' from '+COALESCE(@SourceServer,'')+'['+@SourceDatabase+'].['+@SourceSchema+'].['+@SourceTable+'] '+') S '      
      
SELECT @MergeSQLStr=@MergeSQLStr+@TempSQLStr      
       
      
IF EXISTS(Select 1 from #TblSourcePrimaryKey)      
BEGIN      
SELECT @TempSQLStr = ' on '      
SELECT @TempSQLStr = @TempSQLStr + 'S.'+PrimaryColumn+' = T.'+PrimaryColumn+' and ' from #TblSourcePrimaryKey      
SELECT @TempSQLStr = SUBSTRING(@TempSQLStr,1,len(@TempSQLStr)-4)      
SELECT @MergeSQLStr = @MergeSQLStr+@TempSQLStr      
END      
      
IF @PK_Available = 0      
BEGIN      
SELECT @TempSQLStr = ' WHEN MATCHED AND '      
SELECT @TempSQLStr = @TempSQLStr + 'S.'+cols.PrimaryColumn+' <> T.'+cols.PrimaryColumn+' or '       
 from #TblSourceColumns cols      
 left outer join #TblSourcePrimaryKey PK on cols.PrimaryColumn=PK.PrimaryColumn      
 where PK.PrimaryColumn IS NULL      
SELECT @TempSQLStr = SUBSTRING(@TempSQLStr,1,len(@TempSQLStr)-3)      
SELECT @TempSQLStr = @TempSQLStr+' THEN UPDATE SET '      
SELECT @TempSQLStr = @TempSQLStr + 'T.'+cols.PrimaryColumn+' = S.'+cols.PrimaryColumn+','       
 from #TblSourceColumns cols      
 left outer join #TblSourcePrimaryKey PK on cols.PrimaryColumn=PK.PrimaryColumn      
 where PK.PrimaryColumn IS NULL      
SELECT @TempSQLStr = SUBSTRING(@TempSQLStr,1,len(@TempSQLStr)-1)      
SELECT @MergeSQLStr = @MergeSQLStr+@TempSQLStr      
END      
      
SELECT @TempSQLStr = ' WHEN NOT MATCHED BY TARGET THEN INSERT ('      
SELECT @TempSQLStr = @TempSQLStr+PrimaryColumn+',' from #TblSourceColumns      
SELECT @TempSQLStr = SUBSTRING(@TempSQLStr,1,len(@TempSQLStr)-1)      
SELECT @TempSQLStr = @TempSQLStr+') VALUES ('      
SELECT @TempSQLStr = @TempSQLStr+PrimaryColumn+',' from #TblSourceColumns      
SELECT @TempSQLStr = SUBSTRING(@TempSQLStr,1,len(@TempSQLStr)-1)      
SELECT @TempSQLStr = @TempSQLStr+') '      
SELECT @MergeSQLStr = @MergeSQLStr+@TempSQLStr      
       
      
SELECT @MergeSQLStr = @MergeSQLStr+' WHEN NOT MATCHED BY SOURCE   THEN DELETE '    
      
      
 /*      
 Print the Output result      
 */      
SELECT @TempSQLStr=' OUTPUT $Action,'      
SELECT @TempSQLStr=@TempSQLStr+'INSERTED.'+PrimaryColumn+' AS ['+PrimaryColumn+' Inserted_and_Updated],' from #TblSourcePrimaryKey      
SELECT @TempSQLStr=@TempSQLStr+'DELETED.' +PrimaryColumn+' AS ['+PrimaryColumn+' Deleted],' from #TblSourcePrimaryKey      
SELECT @TempSQLStr = SUBSTRING(@TempSQLStr,1,len(@TempSQLStr)-1)      
SELECT @MergeSQLStr = @MergeSQLStr + @TempSQLStr     
   
      
/*      
 Merge statement append the semicolon at end       
 */      
      
SELECT @MergeSQLStr=@MergeSQLStr+';'      
 SELECT @MergeSQLStr = @MergeSQLStr + CHAR (13) +  CASE WHEN  @HasIdentityInsert = 1 THEN @IdentityInsertOFF ELSE '' END   
      
Declare @Final_Execution_Sql NVARCHAR(MAX)=''

IF @TargetServer IS NOT NULL AND LEN(@TargetServer) > 0
BEGIN
	SET @Final_Execution_Sql = 'EXEC ('''+@MergeSQLStr+''') AT ' + REPLACE(@TargetServer,'.','') 
	--PRINT @Final_Execution_Sql
	EXEC (@Final_Execution_Sql)
END
ELSE 
BEGIN
	EXEC (@MergeSQLStr)  
END 
--PRINT @MergeSQLStr      




IF (@@ERROR <> 0)      
 BEGIN      
 RAISERROR('QC_EGMS_SP_MERGE_MASTER_LOOKUP: SQL execution failed',16,1)      
 RETURN -1      
 END      
      
DROP TABLE #TblSourceColumns      
DROP TABLE #TblSourcePrimaryKey      
RETURN 0      
       
END     
GO


CREATE PROCEDURE dbo.QC_EGMS_SP_STOP_ARCHIVING_JOB
AS
BEGIN
DECLARE @email_recipients VARCHAR(MAX),@qc_egms_archival_execution_log_id BIGINT , @archival_config_id INT 
SET @qc_egms_archival_execution_log_id = (select qc_egms_archival_execution_log_id FROM  QC_EGMS_MAX_ARCHIVAL_EXECUTION_LOG_ID)
SELECT @email_recipients =  EMAIL_RECIPIENTS , @archival_config_id = QC_EGMS_ARCHIVAL_CONFIG_ID FROM dbo.QC_EGMS_ARCHIVAL_CONFIG WHERE IS_RUNNING = 1 

EXEC msdb.dbo.sp_update_job @job_name='MANAGE_JOB_SCHEDULE',@enabled = 0 -- Disable the schedule 
--Check to see if the job is running , if yes stop the job
IF  EXISTS(     
        select 1 
        from msdb.dbo.sysjobs_view job  
        inner join msdb.dbo.sysjobactivity activity on job.job_id = activity.job_id 
        where  
            activity.run_Requested_date is not null  
        and activity.stop_execution_date is null  
        and job.name = 'RUN_ARCHIVING' 
        )
BEGIN
	EXEC msdb.dbo.sp_stop_job 'RUN_ARCHIVING' -- STOP THE JOB 
END
UPDATE	--set the last execution date as today's date for the strategy that was running when the force stop was requested
	B 
SET 
	B.LAST_EXECUTION_DATE =  CAST(GETDATE() AS DATE)
FROM 
	dbo.QC_EGMS_ARCHIVAL_CONFIG A 
JOIN 
	dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B 
ON  
	A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID 
WHERE 
	A.IS_RUNNING = 1 

UPDATE dbo.QC_EGMS_ARCHIVAL_CONFIG SET IS_RUNNING = 0 WHERE IS_RUNNING = 1 -- SET THE FLAG "IS_RUNNING TO 0 "

UPDATE	--set the next execution day to the next schedule for each of the scheduled stratagies
	B 
SET 
	B.NEXT_EXECUTION_DATE =  DATEADD(DD,A.SCHEDULE_FREQUENCY_IN_DAYS,B.NEXT_EXECUTION_DATE)
FROM 
	dbo.QC_EGMS_ARCHIVAL_CONFIG A 
JOIN 
	dbo.QC_EGMS_ARCHIVAL_SCHEDULE_CONFIG B 
ON  
	A.QC_EGMS_ARCHIVAL_CONFIG_ID = B.QC_EGMS_ARCHIVAL_CONFIG_ID 
WHERE 
	A.IS_ENABLED = 1 

EXEC msdb.dbo.sp_update_job @job_name='MANAGE_JOB_SCHEDULE',@enabled = 1 -- Enable the schedule back again
EXEC dbo.QC_EGMS_SP_SEND_DB_MAIL @email_recipients,2,@archival_config_id,@qc_egms_archival_execution_log_id

--TRUNCATE TABLE dbo.QC_EGMS_MAX_ARCHIVAL_EXECUTION_LOG_ID
END
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================
/* Description :
      Used to check if indexes are present on the forieng keys for a given table and all its dependecies.
	  Will return 1 if there  is none else will return 0
		 		
Paramaters : None 
Return Type : Return code 1 or 0 

*/
-- ==========================================================================================================================================
CREATE PROCEDURE dbo.QC_EGMS_SP_MISSING_INDEX_FOREIGN_KEY(@archival_table_name varchar(100),@archival_config_id int)
AS
BEGIN

declare @i int = 0,@number_of_records int = 0,@crlf CHAR(2) = CHAR(0x0D) + CHAR(0x0A),@error_description varchar(max) = ''
,@returnCode int = 0,@Child_table varchar(200),@Parent_table varchar(200),@foreign_key_name varchar(200),@column_name varchar(200)

SET @crlf = CHAR(13) + CHAR(10)


if object_id('tempdb..#tmp') is not null
drop table #tmp;
create table  #tmp  (id int identity(1,1), tablename varchar(256), lvl int, ParentTable varchar(256));
create table #tmpIndex(id int identity(1,1),Child_table varchar(200),Parent_table varchar(200),foreign_key_name varchar(200),column_name varchar(200))
insert into #tmp 
exec dbo.QC_EGMS_SP_SEARCH_FK @table=@archival_table_name, @debug=0;


INSERT INTO dbo.#tmpIndex
select t.tablename as Child_Table,t.ParentTable as Parent_Table, fk.name as foreignkey_name,c.name as column_name 
from #tmp t 
inner join sys.foreign_keys fk on object_id(t.tablename) = fk.parent_object_id and object_id(t.ParentTable)= fk.referenced_object_id
inner join sys.foreign_key_columns fkc on fkc.constraint_object_id = fk.object_id
 inner join sys.columns c on c.column_id= fkc.parent_column_id and c.object_id = fk.parent_object_id 
 --left join sys.indexes i on i.object_id = fk.parent_object_id
 left join  sys.index_columns ic on ic.object_id= fk.parent_object_id  and ic.column_id = c.column_id
 Where ic.object_id is null

 SET @number_of_records = (select count(1) from #tmpIndex)

WHILE (@i<@number_of_records)
BEGIN
	SET @i=@i+1;
	SELECT @Child_table = Child_table , @column_name = column_name  from #tmpIndex where Id = @i
	SET @error_description = @error_description +@crlf
	SET @error_description = @error_description +'The table -' + @Child_table + ' does not have an index on the Foreign key column -' +@column_name + '@'
END
IF @number_of_records > 0
BEGIN
		---Error Log-- STARTS
			INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn 
			(
				QC_EGMS_ARCHIVAL_CONFIG_ID
				,ERROR_DESCRIPTION
				,ERROR_DATE
				)
			SELECT 
				@archival_config_id
				,@error_description
				,GETDATE()
			---Error Log-- ENDS

	SET @returnCode = 1
END
  return @returnCode 

 drop table #tmp
 drop table #tmpIndex
END
GO

CREATE PROCEDURE dbo.QC_EGMS_SP_CREATE_DYNAMIC_STAGING_TABLE_V2
(@table_name_input varchar(100))
AS
BEGIN
DECLARE @temp_table_sql VARCHAR(MAX),@TableScript VARCHAR(MAX)  
-----CREATE THE STAGING TABLE TO HOLD THE IDs FOR ARCHIVING
SET @temp_table_sql = 'DROP TABLE IF EXISTS [tempdb].' +@table_Name_Input+'_Staging
DROP TABLE IF EXISTS [tempdb].'+@table_Name_Input+'
CREATE TABLE [tempdb].' +@table_Name_Input+'_Staging' +' (ID int PRIMARY KEY ,InsertFlag BIT DEFAULT(0),DeleteFlag BIT DEFAULT(0),
INDEX IX_Insert NONCLUSTERED  (InsertFlag) , INDEX IX_Delete NONCLUSTERED  (DeleteFlag))'
EXEC (@temp_table_sql)


--Create new temp staging tabble as the base table to populate records for additional filtering and selecting archival candidate records
EXEC [dbo].[QC_EGMS_SP_GENERATE_DYNAMIC_TABLE]  @table_name_input ,'tempdb',@TableScript output 
EXEC(@TableScript)
END
GO

CREATE PROCEDURE dbo.QC_EGMS_SP_POPULATE_DYNAMIC_STAGING_TABLE_V2
(@table_name_input varchar(100)
,@batch_size_input int
,@Id_Input int
,@archive_date_column varchar(100)
,@Global_Config_Condition varchar(250)
,@primary_archival_column varchar(100)
,@Min_ID bigint
,@Max_ID bigint
--,@last_max_id bigint output
)
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY
	declare @temp_table_sql nvarchar(max), @Max_ID_Return bigint = 0 , @batch_counter_sql nvarchar(max),@crlf char(2)=char(0x0d)+char(0x0a)

	SET @temp_table_sql ='DECLARE @ret_str NVARCHAR(MAX) ;
	EXEC QC_EGMS_SP_GET_DYNAMIC_SQLQUERY ' +CAST(@Id_Input AS varchar(10))+','+CAST(@batch_size_input as varchar(10))+', @ret_str OUTPUT,0,'''+ISNULL(@archive_date_column,'')+''','''+ISNULL(@Global_Config_Condition,'')+'''
	SET @ret_str = @ret_str + '' And  ' +@table_name_input+'.'+@primary_archival_column + ' >= ' + CAST(@Min_ID as varchar)+ ' AND '+@table_name_input+'.'+@primary_archival_column +  ' < '+CAST(@Max_ID as varchar)+' ORDER BY ' +@table_name_input+'.'+@primary_archival_column + ' ASC ;'''+@crlf+' 
	INSERT INTO [tempdb].' +@table_Name_Input+'_Staging(ID)
	EXEC sp_executesql @ret_str'
	
	--select @temp_table_sql as temp_table_sql

	EXECUTE sp_executesql @temp_table_sql
	--,N'@cnt bigint OUTPUT'
	--,@cnt = @last_max_id output
		
	--SET @batch_counter_sql = ' select @cnt  =  count(1) from [tempdb].' + @table_name_input + '_Staging where DeleteFlag = 0' 
	SET @batch_counter_sql = ' select @max_id  =  ISNULL(MAX(ID),0) from [tempdb].' + @table_name_input + '_Staging' 
	
	EXECUTE sp_executesql @batch_counter_sql
	,N'@max_id bigint OUTPUT'
	,@max_id = @Max_ID_Return OUTPUT

	RETURN @Max_ID_Return
END TRY 

BEGIN CATCH
	---Error Log-- STARTS
					INSERT INTO dbo.QC_EGMS_ARCHIVAL_ERROR_LOG_Syn 
					(
						QC_EGMS_ARCHIVAL_CONFIG_ID
						,ERROR_DESCRIPTION
						,ERROR_DATE
						)
					SELECT 
						@Id_Input
						,ERROR_MESSAGE()
						,GETDATE()
					---Error Log-- ENDS
END CATCH
END
GO

CREATE PROCEDURE dbo.QC_EGMS_SP_ARCHIVAL_POPULATE_MIN_MAX_IDs
AS
BEGIN
DECLARE @archival_config_id int ,@temp_table_sql nvarchar(max), @counts int = 0 ,@batch_size_input int ,@crlf char(2)=char(0x0d)+char(0x0a)
,@primary_archival_column varchar(100), @table_Name_Input varchar(100), @archive_date_column varchar(100),@TableScript varchar(max),@Global_Config_Condition varchar(100)
,@last_max_id bigint, @min_id bigint , @max_id bigint 

SET @Global_Config_Condition = (select Config_condition from dbo.qc_egms_archival_global_config where config_key = 'SERVER_DATE')

DECLARE Archival_cursor CURSOR FOR 

	SELECT 
		QC_EGMS_ARCHIVAL_CONFIG_ID
		,ARCHIVAL_TABLE_NAME
		,PRIMARY_ARCHIVAL_COLUMN_NAME
		,BATCH_SIZE
		,ARCHIVE_DATE_COLUMN
		,ISNULL(MIN_ID,0)
		,ISNULL(MAX_ID,0)
	FROM 
		dbo.QC_EGMS_ARCHIVAL_CONFIG 
	WHERE 
		IS_ENABLED = 1 AND IS_APPROVED = 1 AND IS_RUNNABLE = 1 
	

OPEN Archival_cursor  

	FETCH NEXT FROM Archival_cursor INTO @archival_config_id,@table_Name_Input,@primary_archival_column,@batch_size_input,@archive_date_column,@min_id ,@max_id
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
	
	EXEC dbo.QC_EGMS_SP_CREATE_DYNAMIC_STAGING_TABLE_V2 @table_name_input

	SET @temp_table_sql = '
	DECLARE @ret_str NVARCHAR(MAX) ;
	WHILE(1=1)
	BEGIN 
	SET @cnt = (SELECT ISNULL(MAX('+@primary_archival_column+'),0) FROM [tempdb].'+@table_Name_Input+');
	If isnull(@cnt,0) = 0 
	begin
		set @cnt = isnull('+cast(@min_id as varchar) +',0)
	end
	TRUNCATE TABLE [tempdb].'+@table_Name_Input+ ';'+@crlf+
	'INSERT INTO [tempdb].'+@table_Name_Input +@crlf+ 
	'SELECT TOP ('+CAST(@batch_size_input as varchar(10))+ ')  * FROM '+@crlf + 
	@table_Name_Input +' WHERE '+@primary_archival_column + ' >= @cnt  ORDER BY ' +@primary_archival_column + ' ASC ;'+@crlf +
	'if @@rowcount = 0
	break;
	EXEC QC_EGMS_SP_GET_DYNAMIC_SQLQUERY ' +CAST(@archival_config_id AS varchar(10))+','+CAST(@batch_size_input as varchar(10))+', @ret_str OUTPUT,0,'''+ISNULL(@archive_date_column,'')+''','''+ISNULL(@Global_Config_Condition,'')+'''
	SET @ret_str = REPLACE(@ret_str,PARSENAME('''+@table_name_input+''',1),''[tempdb]..''+PARSENAME('''+@table_name_input+''',1))
	INSERT INTO [tempdb].' +@table_Name_Input+'_Staging(ID)
	EXEC sp_executesql @ret_str

	if (select count(1) from [tempdb].'+@table_Name_Input+'_staging) > 0
	begin
		SET @cnt = (SELECT MIN(ID) FROM [tempdb].'+@table_Name_Input+'_Staging);
		UPDATE dbo.QC_EGMS_ARCHIVAL_CONFIG SET MIN_ID = CAST(@cnt AS VARCHAR),MAX_ID = (select MAX('+@primary_archival_column+') from '+@table_Name_Input+' )
		WHERE QC_EGMS_ARCHIVAL_CONFIG_ID = '+ CAST(@archival_config_id AS varchar(10))+''+@crlf+'
		break;

	end 

END'

--select @temp_table_sql

EXECUTE sp_executesql @temp_table_sql
	,N'@cnt bigint OUTPUT'
	,@cnt = @last_max_id output
		
--	select @last_max_id 

	FETCH NEXT FROM Archival_cursor INTO @archival_config_id,@table_Name_Input,@primary_archival_column,@batch_size_input,@archive_date_column,@min_id ,@max_id
	END
	
	CLOSE Archival_cursor  
	DEALLOCATE Archival_cursor 

END
GO
/*
	EXEC dbo.QC_EGMS_SYNC_ARCHIVING_DB_SCHEMA_CHANGES 'dbo.QC_EGMS_XACTION_LOG','QwikCilver_eGMS_CARDS_Archive','QCLAP748-ARJUN'
	EXEC dbo.QC_EGMS_SYNC_ARCHIVING_DB_SCHEMA_CHANGES 'dbo.qc_egms_xaction_log','QwikCilver_eGMS_CARDS_Archive',NULL
*/
CREATE PROCEDURE dbo.QC_EGMS_SYNC_ARCHIVING_DB_SCHEMA_CHANGES(@archival_Table_name varchar(100),@archival_database_name nvarchar(100),@Linked_Server_Name nvarchar(100))
AS
BEGIN
 
SET NOCOUNT ON;    
  
DECLARE @prodColumnName varchar(100)
DECLARE @prodIsnullable bit
DECLARE @prodDataType varchar(100)   
DECLARE @type_of_error varchar(30)
DECLARE @source_sql nvarchar(250)
DECLARE @target_sql nvarchar(250)
DECLARE @fully_qualified_DB_Name nvarchar(250)
DECLARE @SQL nvarchar(max)



SET @fully_qualified_DB_Name = CASE WHEN @Linked_server_name <> '' THEN +'['+ @Linked_server_name +'].['+@archival_database_name +']' ELSE  @archival_database_name END
  
SET @source_sql = 'select * from ' +@archival_Table_name


SET @target_sql =  'select * from ' + @fully_qualified_DB_Name	+'.'+	@archival_Table_name


DECLARE Schema_Sync_cursor CURSOR FOR   

  SELECT 
	PROD.name as PROD_ColumnName, 
	PROD.is_nullable as PROD_is_nullable, 
	PROD.system_type_name as PROD_Datatype, 
	CASE WHEN PROD.system_type_name <> ARCHIVE.system_type_name THEN 'DATA_TYPE_MISMATCH' ELSE 'COLUMN_NOT_FOUND' END AS [TYPE_OF_ERROR]
FROM 
	sys.dm_exec_describe_first_result_set (@source_sql, NULL, 0) PROD 
FULL OUTER JOIN  
	sys.dm_exec_describe_first_result_set (@target_sql, NULL, 0) ARCHIVE 
ON 
	PROD.name = ARCHIVE.name 
WHERE 
	ARCHIVE.name IS NULL  OR (ARCHIVE.system_type_name <> PROD.system_type_name)
ORDER BY 
	PROD.Column_Ordinal


OPEN Schema_Sync_cursor    
  
FETCH NEXT FROM Schema_Sync_cursor     
INTO @prodColumnName,@prodIsnullable,@prodDataType,@type_of_error    
  


WHILE @@FETCH_STATUS = 0    
BEGIN    
  
  IF @type_of_error = 'COLUMN_NOT_FOUND' 
  BEGIN 
	 SET @SQL = 'ALTER TABLE ' + @archival_database_name+'.'+ @archival_Table_name + ' ADD ' + @prodColumnName + ' ' +  @prodDataType + ' ' + CASE WHEN @prodIsnullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
	END
   ELSE 
   BEGIN
		SET @SQL = 'ALTER TABLE ' +@archival_database_name+'.'+@archival_Table_name + ' ALTER COLUMN ' + @prodColumnName + ' ' +  @prodDataType + ' ' + CASE WHEN @prodIsnullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
	END
   
    SET   @SQL = 'Exec (''' + @SQL +  CASE when ISNULL(@linked_server_name,'') ='' then ''')' else ''') at [' +  REPLACE(@linked_server_name,'.','') +']' end     

   EXEC (@SQL)
  


    FETCH NEXT FROM Schema_Sync_cursor     
INTO @prodColumnName,@prodIsnullable,@prodDataType,@type_of_error     
   
END     
CLOSE Schema_Sync_cursor;    
DEALLOCATE Schema_Sync_cursor;  
END
GO
