/****** Object:  StoredProcedure [dbo].[USP_GetDeviationsDetailsForImpactCalculation]    Script Date: 2/19/2018 9:36:49 AM ******/
/****** Procedure to get deviation details for impact calculation ******/
ALTER PROCEDURE [dbo].[USP_GetDeviationsDetailsForImpactCalculation]
	@targetTagType nvarchar(max)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
declare @MonitoringAggnMappingId [uniqueidentifier];
	Declare @MonitoringAggMappingTbl Table
	(
		[Value] [nvarchar](512) NULL,
		[DisplayName] [nvarchar](512) NULL
	);
	CREATE TABLE #TagMonitoringsImpactCal
	(
		[TagMonitoring_PK_ID] [uniqueidentifier] NOT NULL,
		[SampleFrequency] [int] NOT NULL,
		[ImpactType] [nvarchar](100) NULL,
		[MaxFactor] [nvarchar](max) NULL,
		[MinFactor] [nvarchar](max) NULL,		
		[OPCAggregationName] [nvarchar](100) NULL,
		[MaxFactorDataSrcName] [nvarchar](max) NULL,
		[MaxFactorTag] [nvarchar](max) NULL,
		[MinFactorDataSrcName] [nvarchar](max) NULL,
		[MinFactorTag] [nvarchar](max) NULL,
		MaxFactorAggregationName [nvarchar](max) NULL,
		MinFactorAggregationName [nvarchar](max) NULL
	);	
	
	set @MonitoringAggnMappingId = (select Top 1 [LookupType_PK_ID]
		FROM [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[LookupTypes] WITH(NOLOCK)
		where [Name] ='Monitoring Aggregation Mapping');
	IF (@MonitoringAggnMappingId IS NULL)
		Begin
			set @MonitoringAggnMappingId = '00000000-0000-0000-0000-000000000000'
		End
	insert into @MonitoringAggMappingTbl
	select [Value],[DisplayName] 
	from Lookups WITH(NOLOCK)
	where LookupType_PK_ID = @MonitoringAggnMappingId;
	insert into #TagMonitoringsImpactCal 
	(  
		[TagMonitoring_PK_ID],
		[SampleFrequency],
		[ImpactType],
		[MaxFactor],
		[MinFactor],		
		[OPCAggregationName] ,
		[MaxFactorDataSrcName],
		[MaxFactorTag],
		[MinFactorDataSrcName],
		[MinFactorTag],
		MaxFactorAggregationName,
		MinFactorAggregationName
	)
	select
		filteredTargets.[TagMonitoring_PK_ID],
		filteredTargets.[SampleFrequency],
		filteredTargets.[ImpactType],
		filteredTargets.[MaxFactor],
		filteredTargets.[MinFactor],	
		filteredTargets.[OPCAggregationName],
		filteredTargets.[MaxFactorDataSrcName],
		filteredTargets.[MaxFactorTag],
		filteredTargets.[MinFactorDataSrcName],
		filteredTargets.[MinFactorTag],
		LookupsMax.Value as MaxFactorAggregationName,
		LookupsMin.Value as MinFactorAggregationName
	FROM
		(select
			[TagMonitoring_PK_ID],
			[SampleFrequency],
			[ImpactType],
			[MaxFactor],
			[MinFactor],	
			[OPCAggregationName],
			[MaxFactorDataSrcName],
			[MaxFactorTag],
			[MinFactorDataSrcName],
			[MinFactorTag]
		 from TagMonitorings
		 where upper([TagType]) = upper(@targetTagType)
		And ImpactType IS NOT NULL) filteredTargets
		 Left join @MonitoringAggMappingTbl LookupsMax
			on (filteredTargets.MaxFactorDataSrcName +'_'+filteredTargets.OPCAggregationName) = LookupsMax.DisplayName 		  					  
		 Left join @MonitoringAggMappingTbl LookupsMin
			on (filteredTargets.MinFactorDataSrcName +'_'+filteredTargets.OPCAggregationName) = LookupsMin.DisplayName; 
			
	
	(	Select
			DeviationSamples.Activity_PK_ID as Activity_PK_ID,
			DeviationSamples.SampleTime,
			DeviationSamples.SampleValue,
			DeviationSamples.DeviatingLimit,
			DeviationSamples.IsHighDeviation,
			DeviationSamples.DeviationQuantity,
			CASE
				WHEN TagMonitorings.OPCAggregationName = 'Shift' THEN CEILING(Activities.Duration)
				ELSE TagMonitorings.SampleFrequency
			END AS SampleFrequency,
			TagMonitorings.ImpactType,
			TagMonitorings.MaxFactor,
			TagMonitorings.MinFactor,
			TagMonitorings.MaxFactorDataSrcName,
			TagMonitorings.MaxFactorTag,
			TagMonitorings.MinFactorDataSrcName,
			TagMonitorings.MinFactorTag, 
			TagMonitorings.OPCAggregationName,
			Activities.ImpactValue,
			Activities.ImpactCycles,
			Activities.ImpactDuration,
			Activities.LastImpactProcessedTime,
			TagMonitorings.MaxFactorAggregationName,
			TagMonitorings.MinFactorAggregationName,
			Activities.StartTime,
			CONVERT(bit, 0) AS IsSplitDev					
		FROM  
				#TagMonitoringsImpactCal  TagMonitorings
				join Activities 
				ON TagMonitorings.TagMonitoring_PK_ID = Activities.TagMonitoring_PK_ID
				join DeviationSamples 
				ON DeviationSamples.Activity_PK_ID = Activities.Activity_PK_ID 
				WHERE 
				(
					(
						Activities.HasDeviationSamples = 1
					)
					And
					(
						(
							Activities.LastImpactProcessedTime IS NULL 
							OR Activities.EndTime is NULL 
							OR (Activities.LastImpactProcessedTime  IS NOT NULL 
								AND Activities.EndTime > Activities.LastImpactProcessedTime)
						)
					) 
					AND 
					(
						(DeviationSamples.SampleTime > Activities.LastImpactProcessedTime) 
						OR	(Activities.LastImpactProcessedTime  IS NULL 
							And DeviationSamples.SampleTime IS NOT NULL)
					) 
				)
	)					
	UNION All
		(	Select
			SplitActivities.SplitActivity_PK_ID as Activity_PK_ID,
			DeviationSamples.SampleTime,
			DeviationSamples.SampleValue,
			DeviationSamples.DeviatingLimit,
			DeviationSamples.IsHighDeviation,
			DeviationSamples.DeviationQuantity,
			TagMonitorings.SampleFrequency,
			TagMonitorings.ImpactType,
			TagMonitorings.MaxFactor,
			TagMonitorings.MinFactor,
			TagMonitorings.MaxFactorDataSrcName,
			TagMonitorings.MaxFactorTag,
			TagMonitorings.MinFactorDataSrcName,
			TagMonitorings.MinFactorTag, 
			TagMonitorings.OPCAggregationName,
			SplitActivities.ImpactValue,
			SplitActivities.ImpactCycles,
			SplitActivities.ImpactDuration,
			SplitActivities.LastImpactProcessedTime,
			TagMonitorings.MaxFactorAggregationName,
			TagMonitorings.MinFactorAggregationName,
			SplitActivities.StartTime,
			CONVERT(bit, 1) AS IsSplitDev		
		FROM  
				#TagMonitoringsImpactCal  TagMonitorings
				join SplitActivities 
				ON TagMonitorings.TagMonitoring_PK_ID = SplitActivities.TagMonitoring_PK_ID
				join DeviationSamples 
				ON DeviationSamples.Activity_PK_ID = SplitActivities.Activity_PK_ID 
				WHERE 
				(
					(
						SplitActivities.HasDeviationSamples = 1
					)
					And
					(
						(
							SplitActivities.LastImpactProcessedTime IS NULL 
							OR SplitActivities.EndTime is NULL 
							OR (SplitActivities.LastImpactProcessedTime  IS NOT NULL 
								AND SplitActivities.EndTime > SplitActivities.LastImpactProcessedTime)
						)
					) 
					AND 
					(
						DeviationSamples.SampleTime >= SplitActivities.StartTime
						
					) 
					AND 
					(
						(DeviationSamples.SampleTime < SplitActivities.EndTime) 
						OR	(SplitActivities.EndTime  IS NULL 
							And DeviationSamples.SampleTime IS NOT NULL)
					)
					AND 
					(
						(DeviationSamples.SampleTime > SplitActivities.LastImpactProcessedTime) 
						OR	(SplitActivities.LastImpactProcessedTime  IS NULL 
							And DeviationSamples.SampleTime IS NOT NULL)
					) 
				)
	)
	ORDER BY Activity_PK_ID, DeviationSamples.SampleTime;							
	DROP Table #TagMonitoringsImpactCal					
	  
END

