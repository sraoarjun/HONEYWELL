DECLARE @Reportinginterval int,@StartDateText varchar(30);
--Set Reporting interval in days
SET @Reportinginterval = 10;
set @StartDateText   =(select CAST(DATEADD(DAY, -@Reportinginterval, GETUTCDATE()) AS varchar(30)));


 SELECT 
		  DB_NAME(),
		  s.name AS SchemaName,
		  o.name AS ObjectName,
		  SUBSTRING(t.query_sql_text,1,1000) AS QueryText,
		  SUM(rs.count_executions) AS TotalExecutions,
		  SUM(rs.avg_duration * rs.count_executions) AS TotalDuration,
		  SUM(rs.avg_cpu_time * rs.count_executions) AS TotalCPU,
		  SUM(rs.avg_logical_io_reads * rs.count_executions) AS TotalLogicalReads,
		  rs.last_execution_time
	   FROM sys.query_store_query q
	   INNER JOIN sys.query_store_query_text t
		  ON q.query_text_id = t.query_text_id
	   INNER JOIN sys.query_store_plan p
		  ON q.query_id = p.query_id
	   INNER JOIN sys.query_store_runtime_stats rs
		  ON p.plan_id = rs.plan_id
	   INNER JOIN sys.query_store_runtime_stats_interval rsi
		  ON rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
	   LEFT JOIN sys.objects o
		  ON q.OBJECT_ID = o.OBJECT_ID
	   LEFT JOIN sys.schemas s
		  ON o.schema_id = s.schema_id     
	   WHERE rsi.start_time > @StartDateText
	   and s.name = 'dbo' and o.name is not null
	   GROUP BY s.name, o.name, SUBSTRING(t.query_sql_text,1,1000),rs.last_execution_time
	   OPTION(RECOMPILE);