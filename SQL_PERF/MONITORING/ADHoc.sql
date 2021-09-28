
 WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT  st.text,
        qp.query_plan,
        qs.*
FROM    (
    SELECT  TOP 50 *
    FROM    sys.dm_exec_query_stats
    ORDER BY total_worker_time DESC
) AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE qp.query_plan.value('count(//p:MissingIndexGroup)', 'int') > 0



SELECT DISTINCT
       o.name AS Object_Name,
       o.type_desc
FROM sys.sql_modules m
       INNER JOIN
       sys.objects o
         ON m.object_id = o.object_id
WHERE m.definition Like '%INSERT INTO #FinalRtnTrgts%';





SELECT TOP 10
	TOTAL_WORKER_TIME ,
	EXECUTION_COUNT ,
	TOTAL_WORKER_TIME / EXECUTION_COUNT AS [AVG CPU TIME] ,
QT.TEXT AS QUERYTEXT
FROM SYS.DM_EXEC_QUERY_STATS QS
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(QS.PLAN_HANDLE) AS QT
ORDER BY QS.TOTAL_WORKER_TIME DESC ;


WITH Waits AS 
( 
SELECT 
wait_type, 
wait_time_ms / 1000. AS wait_time_s, 
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct, 
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn 
FROM sys.dm_os_wait_stats 
WHERE wait_type 
NOT IN 
('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 
'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 
'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT') 
) -- filter out additional irrelevant waits 
SELECT W1.wait_type, 
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s, 
CAST(W1.pct AS DECIMAL(12, 2)) AS pct, 
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct 
FROM Waits AS W1 
INNER JOIN Waits AS W2 ON W2.rn <= W1.rn 
GROUP BY W1.rn, 
W1.wait_type, 
W1.wait_time_s, 
W1.pct 
HAVING SUM(W2.pct) - W1.pct < 95
and W1.wait_type = 'SOS_SCHEDULER_YIELD'; -- percentage threshold;



SELECT AVG(current_tasks_count) AS [Avg Current Task], 
AVG(runnable_tasks_count) AS [Avg Wait Task]
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
AND status = 'VISIBLE ONLINE'


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



SELECT COUNT(*) AS proc# 
FROM sys.dm_os_schedulers 
WHERE status = 'VISIBLE ONLINE' 
AND is_online = 1
GO

SELECT s2.text, 
session_id,
start_time,
status, 
cpu_time, 
blocking_session_id, 
wait_type,
wait_time, 
wait_resource, 
open_transaction_count
FROM sys.dm_exec_requests a
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) AS s2  
WHERE status <> 'background'
 order by cpu_time desc 


 exec sp_whoisactive