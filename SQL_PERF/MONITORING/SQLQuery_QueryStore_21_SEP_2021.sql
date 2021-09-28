DECLARE @UTCDateTime_Start DATETIME , @UTCDateTime_End DATETIME ;
DECLARE @LocalTime_Start DATETIME = '2021-09-23 17:35:00.000', @LocalTime_End DATETIME ='2021-09-23 19:50:00.000' ; 

-- 'India Standard Time' to 'UTC' DATETIME
SET @UTCDateTime_Start = @LocalTime_Start AT TIME ZONE 'India Standard Time' AT TIME ZONE 'UTC'
SET @UTCDateTime_End =  @LocalTime_End AT TIME ZONE 'India Standard Time' AT TIME ZONE 'UTC'


--select @UTCDateTime_Start as UTCTimeStart , @UTCDateTime_End as UTCTimeEnd

SELECT
	TOP  25 

     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
	[rs].[runtime_stats_interval_id],
	 --[rs].[avg_cpu_time]/1000.00 as [avg_cpu_time_ms],
	--[rs].[avg_duration]/1000.00 as [avg_duration_ms],
	[rs].[count_executions],
	 OBJECT_NAME([qsq].[object_id]) AS [OBJECT_NAME],
	[qst].[query_sql_text],
	[rs].[avg_cpu_time]/1000000.00 as [avg_cpu_time_sec],
	[rs].[avg_duration]/1000000.00 as [avg_duration_sec],
     [rs].[avg_logical_io_reads],
	 [rs].[avg_query_max_used_memory],
	 [rs].[avg_logical_io_writes],
     [rs].[avg_rowcount],
	 [rs].[last_execution_time] AT TIME ZONE 'India Standard Time'  as [last_execution_time],
	--ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
	[rsi].[start_time] AT TIME ZONE 'India Standard Time' [start_time] ,
     [rsi].[end_time] AT TIME ZONE 'India Standard Time' [end_time]
	 FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
Where 
			rs.last_execution_time > @UTCDateTime_Start 
			and rs.last_execution_time < @UTCDateTime_End
			--and [qsq].[object_id] <> OBJECT_ID(N'usp_InsertTargetProcessingHist')
			--and OBJECT_NAME(qsq.object_id) is not null 
			--and rs.runtime_stats_interval_id = 2 
			--and [rs].[avg_duration]/1000000.00 >= 2.0
				--and [qst].query_sql_text like '%_history%'
	 AND [rs].[execution_type] = 0
	 --AND [qsp].[plan_id] not in (7249,8352,9326)
	 --and rs.runtime_stats_interval_id = 39
--ORDER BY rs.avg_logical_io_reads desc
ORDER BY rs.avg_duration desc 
--ORDER BY rs.avg_logical_io_writes desc 
--ORDER BY rs.avg_cpu_time desc
--ORDER BY rs.avg_query_max_used_memory desc  
GO
