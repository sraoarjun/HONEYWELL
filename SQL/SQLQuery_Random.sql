;WITH CPU_Per_Db AS
(SELECT 
dmpa.DatabaseID
, DB_Name(dmpa.DatabaseID) AS [Database]
, SUM(dmqs.total_worker_time) AS CPUTimeAsMS
FROM sys.dm_exec_query_stats dmqs 
CROSS APPLY 
(SELECT 
CONVERT(INT, value) AS [DatabaseID] 
FROM sys.dm_exec_plan_attributes(dmqs.plan_handle)
WHERE attribute = N'dbid') dmpa
GROUP BY dmpa.DatabaseID)
 
SELECT 
[Database] 
,[CPUTimeAsMS] 
,CAST([CPUTimeAsMS] * 1.0 / SUM([CPUTimeAsMS]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUTimeAs%]
FROM CPU_Per_Db
ORDER BY [CPUTimeAs%] DESC;


-- CPU intensive query over adventureworks database
SELECT
       -- using statement_start_offset and
       -- statement_end_offset we get the query text
       -- from inside the entire batch
       SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
                           ((CASE qs.statement_end_offset
                                        WHEN -1 THEN DATALENGTH(qt.TEXT)
                                        ELSE qs.statement_end_offset
                           END
                           - qs.statement_start_offset)/2)+1)
                           as [Text],
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
-- converting microseconds to seconds
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
       -- Retrieve the query text
       CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
       -- Retrieve the query plan
       CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time DESC -- CPU time
GO


SELECT name AS 'Database Name'
      ,SUM(num_of_reads) AS 'Number of Read'
      ,SUM(num_of_writes) AS 'Number of Writes' 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) I
  INNER JOIN sys.databases D  
      ON I.database_id = d.database_id
GROUP BY name ORDER BY 'Number of Read' DESC;
GO


SELECT left(f.physical_name, 1) AS DriveLetter, 
	DATEADD(MS,sample_ms * -1, GETDATE()) AS [Start Date],
	SUM(v.num_of_writes) AS total_num_of_writes, 
	SUM(v.num_of_bytes_written) AS total_num_of_bytes_written, 
	SUM(v.num_of_reads) AS total_num_of_reads, 
	SUM(v.num_of_bytes_read) AS total_num_of_bytes_read, 
	SUM(v.size_on_disk_bytes) AS total_size_on_disk_bytes
FROM sys.master_files f
INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) v
ON f.database_id=v.database_id and f.file_id=v.file_id
GROUP BY left(f.physical_name, 1),DATEADD(MS,sample_ms * -1, GETDATE());

SELECT  LEFT(physical_name, 1) AS drive,
        CAST(SUM(io_stall_read_ms) / 
            (1.0 + SUM(num_of_reads)) AS NUMERIC(10,1)) 
                          AS 'avg_read_disk_latency_ms',
        CAST(SUM(io_stall_write_ms) / 
            (1.0 + SUM(num_of_writes) ) AS NUMERIC(10,1)) 
                          AS 'avg_write_disk_latency_ms',
        CAST((SUM(io_stall)) / 
            (1.0 + SUM(num_of_reads + num_of_writes)) AS NUMERIC(10,1)) 
                          AS 'avg_disk_latency_ms'
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs
        JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id
                                       AND mf.file_id = divfs.file_id
GROUP BY LEFT(physical_name, 1)
ORDER BY avg_disk_latency_ms DESC;

GO


SELECT TOP 25 cp.usecounts AS [execution_count]
      ,qs.total_worker_time AS CPU
      ,qs.total_elapsed_time AS ELAPSED_TIME
      ,qs.total_logical_reads AS LOGICAL_READS
      ,qs.total_logical_writes AS LOGICAL_WRITES
      ,qs.total_physical_reads AS PHYSICAL_READS 
      ,SUBSTRING(text, 
                   CASE WHEN statement_start_offset = 0 
                          OR statement_start_offset IS NULL  
                           THEN 1  
                           ELSE statement_start_offset/2 + 1 END, 
                   CASE WHEN statement_end_offset = 0 
                          OR statement_end_offset = -1  
                          OR statement_end_offset IS NULL  
                           THEN LEN(text)  
                           ELSE statement_end_offset/2 END - 
                     CASE WHEN statement_start_offset = 0 
                            OR statement_start_offset IS NULL 
                             THEN 1  
                             ELSE statement_start_offset/2  END + 1 
                  )  AS [Statement]        
FROM sys.dm_exec_query_stats qs  
   join sys.dm_exec_cached_plans cp on qs.plan_handle = cp.plan_handle 
   CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
ORDER BY qs.total_logical_reads DESC;


SELECT name AS 'Database Name'
      ,SUM(num_of_reads) AS 'Number of Read'
      ,SUM(num_of_writes) AS 'Number of Writes' 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) I
  INNER JOIN sys.databases D  
      ON I.database_id = d.database_id
GROUP BY name ORDER BY 'Number of Read' DESC;


GO

SELECT OBJECT_NAME(i.[object_id]) AS TableName,
       i.[name] AS IndexName,
       SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id] AND s.[index_id] = i.[index_id]
WHERE OBJECT_NAME(i.[object_id]) like '%testtable%'
GROUP BY i.[name],i.[object_id];


GO

SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
       ind.name AS IndexName, 
       indexstats.index_type_desc AS IndexType, 
       indexstats.avg_fragmentation_in_percent 
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id 
WHERE OBJECT_NAME(ind.OBJECT_ID) like '%testtable%'
ORDER BY indexstats.avg_fragmentation_in_percent DESC 

GO
