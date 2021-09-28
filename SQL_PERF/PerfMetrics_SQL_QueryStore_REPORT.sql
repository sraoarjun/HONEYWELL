
-- Top Most resource consuming Queries by Max duration
SELECT TOP 25 rs.max_duration,cast(rs.max_duration/1000000.00 as decimal(10,4))  as [max_duration(s)], qt.query_sql_text, q.query_id,
    qt.query_text_id, p.plan_id,
    rs.last_execution_time
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
ORDER BY rs.max_duration DESC;
GO


-- Top Most resource consuming Queries by Avg duration
--SELECT TOP 25 
--	rs.avg_duration,
--	cast(rs.avg_duration/1000000.00 as decimal(10,4))  as [avg_duration(s)], qt.query_sql_text, q.query_id,
--    qt.query_text_id, p.plan_id,
--    rs.last_execution_time
--FROM sys.query_store_query_text AS qt
--JOIN sys.query_store_query AS q
--    ON qt.query_text_id = q.query_text_id
--JOIN sys.query_store_plan AS p
--    ON q.query_id = p.query_id
--JOIN sys.query_store_runtime_stats AS rs
--    ON p.plan_id = rs.plan_id
--ORDER BY rs.avg_duration DESC;
--GO
DECLARE @Period1Start Datetimeoffset, @Period1End Datetimeoffset, @Period2Start datetime, @Period2End datetime
SET @Period1Start = '20210727 15:30:00:000 +05:30'
SET @Period1End = '20210727 16:30:00:000 +05:30';

WITH
recent AS
(
    SELECT 
		p.query_id query_id,
        ROUND(ROUND(CONVERT(FLOAT, SUM(rs.avg_duration * rs.count_executions)) * 0.001, 2), 2) AS total_duration,
		AVG(rs.avg_duration* 0.000001) avg_duration_old,
		(ROUND(ROUND(CONVERT(FLOAT, SUM(rs.avg_duration * rs.count_executions)) * 0.001, 2), 2)/SUM(rs.count_executions) * 0.001) AS avg_duration,
        SUM(rs.count_executions) AS count_executions,
        COUNT(distinct p.plan_id) AS num_plans
    FROM sys.query_store_runtime_stats AS rs
        JOIN sys.query_store_plan AS p ON p.plan_id = rs.plan_id
    WHERE  (rs.first_execution_time >= @Period1Start
               AND rs.last_execution_time < @Period1End)
        OR (rs.first_execution_time <= @Period1Start
               AND rs.last_execution_time > @Period1Start)
        OR (rs.first_execution_time <= @Period1End
               AND rs.last_execution_time > @Period1End)
    GROUP BY p.query_id
	--ORDER BY (ROUND(ROUND(CONVERT(FLOAT, SUM(rs.avg_duration * rs.count_executions)) * 0.001, 2), 2)/SUM(rs.count_executions) * 0.001) desc
)
--select * from recent where query_id IN(2106,361,2041,5,2106,691,2045,2242)
select top 25 r.*,s.query_sql_text from recent r 

JOIN 
(select distinct qt.query_sql_text , q.query_id from  sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id 
	) s 
on 
 r.query_id = s.query_id
 order by r.avg_duration desc 
GO


-- Biggest avg physical io reads 

SELECT TOP 30 rs.avg_physical_io_reads, qt.query_sql_text,
    q.query_id, qt.query_text_id, p.plan_id, rs.runtime_stats_id,
    rsi.start_time, rsi.end_time, rs.avg_rowcount, rs.count_executions
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi
    ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
ORDER BY rs.avg_physical_io_reads DESC;
GO


--Queries that recently regressed in performance (comparing different point in time
SELECT
    qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    rs1.runtime_stats_id AS runtime_stats_id_1,
    rsi1.start_time AS interval_1,
    p1.plan_id AS plan_1,
    --rs1.avg_duration/1000000 AS [avg_duration_1(s)],
	cast(rs1.avg_duration/1000000.00 as decimal(10,4)) AS [avg_duration_1(s)],
    --rs2.avg_duration/1000000 AS [avg_duration_2(s)],
	cast(rs2.avg_duration/1000000.00 as decimal(10,4)) AS [avg_duration_2(s)],
    p2.plan_id AS plan_2,
    rsi2.start_time AS interval_2,
    rs2.runtime_stats_id AS runtime_stats_id_2
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p1
    ON q.query_id = p1.query_id
JOIN sys.query_store_runtime_stats AS rs1
    ON p1.plan_id = rs1.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi1
    ON rsi1.runtime_stats_interval_id = rs1.runtime_stats_interval_id
JOIN sys.query_store_plan AS p2
    ON q.query_id = p2.query_id
JOIN sys.query_store_runtime_stats AS rs2
    ON p2.plan_id = rs2.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi2
    ON rsi2.runtime_stats_interval_id = rs2.runtime_stats_interval_id
    AND rsi2.start_time > rsi1.start_time
    AND p1.plan_id <> p2.plan_id
    AND rs2.avg_duration > 2*rs1.avg_duration
ORDER BY q.query_id, rsi1.start_time, rsi2.start_time;
GO


























---======================================================================================================

---======================================================================================================
--select DATEDIFF(hour,getdate() ,'2021-07-23 19:30:45.857') as datediff_in_hours

--The number of queries with the longest average execution time 

SELECT TOP 25 rs.avg_duration, qt.query_sql_text, q.query_id,
    qt.query_text_id, p.plan_id, GETUTCDATE() AS CurrentUTCTime,
    rs.last_execution_time
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
WHERE rs.last_execution_time > DATEADD(HOUR, DATEDIFF(hour,getdate() ,'20210727 15:30:00:000 +0:00'), GETUTCDATE()) 
and rs.last_execution_time < DATEADD(HOUR, DATEDIFF(hour,getdate() ,'20210727 16:30:00:000 +0:00'),GETUTCDATE())
ORDER BY rs.avg_duration DESC;
GO


/*The number of queries that had the biggest average physical I/O reads in last 24 hours, 
with corresponding average row count and execution count?
*/
SELECT TOP 30 rs.avg_physical_io_reads, qt.query_sql_text,
    q.query_id, qt.query_text_id, p.plan_id, rs.runtime_stats_id,
    rsi.start_time, rsi.end_time, rs.avg_rowcount, rs.count_executions
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi
    ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE rsi.start_time >= DATEADD(hour, DATEDIFF(hour,getdate() ,'20210727 15:30:00:000 +5:30'), GETUTCDATE())
ORDER BY rs.avg_physical_io_reads DESC;
GO



--Queries that recently regressed in performance (comparing different point in time)?
SELECT
    qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    rs1.runtime_stats_id AS runtime_stats_id_1,
    rsi1.start_time AS interval_1,
    p1.plan_id AS plan_1,
    rs1.avg_duration AS avg_duration_1,
    rs2.avg_duration AS avg_duration_2,
    p2.plan_id AS plan_2,
    rsi2.start_time AS interval_2,
    rs2.runtime_stats_id AS runtime_stats_id_2
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p1
    ON q.query_id = p1.query_id
JOIN sys.query_store_runtime_stats AS rs1
    ON p1.plan_id = rs1.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi1
    ON rsi1.runtime_stats_interval_id = rs1.runtime_stats_interval_id
JOIN sys.query_store_plan AS p2
    ON q.query_id = p2.query_id
JOIN sys.query_store_runtime_stats AS rs2
    ON p2.plan_id = rs2.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi2
    ON rsi2.runtime_stats_interval_id = rs2.runtime_stats_interval_id
WHERE rsi1.start_time > DATEADD(hour, DATEDIFF(hour,getdate() ,'20210727 15:30:00:000 +5:30'), GETUTCDATE())
    AND rsi2.start_time > rsi1.start_time
    AND p1.plan_id <> p2.plan_id
    AND rs2.avg_duration > 2*rs1.avg_duration
ORDER BY q.query_id, rsi1.start_time, rsi2.start_time;
GO






----------=======================================================================================================
drop table if exists #tempMax,#tempAvg

DECLARE @Period1Start Datetimeoffset, @Period1End Datetimeoffset, @Period2Start datetime, @Period2End datetime
SET @Period1Start = '20210727 15:30:00:000 +05:30'
SET @Period1End = '20210727 16:30:00:000 +05:30';

SELECT rs.max_duration,cast(rs.max_duration/1000000.00 as decimal(10,4))  as [max_duration(s)], qt.query_sql_text, q.query_id,
    qt.query_text_id, p.plan_id,
    rs.last_execution_time
	INTO #tempMax
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
WHERE  (rs.first_execution_time >= @Period1Start
               AND rs.last_execution_time < @Period1End)
        OR (rs.first_execution_time <= @Period1Start
               AND rs.last_execution_time > @Period1Start)
        OR (rs.first_execution_time <= @Period1End
               AND rs.last_execution_time > @Period1End) 

ORDER BY rs.max_duration DESC;
GO

DECLARE @Period1Start Datetimeoffset, @Period1End Datetimeoffset, @Period2Start datetime, @Period2End datetime
SET @Period1Start = '20210727 15:30:00:000 +05:30'
SET @Period1End = '20210727 16:30:00:000 +05:30';

WITH
recent AS
(
    SELECT 
		p.query_id query_id,
        ROUND(ROUND(CONVERT(FLOAT, SUM(rs.avg_duration * rs.count_executions)) * 0.001, 2), 2) AS total_duration,
		AVG(rs.avg_duration* 0.000001) avg_duration_old,
		(ROUND(ROUND(CONVERT(FLOAT, SUM(rs.avg_duration * rs.count_executions)) * 0.001, 2), 2)/SUM(rs.count_executions) * 0.001) AS avg_duration,
        SUM(rs.count_executions) AS count_executions,
        COUNT(distinct p.plan_id) AS num_plans
    FROM sys.query_store_runtime_stats AS rs
        JOIN sys.query_store_plan AS p ON p.plan_id = rs.plan_id
    WHERE  (rs.first_execution_time >= @Period1Start
               AND rs.last_execution_time < @Period1End)
        OR (rs.first_execution_time <= @Period1Start
               AND rs.last_execution_time > @Period1Start)
        OR (rs.first_execution_time <= @Period1End
               AND rs.last_execution_time > @Period1End)
    GROUP BY p.query_id
	
)

select   r.*,s.query_sql_text  into #tempAvg from recent r 

JOIN 
(select distinct qt.query_sql_text , q.query_id from  sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id 
	) s 
on 
 r.query_id = s.query_id
 order by r.avg_duration desc 
GO





--select  a.*,'--',b.* from #tempMax  a ,#tempAvg b where a.query_id = b.query_id

select distinct a.query_id ,a.query_sql_text,a.[max_duration(s)],b.avg_duration as [avg_duration(s)], count_executions as execution_count   from #tempMax  a ,#tempAvg b where a.query_id = b.query_id
 and b.avg_duration > 1 and count_executions > 5


 select * from 
 (
select distinct a.query_id ,a.query_sql_text,a.[max_duration(s)],b.avg_duration as [avg_duration(s)], count_executions as execution_count   from #tempMax  a ,#tempAvg b where a.query_id = b.query_id
 and b.avg_duration > 1 --and count_executions > 5

 )A

 GO


 

	select x.* from 
	(
		select  a.query_id ,a.query_sql_text,a.[max_duration(s)],b.avg_duration as [avg_duration(s)], count_executions as execution_count   from #tempMax  a ,#tempAvg b  where a.query_id = b.query_id
		and 
			b.avg_duration > 1  --and a.query_id = 691
	)x
	join 
	(
		select a.query_id , max(a.[max_duration(s)]) as [max_duration(s)] from #tempMax a , #tempAvg b where 
		a.query_id = b.query_id
		and b.avg_duration > 1  --and a.query_id = 691
		group by a.query_id 
	)y
	On 
	
	x.query_id = y.query_id
and 
	x.[max_duration(s)] = y.[max_duration(s)] 

	
