SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
AS [%signal (cpu) waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
AS [%resource waits] FROM sys.dm_os_wait_stats OPTION (RECOMPILE)


SELECT total_physical_memory_kb/1024 [Total Physical Memory in MB],
available_physical_memory_kb/1024 [Physical Memory Available in MB],
system_memory_state_desc
FROM sys.dm_os_sys_memory;


SELECT physical_memory_in_use_kb/1024 [Physical Memory Used in MB],
process_physical_memory_low [Physical Memory Low],
process_virtual_memory_low [Virtual Memory Low]
FROM sys.dm_os_process_memory;



SELECT committed_kb/1024 [SQL Server Committed Memory in MB],
committed_target_kb/1024 [SQL Server Target Committed Memory in MB]
FROM sys.dm_os_sys_info;





DECLARE @max INT;
SELECT @max = max_workers_count
FROM sys.dm_os_sys_info;
SELECT GETDATE() AS 'CurrentDate', 
       @max AS 'TotalThreads', 
       SUM(active_Workers_count) AS 'CurrentThreads', 
       @max - SUM(active_Workers_count) AS 'AvailableThreads', 
       SUM(runnable_tasks_count) AS 'WorkersWaitingForCpu', 
       SUM(work_queue_count) AS 'RequestWaitingForThreads', 
       SUM(current_workers_count) AS 'AssociatedWorkers'
FROM sys.dm_os_Schedulers
WHERE STATUS = 'VISIBLE ONLINE';

SELECT 
a.scheduler_id ,
b.session_id,
 (SELECT TOP 1 SUBSTRING(s2.text,statement_start_offset / 2+1 , 
      ( (CASE WHEN statement_end_offset = -1 
         THEN (LEN(CONVERT(nvarchar(max),s2.text)) * 2) 
         ELSE statement_end_offset END)  - statement_start_offset) / 2+1))  AS sql_statement
FROM sys.dm_os_schedulers a 
INNER JOIN sys.dm_os_tasks b on a.active_worker_address = b.worker_address
INNER JOIN sys.dm_exec_requests c on b.task_address = c.task_address
CROSS APPLY sys.dm_exec_sql_text(c.sql_handle) AS s2 

GO
