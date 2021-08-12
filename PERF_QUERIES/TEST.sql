SELECT * FROM sys.dm_os_performance_counters 
WHERE [counter_name] = 'Page life expectancy'
GO
SELECT physical_memory_kb FROM sys.dm_os_sys_info;
GO
SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Target Server%';
GO 
SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Total Server%';
GO


SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
GO



select
    P.spid
,   right(convert(varchar, 
            dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'), 
            121), 12) as 'batch_duration'
,   P.program_name
,   P.hostname
,   P.loginame
from master.dbo.sysprocesses P
where P.spid > 50
and      P.status not in ('background', 'sleeping')
and      P.cmd not in ('AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER')
order by batch_duration desc
GO


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


--[dbo].[ResetTargetsProcessingStatus]

--CXPACKET
--LATCH_EX
--PAGEIOLATCH_EX
--WRITELOG
--PAGEIOLATCH_UP