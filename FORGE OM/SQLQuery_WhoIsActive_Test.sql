USE [TEST]
GO
-- fig-1 code
exec sp_whoisactive   @get_outer_command=1
,  @output_column_list = '[dd%][session_id][sql_command][sql_text][login_name][host_name][database_name][wait_info][blocking_session_id][blocked_session_count][percent_complete][cpu][used_memory][reads][writes][program_name][collection_time]'
, @find_block_leaders=1
, @destination_table = 'dbo.tbl_whoisactive';
 
select [dd hh:mm:ss.mss]
, session_id, sql_text
, database_name, wait_info
, blocking_session_id, blocked_session_count 
from dbo.tbl_whoisactive;



select * from dbo.tbl_whoisactive with (nolock)

select [dd hh:mm:ss.mss]
, session_id, sql_text
, database_name, wait_info
, blocking_session_id, blocked_session_count 
from dbo.tbl_whoisactive
where blocked_session_count > 0
and blocking_session_id is null;




SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
Go

SELECT  
	session_id,
	blocking_session_id,
	wait_time,
	wait_type,
	last_wait_type,
	wait_resource,
	transaction_isolation_level,
	lock_timeout
	FROM sys.dm_exec_requests
	WHERE blocking_session_id <> 0
GO



------------------------------------------
DECLARE @destination_table VARCHAR(4000);

SET @destination_table = 'WhoIsActive_Cap';

DECLARE @schema VARCHAR(4000);

EXEC sp_WhoIsActive @get_transaction_info = 1
    ,@get_plans = 1
    ,@return_schema = 1
    ,@schema = @schema OUTPUT;

SET @schema = REPLACE(@schema, '<table_name>', @destination_table);

PRINT @schema

EXEC (@schema);


DECLARE @destination_table VARCHAR(4000);
SET @destination_table = '[TEST].dbo.WhoIsActive_Cap'

EXEC Master.dbo.sp_WhoIsActive @get_transaction_info = 1
    ,@get_plans = 1
    ,@destination_table = @destination_table;

-- remove records older than 7 days but adjust accordingly for your needs
DELETE
FROM [TEST].dbo.WhoIsActive_Cap
WHERE collection_time < dateadd(dd, -7, getdate())



select * from dbo.WhoIsActive_Cap order by collection_time asc


--------------


EXEC sp_whoisactive @help = 1;

declare @table_creation_script varchar(max);
exec sp_whoisactive @Schema = @table_creation_script output, @return_schema=1;
print @table_creation_script;

GO

drop table dbo.testData
GO
CREATE TABLE dbo.testData ( [dd hh:mm:ss.mss] varchar(8000) NULL,[session_id] smallint NOT NULL,[sql_text] xml NULL,[login_name] nvarchar(128) NOT NULL,[wait_info] nvarchar(4000) NULL,[CPU] varchar(30) NULL,[tempdb_allocations] varchar(30) NULL,[tempdb_current] varchar(30) NULL,[blocking_session_id] smallint NULL,[reads] varchar(30) NULL,[writes] varchar(30) NULL,[physical_reads] varchar(30) NULL,[used_memory] varchar(30) NULL,[status] varchar(30) NOT NULL,[open_tran_count] varchar(30) NULL,[percent_complete] varchar(30) NULL,[host_name] nvarchar(128) NULL,[database_name] nvarchar(128) NULL,[program_name] nvarchar(128) NULL,[start_time] datetime NOT NULL,[login_time] datetime NULL,[request_id] int NULL,[collection_time] datetime NOT NULL)
GO


drop table dbo.tbl_Whoisactive
GO

CREATE TABLE dbo.tbl_Whoisactive ( 
[dd hh:mm:ss.mss] varchar(20) NULL -- change from varchar(8000) to varchar(20)
,[session_id] smallint NOT NULL 
,[sql_command] xml NULL
,[sql_text] xml NULL
,[login_name] nvarchar(128) NOT NULL
,[host_name] nvarchar(128) NULL
,[database_name] nvarchar(128) NULL
,[wait_info] nvarchar(1000) NULL -- change from nvarchar(4000) to nvarchar(1000)
,[blocking_session_id] smallint NULL
,[blocked_session_count] varchar(30) NULL
,[percent_complete] varchar(30) NULL
,[CPU] varchar(30) NULL
,[used_memory] varchar(30) NULL
,[reads] varchar(30) NULL
,[writes] varchar(30) NULL
,[program_name] nvarchar(128) NULL
,[collection_time] datetime NOT NULL -- better create an index on this column
,id bigint identity primary key -- we can add one and only one PK column here
); 


truncate table dbo.tbl_Whoisactive 
select * from dbo.tbl_Whoisactive 

GO

------------------------------===========================BLOCKING TEST====================================================================
-- Run this in First Window 
drop table if exists dbo.t;
 CREATE TABLE DBO.t (id int  primary key, a varchar(200));
insert into dbo.t (id, a) values (1,'hello'), (2, 'world');
-- start a transaction without committment
begin tran 
update dbo.t set a='hello 2' where id = 1;

--- Run this in Second Window 

delete  from dbo.t

--- Run this in Third Window 
select * from dbo.t
------------------------------===========================BLOCKING TEST====================================================================
--commit tran
--rollback tran