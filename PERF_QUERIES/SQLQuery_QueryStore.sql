DECLARE @UTCDateTime_Start DATETIME , @UTCDateTime_End DATETIME ;
DECLARE @LocalTime_Start DATETIME = '2021-08-10 14:15:00.000', @LocalTime_End DATETIME ='2021-08-10 16:00:00.000' ; 

-- 'India Standard Time' to 'UTC' DATETIME
SET @UTCDateTime_Start = @LocalTime_Start AT TIME ZONE 'India Standard Time' AT TIME ZONE 'UTC'
SET @UTCDateTime_End =  @LocalTime_End AT TIME ZONE 'India Standard Time' AT TIME ZONE 'UTC'

SELECT
	TOP  25 

     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
	[rs].[runtime_stats_interval_id],
	 [rs].[count_executions],
    [rs].[avg_cpu_time]/1000.00 as [avg_cpu_time_ms],
	[rs].[avg_duration]/1000.00 as [avg_duration_ms],
	[rs].[avg_cpu_time]/1000000.00 as [avg_cpu_time_sec],
	[rs].[avg_duration]/1000000.00 as [avg_duration_sec],
     [rs].[avg_logical_io_reads],
     [rs].[avg_rowcount],
	 OBJECT_NAME([qsq].[object_id]) AS [OBJECT_NAME],
     [qst].[query_sql_text],
	 ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan]),
	 GETDATE() as DATE_CURRENT,
	 GETUTCDATE() as UTC_DATE_CURRENT,
     [rsi].[start_time],
     [rsi].[end_time],
	 [rs].[last_execution_time]
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
			--rs.last_execution_time > DATEADD(DAY, -1, GETUTCDATE())
			rs.last_execution_time > @UTCDateTime_Start 
			and rs.last_execution_time < @UTCDateTime_End
			--and [qsq].[object_id] = OBJECT_ID(N'dbo.sp_GetAssetCmtsAndRespsForUser')
			--and 
			--	[qst].query_sql_text like '%CommentCategory%'
	 AND [rs].[execution_type] = 0
ORDER BY rs.avg_logical_io_reads desc
--ORDER BY rs.avg_duration desc 
GO






DECLARE @UTCDateTime_Start DATETIME , @UTCDateTime_End DATETIME ;
DECLARE @LocalTime_Start DATETIME = '2021-08-09 14:45:00.000', @LocalTime_End DATETIME ='2021-08-09 16:45:00.000' ; 

-- 'India Standard Time' to 'UTC' DATETIME
SET @UTCDateTime_Start = @LocalTime_Start AT TIME ZONE 'India Standard Time' AT TIME ZONE 'UTC'
SET @UTCDateTime_End =  @LocalTime_End AT TIME ZONE 'India Standard Time' AT TIME ZONE 'UTC'

select @LocalTime_Start as LocalTimeStart, @LocalTime_End as LocalTimeEnd , @UTCDateTime_Start as UTCTimeStart ,
		@UTCDateTime_End as UTCTimeEnd 


SELECT
	TOP  25 

     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
	[rs].[runtime_stats_interval_id],
	 [rs].[count_executions],
    [rs].[avg_cpu_time]/1000.00 as [avg_cpu_time_ms],
	[rs].[avg_duration]/1000.00 as [avg_duration_ms],
	[rs].[avg_cpu_time]/1000000.00 as [avg_cpu_time_sec],
	[rs].[avg_duration]/1000000.00 as [avg_duration_sec],
     [rs].[avg_logical_io_reads],
     [rs].[avg_rowcount],
	 OBJECT_NAME([qsq].[object_id]) AS [OBJECT_NAME],
     [qst].[query_sql_text],
	 ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan]),
	 GETDATE() as DATE_CURRENT,
	 GETUTCDATE() as UTC_DATE_CURRENT,
     [rsi].[start_time],
     [rsi].[end_time],
	 [rs].[last_execution_time]
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
--	[qsq].[object_id] = OBJECT_ID(N'dbo.sp_GetAllStandingOrdersLite')
     --AND 
		--[rs].[last_execution_time] > DATEADD(MINUTE, -10, GETUTCDATE())
		--[rs].[last_execution_time] > '2021-08-04 16:55:00.0000000 +00:00'
--Where 
--AND		[qst].[query_sql_text] LIKE '%(@StandingOrderLockingTimeout int)UPDATE standingOrders%'
WHERE 
		--rs.last_execution_time > DATEADD(DAY, -1, GETUTCDATE())
		rs.last_execution_time > @UTCDateTime_Start and rs.last_execution_time < @UTCDateTime_End
AND 
		[rs].[execution_type] = 0

ORDER BY rs.avg_duration desc 
GO









