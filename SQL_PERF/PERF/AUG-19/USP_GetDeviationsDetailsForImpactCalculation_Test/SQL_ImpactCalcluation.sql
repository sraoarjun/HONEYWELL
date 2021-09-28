/*


set statistics io on
exec [USP_GetDeviationsDetailsForImpactCalculation] 'OPCHDA'
set statistics io off



set statistics io on
exec [USP_GetDeviationsDetailsForImpactCalculation_Test] 'OPCHDA'
set statistics io off

*/


ALTER PROCEDURE [dbo].[USP_GetDeviationsDetailsForImpactCalculation]
	@targetTagType nvarchar(100)
AS
BEGIN
	--SET TRANSACTION ISOLATION LEVEL SNAPSHOT
declare @MonitoringAggnMappingId [uniqueidentifier];
	
	--Declare @MonitoringAggMappingTbl Table
	--(
	--	[Value] [nvarchar](512) NULL,
	--	[DisplayName] [nvarchar](512) NULL
	--);

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
			
	
	CREATE CLUSTERED INDEX IDX ON #TagMonitoringsImpactCal(TagMonitoring_PK_ID)
	(	Select 
			I.Activity_PK_ID as Activity_PK_ID,
			I.SampleTime,
			I.SampleValue,
			I.DeviatingLimit,
			I.IsHighDeviation,
			I.DeviationQuantity,
			CASE
				WHEN TagMonitorings.OPCAggregationName = 'Shift' THEN CEILING(I.Duration)
				ELSE TagMonitorings.SampleFrequency
			END AS SampleFrequency,
			--TagMonitorings.SampleFrequency,
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
			0 AS IsSplitDev					
		FROM  
				#TagMonitoringsImpactCal  TagMonitorings
				join dbo.vw_deviationSamples_indexed i  
				ON TagMonitorings.TagMonitoring_PK_ID = I.TagMonitoring_PK_ID
				
	)					
	UNION All
		(	Select
			I.Activity_PK_ID ,
			I.SampleTime,
			I.SampleValue,
			I.DeviatingLimit,
			I.IsHighDeviation,
			I.DeviationQuantity,
			TagMonitorings.SampleFrequency,
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
			1 AS IsSplitDev		
		FROM  
				#TagMonitoringsImpactCal  TagMonitorings
				join dbo.vw_deviationSample_SplitActivities_Indexex I
				ON TagMonitorings.TagMonitoring_PK_ID = I.TagMonitoring_PK_ID
				
	)
	--ORDER BY Activity_PK_ID, I.SampleTime;							

	DROP Table #TagMonitoringsImpactCal					
	--DROP INDEX IDX ON #TagMonitoringsImpactCal
END
