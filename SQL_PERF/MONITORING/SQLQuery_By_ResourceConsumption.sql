/*
The DMV can only report on the data that is available in the plan cache. If the plan cache is experiencing lots of churn, the report becomes less accurate.
If you want to track this data over time, you will need to capture data at regular intervals and persist it to some kind of logging table or file

*/

WITH CPU_Per_Db
AS
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
 ,CAST([CPUTimeAsMS] * 1.0 / SUM([CPUTimeAsMS]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUTimeAs{96f5cbaad583fb885ff5d18ecce5734bf1e8596949521e20c290401929518f75}]
 FROM CPU_Per_Db
 ORDER BY [CPUTimeAsMS] DESC;

 GO


 WITH IO_Per_DB
AS
(SELECT 
  DB_NAME(database_id) AS Db
  , CONVERT(DECIMAL(12,2), SUM(num_of_bytes_read + num_of_bytes_written) / 1024 / 1024) AS TotalMb
 FROM sys.dm_io_virtual_file_stats(NULL, NULL) dmivfs
 GROUP BY database_id)
 SELECT 
    Db
    ,TotalMb
    ,CAST(TotalMb / SUM(TotalMb) OVER() * 100 AS DECIMAL(5,2)) AS [I/O]
FROM IO_Per_DB
ORDER BY [I/O] DESC;

GO


WITH IO_Per_DB_Per_File
AS
(SELECT 
    DB_NAME(dmivfs.database_id) AS Db
  , CONVERT(DECIMAL(12,2), SUM(num_of_bytes_read + num_of_bytes_written) / 1024 / 1024) AS TotalMb
  , CONVERT(DECIMAL(12,2), SUM(num_of_bytes_read) / 1024 / 1024) AS TotalMbRead
  , CONVERT(DECIMAL(12,2), SUM(num_of_bytes_written) / 1024 / 1024) AS TotalMbWritten
  , CASE WHEN dmmf.type_desc = 'ROWS' THEN 'Data File' WHEN dmmf.type_desc = 'LOG' THEN 'Log File' END AS DataFileOrLogFile
 FROM sys.dm_io_virtual_file_stats(NULL, NULL) dmivfs
 JOIN sys.master_files dmmf ON dmivfs.file_id = dmmf.file_id AND dmivfs.database_id = dmmf.database_id
 GROUP BY dmivfs.database_id, dmmf.type_desc)
 SELECT 
    Db
  , TotalMb
  , TotalMbRead
  , TotalMbWritten
  , DataFileOrLogFile
  , CAST(TotalMb / SUM(TotalMb) OVER() * 100 AS DECIMAL(5,2)) AS [I/O]
FROM IO_Per_DB_Per_File
ORDER BY [I/O] DESC;