

--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE CLEAR;



SELECT actual_state_desc, desired_state_desc, current_storage_size_mb,
    max_storage_size_mb, readonly_reason, interval_length_minutes,
    stale_query_threshold_days, size_based_cleanup_mode_desc,
    query_capture_mode_desc
FROM sys.database_query_store_options;


--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_ONLY);

--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (QUERY_CAPTURE_MODE = AUTO);

 
--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);

SELECT
	TOP 10 
     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
	 OBJECT_NAME([qsq].[object_id]) AS [OBJECT_NAME],
     [rs].[runtime_stats_interval_id],
     [rsi].[start_time],
     [rsi].[end_time],
     [rs].[count_executions],
    [rs].[avg_cpu_time]/1000.00 as [avg_cpu_time_ms],
	[rs].[avg_duration]/1000.00 as [avg_duration_ms],
     [rs].[avg_logical_io_reads],
     [rs].[avg_rowcount],
     [qst].[query_sql_text],
	 [rs].[last_execution_time],
     ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE 
	--[qsq].[object_id] = OBJECT_ID(N'dbo.usp_GetTargetDeviations')
 --    AND 
		[rs].[last_execution_time] > DATEADD(MINUTE, -15, GETUTCDATE())
		--[rs].[last_execution_time] > '2021-08-04 14:05:12.6400000 +00:00'
		
	 AND [rs].[execution_type] = 0
ORDER BY rs.avg_duration desc
GO





SELECT
     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
     [rs].[runtime_stats_interval_id],
     [rsi].[start_time],
     [rsi].[end_time],
     [rs].[count_executions],
     [rs].[avg_duration],
     [rs].[avg_cpu_time],
     [rs].[avg_logical_io_reads],
     [rs].[avg_rowcount],
     [qst].[query_sql_text],
     ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'dbo.usp_GetTargetDeviations')
     AND [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())
	 --AND [rs].[last_execution_time] > DATEADD(DAY, -10, GETUTCDATE())
     AND [rs].[execution_type] = 0
ORDER BY [qsq].[query_id], [qsp].[plan_id], [rs].[runtime_stats_interval_id];
GO

SELECT
     [qsq].[query_id],
     [qsp].[plan_id],
     OBJECT_NAME([qsq].[object_id])AS [ObjectName],
     SUM([rs].[count_executions]) AS [TotalExecutions],
     SUM([rs].[avg_duration]) / SUM([rs].[count_executions]) AS [Avg_Duration],
     SUM([rs].[avg_cpu_time]) / SUM([rs].[count_executions]) AS [Avg_CPU],
     SUM([rs].[avg_logical_io_reads]) / SUM([rs].[count_executions]) AS [Avg_LogicalReads],
     MIN([qst].[query_sql_text]) AS[Query]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'dbo.usp_GetTargetDeviations')
     AND [rs].[last_execution_time] > DATEADD(HOUR, -2, GETUTCDATE())
     AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qsp].[plan_id], OBJECT_NAME([qsq].[object_id])
--ORDER BY AVG([rs].[avg_cpu_time]) DESC;
ORDER BY AVG([rs].[avg_duration]) DESC;
GO


