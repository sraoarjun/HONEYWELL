
drop table if exists #MonitoringAggMappingTbl, #TagMonitoringsImpactCal



declare @targetTagType nvarchar(100) = 'OPCHDA'
declare @MonitoringAggnMappingId [uniqueidentifier];
	
	
	CREATE TABLE #MonitoringAggMappingTbl
	(
		[Value] [nvarchar](512) NULL,
		[DisplayName] [nvarchar](512) NULL
	)

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
		MaxFactorAggregationName [nvarchar](512) NULL,
		MinFactorAggregationName [nvarchar](512) NULL
	);	
	--CREATE NONCLUSTERED INDEX IDX ON #TagMonitoringsImpactCal(TagMonitoring_PK_ID)
	
	set @MonitoringAggnMappingId = (select Top 1 [LookupType_PK_ID]
		FROM [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[LookupTypes]
		where [Name] ='Monitoring Aggregation Mapping');

	IF (@MonitoringAggnMappingId IS NULL)
		Begin
			set @MonitoringAggnMappingId = '00000000-0000-0000-0000-000000000000'
		End

	insert into #MonitoringAggMappingTbl
	select [Value],[DisplayName] 
	from Lookups
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
		 where [TagType] = @targetTagType
		And ImpactType IS NOT NULL) filteredTargets
		 Left join #MonitoringAggMappingTbl LookupsMax
			on (filteredTargets.MaxFactorDataSrcName +'_'+filteredTargets.OPCAggregationName) = LookupsMax.DisplayName 		  					  
		 Left join #MonitoringAggMappingTbl LookupsMin
			on (filteredTargets.MinFactorDataSrcName +'_'+filteredTargets.OPCAggregationName) = LookupsMin.DisplayName; 
			
	
--drop index idx on #TagMonitoringsImpactCal
--CREATE CLUSTERED INDEX IDX ON #TagMonitoringsImpactCal(TagMonitoring_PK_ID)

--set statistics io on

ALTER view dbo.vw_deviationSamples_indexed
WITH SCHEMABINDING AS
select		d.DeviationSample_PK_ID,
			d.Activity_PK_ID as Activity_PK_ID,
			d.SampleTime,
			d.SampleValue,
			d.DeviatingLimit,
			d.IsHighDeviation,
			d.DeviationQuantity,
			a.ImpactValue,
			a.ImpactCycles,
			a.ImpactDuration,
			a.LastImpactProcessedTime,
			a.StartTime,
			d.TagMonitoring_PK_ID,
			a.Duration
FROM  
				
				dbo.Activities a
				join dbo.DeviationSamples d
				ON d.Activity_PK_ID = a.Activity_PK_ID   
				WHERE 
				(
					(
						a.HasDeviationSamples = 1
					)
					And
					(
						(
							a.LastImpactProcessedTime IS NULL 
							OR a.EndTime is NULL 
							OR (a.LastImpactProcessedTime  IS NOT NULL 
								AND a.EndTime > a.LastImpactProcessedTime)
						)
					) 
					AND 
					(
						(d.SampleTime > a.LastImpactProcessedTime) 
						OR	(a.LastImpactProcessedTime  IS NULL 
							And d.SampleTime IS NOT NULL)
					) 
				)
GO
drop index IX_VEMPInfo on dbo.vw_deviationSamples_indexed

CREATE UNIQUE CLUSTERED INDEX IX_VEMPInfo 
	ON dbo.vw_deviationSamples_indexed
	(DeviationSample_PK_ID,Activity_PK_ID ,
	SampleTime,
	SampleValue,
	DeviatingLimit,
	IsHighDeviation,
	DeviationQuantity,
	ImpactValue,
	ImpactCycles,
	ImpactDuration,
	LastImpactProcessedTime,
	StartTime,
	TagMonitoring_PK_ID,
	Duration
	)
	
	select * from dbo.vw_deviationSamples_indexed


	GO



	
Select
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


	GO


Select
			i.Activity_PK_ID as Activity_PK_ID,
			i.SampleTime,
			i.SampleValue,
			i.DeviatingLimit,
			i.IsHighDeviation,
			i.DeviationQuantity,
			CASE
				WHEN TagMonitorings.OPCAggregationName = 'Shift' THEN CEILING(I.Duration)
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
			I.ImpactValue,
			I.ImpactCycles,
			I.ImpactDuration,
			I.LastImpactProcessedTime,
			TagMonitorings.MaxFactorAggregationName,
			TagMonitorings.MinFactorAggregationName,
			I.StartTime,
			CONVERT(bit, 0) AS IsSplitDev					
		FROM  
				#TagMonitoringsImpactCal  TagMonitorings
				join dbo.vw_deviationSamples_indexed I
				ON
				TagMonitorings.TagMonitoring_PK_ID = I.TagMonitoring_PK_ID
				



				
		
