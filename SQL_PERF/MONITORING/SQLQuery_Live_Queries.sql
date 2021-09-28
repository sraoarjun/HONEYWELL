exec sp_PressureDetector


exec sp_whoisactive 

SELECT * FROM sys.dm_exec_requests r 
INNER JOIN sys.dm_exec_sessions s
ON r.session_id = s.session_id 
WHERE s.is_user_process = 1


SELECT session_id, blocking_session_id, start_time, wait_type, wait_type
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0;	


SELECT DISTINCT DEC.session_id, DST.text AS 'SQL'
FROM sys.dm_exec_requests AS DER
  JOIN sys.dm_exec_connections AS DEC
    ON DER.blocking_session_id = DEC.session_id
  CROSS APPLY sys.dm_exec_sql_text(DEC.most_recent_sql_handle) AS DST;	


SELECT session_id, open_transaction_count
FROM sys.dm_exec_sessions
WHERE open_transaction_count > 0;	




SELECT DER.session_id, DEQP.query_plan 
FROM sys.dm_exec_requests AS DER
  CROSS APPLY sys.dm_exec_query_plan(DER.plan_handle) AS DEQP
WHERE NOT DER.status IN ('background', 'sleeping');	


SELECT DER.session_id, DES.login_name, DES.program_name
FROM sys.dm_exec_requests AS DER
  JOIN sys.databases AS DB
    ON DER.database_id = DB.database_id
  JOIN sys.dm_exec_sessions AS DES
    ON DER.session_id = DES.session_id
WHERE DB.name = 'Honeywell.MES.Operations.DataModel.OperationsDB';	


SELECT COALESCE(wait_type, 'None') AS wait_type, COUNT(*) AS Total
FROM sys.dm_exec_requests
WHERE NOT status IN ('Background', 'Sleeping')
GROUP BY wait_type 
ORDER BY Total DESC;


SELECT L.request_session_id, L.resource_type, 
  L.resource_subtype, L.request_mode, L.request_type 
FROM sys.dm_tran_locks AS L
  JOIN sys.dm_exec_requests AS DER
    ON L.request_session_id = DER.session_id
WHERE DER.wait_type = 'LCK_M_S';




SELECT      r.start_time [Start Time],session_ID [SPID],
            DB_NAME(database_id) [Database],
            SUBSTRING(t.text,(r.statement_start_offset/2)+1,
            CASE WHEN statement_end_offset=-1 OR statement_end_offset=0
            THEN (DATALENGTH(t.Text)-r.statement_start_offset/2)+1
            ELSE (r.statement_end_offset-r.statement_start_offset)/2+1
            END) [Executing SQL],
            Status,command,wait_type,wait_time,wait_resource,
            last_wait_type
FROM        sys.dm_exec_requests r
OUTER APPLY sys.dm_exec_sql_text(sql_handle) t
WHERE       session_id != @@SPID -- don't show this query
AND         session_id > 50 -- don't show system queries
ORDER BY    r.start_time
GO

--- Currently Blocking Queries 
SELECT * 
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO
-- Currently Waiting Tasks 
SELECT session_id, wait_duration_ms, wait_type, blocking_session_id 
FROM sys.dm_os_waiting_tasks 
WHERE blocking_session_id <> 0
GO

SELECT session_id, wait_duration_ms, wait_type, blocking_session_id 
FROM sys.dm_os_waiting_tasks where wait_type like '%Thread%'


declare @sp_id int = 305
DECLARE @sqltext VARBINARY(128)
SELECT @sqltext = sql_handle
FROM sys.sysprocesses
WHERE spid =@sp_id
SELECT TEXT
FROM sys.dm_exec_sql_text(@sqltext)
GO



SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
AS [%signal (cpu) waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
AS [%resource waits] FROM sys.dm_os_wait_stats OPTION (RECOMPILE);

GO


SELECT
scheduler_id,
cpu_id,
current_tasks_count,
runnable_tasks_count,
current_workers_count,
active_workers_count,
work_queue_count,
pending_disk_io_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255;