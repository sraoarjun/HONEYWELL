
SELECT

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
--WHERE 
--	[qsq].[object_id] = OBJECT_ID(N'dbo.usp_GetTargetDeviations')
     --AND 
		--[rs].[last_execution_time] > DATEADD(MINUTE, -10, GETUTCDATE())
		--[rs].[last_execution_time] > '2021-08-04 16:55:00.0000000 +00:00'
Where 
		[qst].[query_sql_text] LIKE '%TagWeightage%'
		and rs.last_execution_time > DATEADD(MINUTE, -1, GETUTCDATE())
	 AND [rs].[execution_type] = 0
ORDER BY rs.avg_duration desc
GO



