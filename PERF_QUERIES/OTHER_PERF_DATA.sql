-- Disk IO Latency 
SELECT  DB_NAME(vfs.database_id) AS database_name ,physical_name AS [Physical Name],
        size_on_disk_bytes / 1024 / 1024. AS [Size of Disk] ,
        CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [Average Read latency] ,
        CAST(io_stall_write_ms/(1.0 + num_of_writes) AS NUMERIC(10,1)) AS [Average Write latency] ,
        CAST((io_stall_read_ms + io_stall_write_ms)
/(1.0 + num_of_reads + num_of_writes) 
AS NUMERIC(10,1)) AS [Average Total Latency],
        num_of_bytes_read / NULLIF(num_of_reads, 0) AS    [Average Bytes Per Read],
        num_of_bytes_written / NULLIF(num_of_writes, 0) AS   [Average Bytes Per Write]
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
  JOIN sys.master_files AS mf 
    ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY [Average Total Latency] DESC

GO

---Paul DISK IO Latency
SELECT
    [ReadLatency] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,
    [WriteLatency] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,
    [Latency] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,
    [AvgBPerRead] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,
    [AvgBPerWrite] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,
    [AvgBPerTransfer] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE
                (([num_of_bytes_read] + [num_of_bytes_written]) /
                ([num_of_reads] + [num_of_writes])) END,
    LEFT ([mf].[physical_name], 2) AS [Drive],
    DB_NAME ([vfs].[database_id]) AS [DB],
    [mf].[physical_name]
FROM
    sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
JOIN sys.master_files AS [mf]
    ON [vfs].[database_id] = [mf].[database_id]
    AND [vfs].[file_id] = [mf].[file_id]
-- WHERE [vfs].[file_id] = 2 -- log files
-- ORDER BY [Latency] DESC
-- ORDER BY [ReadLatency] DESC
ORDER BY [WriteLatency] DESC;
GO

-- Index Stats
SELECT OBJECT_NAME(A.[OBJECT_ID]) AS [OBJECT NAME], 
       I.[NAME] AS [INDEX NAME], 
       A.LEAF_INSERT_COUNT, 
       A.LEAF_UPDATE_COUNT, 
       A.LEAF_DELETE_COUNT 
FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) A 
       INNER JOIN SYS.INDEXES AS I 
         ON I.[OBJECT_ID] = A.[OBJECT_ID] 
            AND I.INDEX_ID = A.INDEX_ID 
WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1
GO

-- Highest wait time by Object Details
select db_name(database_id) DB,
QUOTENAME(OBJECT_SCHEMA_NAME(object_id, database_id)) 
+ N'.' 
+ QUOTENAME(OBJECT_NAME(object_id, database_id)) ObjDetails,
row_lock_wait_in_ms + page_lock_wait_in_ms Block_Wait_Time_in_ms
from sys.dm_db_index_operational_stats(NULL,NULL,NULL,NULL)
order by Block_Wait_Time_in_ms desc,ObjDetails desc
GO


--  Index UsageDetails
select object_name(object_id), index_id, user_seeks, user_scans, user_lookups 
from sys.dm_db_index_usage_stats 
 --where OBJECT_NAME(object_id) like '%tag%'
 order by object_id, index_id 

---All indexes which haven’t been used yet can be retrieved with the following statement: 

select object_name(object_id), i.name 
from sys.indexes i 
where  i.index_id NOT IN (select s.index_id 
                          from sys.dm_db_index_usage_stats s 
                          where s.object_id=i.object_id and 
                          i.index_id=s.index_id and 
                          database_id =  DB_id(db_name())) 
	--and i.name like '%tag%'
order by object_name(object_id) asc 
GO

--Poorly configured IO subsystem - average total IO latency
 SET NOCOUNT ON
 
   SELECT TOP (10) DB_NAME (a.database_id) AS dbname,
      a.io_stall / NULLIF (a.num_of_reads + a.num_of_writes, 0) AS average_tot_latency,
      Round ((a.size_on_disk_bytes / square (1024.0)), 1) AS size_mb,
      b.physical_name AS [fileName]
   FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS a,
      sys.master_files AS b
   WHERE a.database_id = b.database_id
      AND a.FILE_ID = b.FILE_ID
   ORDER BY average_tot_latency DESC
 
   SET NOCOUNT OFF
GO
