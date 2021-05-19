-- This query will give us the exact sql text that was executed
-- modify the value with your actual sql_handle
SELECT * FROM sys.dm_exec_sql_text(0x02000000af179f1fdaace2c222722cf670777c010b331f9e0000000000000000000000000000000000000000)


SELECT 
    [TYPE] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.PHYSICAL_NAME
    ,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)
    ,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))
    ,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
    ,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -' 
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END 
        + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted' 
            ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END 
        + CASE is_percent_growth WHEN 1 THEN ' [autogrowth by percent, BAD setting!]' ELSE '' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
order by A.TYPE desc, A.NAME;
GO



SELECT   
        t1.resource_type,  
        t1.resource_database_id,  
        t1.resource_associated_entity_id,  
        t1.request_mode,  
        t1.request_session_id,  
        t2.blocking_session_id  
    FROM sys.dm_tran_locks as t1  
    INNER JOIN sys.dm_os_waiting_tasks as t2  
    ON t1.lock_owner_address = t2.resource_address;
GO


 EXEC Master.dbo.sp_whoisactive 
 GO


 select * from sys.dm_exec_requests

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

SELECT * FROM sys.sysprocesses WHERE open_tran = 1


SELECT
trans.session_id AS [SESSION ID],
ESes.host_name AS [HOST NAME],login_name AS [Login NAME],
trans.transaction_id AS [TRANSACTION ID],
tas.name AS [TRANSACTION NAME],tas.transaction_begin_time AS [TRANSACTION 
BEGIN TIME],
tds.database_id AS [DATABASE ID],DBs.name AS [DATABASE NAME]
FROM sys.dm_tran_active_transactions tas
JOIN sys.dm_tran_session_transactions trans
ON (trans.transaction_id=tas.transaction_id)
LEFT OUTER JOIN sys.dm_tran_database_transactions tds
ON (tas.transaction_id = tds.transaction_id )
LEFT OUTER JOIN sys.databases AS DBs
ON tds.database_id = DBs.database_id
LEFT OUTER JOIN sys.dm_exec_sessions AS ESes
ON trans.session_id = ESes.session_id
WHERE ESes.session_id IS NOT NULL




DECLARE @sqltext VARBINARY(128)
SELECT @sqltext = sql_handle
FROM sys.sysprocesses
WHERE spid IN(118)
SELECT TEXT
FROM sys.dm_exec_sql_text(@sqltext)
GO




SELECT s.session_id, 
	r.start_time, 
	s.host_name, 
	s.login_name,
	i.event_info,
	r.status,
	s.program_name,
	r.writes,
	r.reads,
	r.logical_reads,
	r.blocking_session_id,
	r.wait_type,
	r.wait_time,
	r.wait_resource
FROM sys.dm_exec_requests as r
 JOIN sys.dm_exec_sessions as s
	 on s.session_id = r.session_id
CROSS APPLY sys.dm_exec_input_buffer(s.session_id, r.request_id) as i
WHERE s.session_id != @@SPID
and  s.is_user_process = 1 
GO




SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
where 
	req.session_id != @@SPID
	 --req.session_id = 119
GO


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


SELECT session_id, login_time, security_id, status
FROM sys.dm_exec_sessions
WHERE host_name IS NULL;	
GO

SELECT DES.session_id, DES.login_name, DES.program_name, DES.client_interface_name
FROM sys.dm_exec_sessions AS DES
  JOIN sys.dm_exec_connections AS DEC
    ON DEC.session_id = DES.session_id;
GO

SELECT DEC.session_id, DEC.protocol_type, DEC.auth_scheme,
  DES.login_name, DES.login_time ,des.host_name,des.context_info
FROM sys.dm_exec_sessions AS DES
  JOIN sys.dm_exec_connections AS DEC
    ON DEC.session_id = DES.session_id
	order by session_id asc;
GO


SELECT session_id, connect_time, net_transport, auth_scheme, client_net_address 
FROM sys.dm_exec_connections;

SELECT DEC.session_id, T.text AS 'SQLQuery'
FROM sys.dm_exec_connections AS DEC
CROSS APPLY sys.dm_exec_sql_text(DEC.most_recent_sql_handle) AS T	
where 
	 dec.session_id in (128,130,119)

GO


dbcc opentran


DECLARE @destination_table VARCHAR(4000);
SET @destination_table = '[TEST].dbo.WhoIsActive_Log'

EXEC Master.dbo.sp_WhoIsActive @get_transaction_info = 1
    ,@get_plans = 1
    ,@destination_table = @destination_table;




select * from dbo.WhoIsActive_Log order by collection_time desc;
GO

truncate table dbo.WhoIsActive_Log 
GO







-----------------------------------------------------START : GET DEADLOCK INFORMATION-----------------------------------------------------
-- Query to get deadlock information

CREATE TABLE #errorlog (
            LogDate DATETIME 
            , ProcessInfo VARCHAR(100)
            , [Text] VARCHAR(MAX)
            );
DECLARE @tag VARCHAR (MAX) , @path VARCHAR(MAX);
INSERT INTO #errorlog EXEC sp_readerrorlog;
SELECT @tag = text
FROM #errorlog 
WHERE [Text] LIKE 'Logging%MSSQL\Log%';
DROP TABLE #errorlog;
SET @path = SUBSTRING(@tag, 38, CHARINDEX('MSSQL\Log', @tag) - 29);

SELECT 
  CONVERT(xml, event_data).query('/event/data/value/child::*') AS DeadlockReport,
  CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]', 'datetime') 
  AS Execution_Time
FROM sys.fn_xe_file_target_read_file(@path + '\system_health*.xel', NULL, NULL, NULL)
WHERE OBJECT_NAME like 'xml_deadlock_report';
GO


---Another query to get the deadlock information
DECLARE @xelfilepath NVARCHAR(260)
SELECT @xelfilepath = dosdlc.path
FROM sys.dm_os_server_diagnostics_log_configurations AS dosdlc;
SELECT @xelfilepath = @xelfilepath + N'system_health_*.xel'
 DROP TABLE IF EXISTS  #TempTable
 SELECT CONVERT(XML, event_data) AS EventData
        INTO #TempTable FROM sys.fn_xe_file_target_read_file(@xelfilepath, NULL, NULL, NULL)
         WHERE object_name = 'xml_deadlock_report'
SELECT EventData.value('(event/@timestamp)[1]', 'datetime2(7)') AS UtcTime, 
            CONVERT(DATETIME, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, 
      EventData.value('(event/@timestamp)[1]', 'VARCHAR(50)')), DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS LocalTime, 
            EventData.query('event/data/value/deadlock') AS XmlDeadlockReport
     FROM #TempTable
     ORDER BY UtcTime DESC;



-----------------------------------------------------END : GET DEADLOCK INFORMATION-------------------------------------------------------


-----------------------------------------------------START : TROUBLESHOOT LOCKING INFORMATION-----------------------------------------------------

--Find the blocking and Locking Information from the below Query . Observer the column WAIT_RESOURCE 

SELECT  session_id
 ,blocking_session_id
 ,wait_time
 ,wait_type
 ,last_wait_type
 ,wait_resource
 ,transaction_isolation_level
 ,lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
and session_id >= 53
GO

/*
--KEY: 27:72057594043236352 (8194443284a0)
*/
-- From the above query result , find the database ID 
SELECT 
    name 
FROM sys.databases 
WHERE database_id=27;
GO


-- Now get the hobt_id from the above wait resource and execute on the above mentioned database ID only
GO
SELECT 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
FROM sys.partitions AS p
JOIN sys.objects as so on 
    p.object_id=so.object_id
JOIN sys.indexes as si on 
    p.index_id=si.index_id and 
    p.object_id=si.object_id
JOIN sys.schemas AS sc on 
    so.schema_id=sc.schema_id
WHERE hobt_id = 72057594043236352;
GO



-- This will give you the exact resource / row that the lock is being held on 
SELECT
    *
FROM [dbo].[Test] (NOLOCK)
WHERE %%lockres%% = '(8194443284a0)';
GO


-----------------------------------------------------END : TROUBLESHOOT LOCKING INFORMATION-----------------------------------------------------


----- Get total number of pages and used pages information for a given table 

SELECT 
    t.NAME AS TableName,
    p.rows AS RowCounts,
    SUM(a.total_pages) AS TotalPages, 
    SUM(a.used_pages) AS UsedPages, 
    (SUM(a.total_pages) - SUM(a.used_pages)) AS UnusedPages
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME = 'Activities' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, p.Rows
ORDER BY 
    t.Name

GO


-- Get the row size for each row for a given table 

declare @table nvarchar(128)
declare @idcol nvarchar(128)
declare @sql nvarchar(max)

--initialize those two values
set @table = 'Activities'
set @idcol = 'Activity_PK_ID'

set @sql = 'select ' + @idcol +' , (0'

select @sql = @sql + ' + isnull(datalength(' + name + '), 1)' 
        from  sys.columns 
        where object_id = object_id(@table)
        and   is_computed = 0
set @sql = @sql + ') as rowsize from ' + @table + ' order by rowsize desc'

PRINT @sql

exec (@sql)

GO



-- Get the index usage statistics for the tables in a database other than the Primary Key (Clustered index) and Unique indexes.
-- Additional filters are commented out for being able to tailor to specific needs . Please uncomment should there be a need to
-- further filter on specific table / Index or by the number of seeks or so to get more infomration

SELECT  DB_NAME() AS DatabaseName
	   ,SCHEMA_NAME(s.schema_id) +'.'+OBJECT_NAME(i.OBJECT_ID) AS TableName
	   ,i.name AS IndexName
	   ,ius.user_seeks AS Seeks
	   ,ius.user_scans AS Scans
	   ,ius.user_lookups AS Lookups
	   ,ius.user_updates AS Updates
	   ,CASE WHEN ps.usedpages > ps.pages THEN (ps.usedpages - ps.pages) ELSE 0 
	  END * 8 / 1024 AS IndexSizeMB
	   ,ius.last_user_seek AS LastSeek
	   ,ius.last_user_scan AS LastScan
	   ,ius.last_user_lookup AS LastLookup
	   ,ius.last_user_update AS LastUpdate
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius ON ius.index_id = i.index_id AND ius.OBJECT_ID = i.OBJECT_ID
INNER JOIN (SELECT sch.name, sch.schema_id, o.OBJECT_ID, o.create_date FROM sys.schemas sch 
	 INNER JOIN sys.objects o ON o.schema_id = sch.schema_id) s ON s.OBJECT_ID = i.OBJECT_ID
LEFT JOIN (SELECT OBJECT_ID, index_id, SUM(used_page_count) AS usedpages,
	    SUM(CASE WHEN (index_id < 2) 
	  THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) 
	  ELSE lob_used_page_count + row_overflow_used_page_count 
	   END) AS pages
		FROM sys.dm_db_partition_stats
		GROUP BY object_id, index_id) AS ps ON i.object_id = ps.object_id AND i.index_id = ps.index_id
WHERE OBJECTPROPERTY(i.OBJECT_ID,'IsUserTable') = 1
--optional parameters
AND ius.database_id = DB_ID() --only check indexes in current database
AND i.type_desc = 'nonclustered' --only check nonclustered indexes
AND i.is_primary_key = 0 --do not check primary keys
AND i.is_unique_constraint = 0 --do not check unique constraints
--AND (ius.user_seeks+ius.user_scans+ius.user_lookups) < 1  --only return unused indexes
--AND OBJECT_NAME(i.OBJECT_ID) = 'tableName'--only check indexes on specified table
--AND i.name = 'IX_Your_Index_Name' --only check a specified index
 order by i.name
 GO


 
-- Get Index creation date 
SELECT I.NAME, I.OBJECT_ID, O.CREATE_DATE, O.OBJECT_ID, O.NAME
FROM SYS.INDEXES I 
JOIN SYS.OBJECTS O ON I.OBJECT_ID=O.OBJECT_ID 
WHERE I.NAME = 'INDEX_NAME'

GO




-- Get Index Fragmentaion Information
SELECT  OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name, 
IDX.name AS Index_Name, 
IDXPS.index_type_desc AS Index_Type, 
IDXPS.avg_fragmentation_in_percent  Fragmentation_Percentage
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) IDXPS 
INNER JOIN sys.indexes IDX  ON IDX.object_id = IDXPS.object_id 
AND IDX.index_id = IDXPS.index_id 
ORDER BY Fragmentation_Percentage DESC

GO


-- Get Index Fragmentaion Information
--Same query as above with additional column Page_count
select * from 
(
SELECT  OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name, 
IDX.name AS Index_Name, 
IDXPS.index_type_desc AS Index_Type, 
IDXPS.avg_fragmentation_in_percent  Fragmentation_Percentage,
page_count as Page_Count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) IDXPS 
INNER JOIN sys.indexes IDX  ON IDX.object_id = IDXPS.object_id 
AND IDX.index_id = IDXPS.index_id 

)A
Where A.Fragmentation_Percentage > 90
	AND Page_Count >250
ORDER BY Fragmentation_Percentage DESC
GO



--------------------------------------------START : GET MORE INDEX INFORMATION---------------------------------------------------

/*
The below query gives the index fragmentation infomration for a given index and the total page counts.
Once we do REBUILD the index ,and run this query we can check that the information should change and reduce the fragmentation 
as well as there will be a reduction in page count as a result of Rebuild Operation
*/
SELECT S.name as 'Schema',
T.name as 'Table',
I.name as 'Index',
DDIPS.avg_fragmentation_in_percent,
DDIPS.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
INNER JOIN sys.schemas S on T.schema_id = S.schema_id
INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
and I.name is not null
AND DDIPS.avg_fragmentation_in_percent > 0
AND I.name = 'INDEX_NAME'
	
ORDER BY DDIPS.avg_fragmentation_in_percent desc

GO




/*
The below query gives information on the Extent (which contains 8 8KB pages) as well as the allocated page_id, the next page_id 
and the previous page_id. 
Upon Rebuilding this script will show the ordered page and extents information .
*/
SELECT OBJECT_NAME(IX.object_id) as db_name, si.name, extent_page_id, allocated_page_page_id, previous_page_page_id, next_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID('YOUR_DB_NAME'), OBJECT_ID('Schema.Table_Name'),NULL, NULL, 'DETAILED') IX
INNER JOIN sys.indexes si on IX.object_id = si.object_id AND IX.index_id = si.index_id
WHERE si.name = 'INDEX_NAME'
ORDER BY allocated_page_page_id

GO

--------------------------------------------END : GET MORE INDEX INFORMATION---------------------------------------------------