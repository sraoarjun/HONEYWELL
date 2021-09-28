CREATE VIEW dbo.vw_deviationSamples_indexed
WITH SCHEMABINDING AS
select	
	

	d.DeviationSample_PK_ID,
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

drop index IX_vw_deviationSamples_indexed on dbo.vw_deviationSamples_indexed

CREATE UNIQUE CLUSTERED INDEX IX_vw_deviationSamples_indexed 
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
	


CREATE VIEW dbo.vw_deviationSample_SplitActivities_Indexex 
WITH SCHEMABINDING AS

	Select
			s.SplitActivity_PK_ID as Activity_PK_ID,
			d.SampleTime,
			d.SampleValue,
			d.DeviatingLimit,
			d.IsHighDeviation,
			d.DeviationQuantity,
			s.ImpactValue,
			s.ImpactCycles,
			s.ImpactDuration,
			s.LastImpactProcessedTime,
			s.StartTime,
			d.TagMonitoring_PK_ID
				
	FROM  
				 dbo.SplitActivities  s  join dbo.DeviationSamples  d 
				ON d.Activity_PK_ID = s.Activity_PK_ID 
				WHERE 
				(
					(
						s.HasDeviationSamples = 1
					)
					And
					(
						(
							s.LastImpactProcessedTime IS NULL 
							OR s.EndTime is NULL 
							OR (s.LastImpactProcessedTime  IS NOT NULL 
								AND s.EndTime > s.LastImpactProcessedTime)
						)
					) 
					AND 
					(
						d.SampleTime >= s.StartTime
						
					) 
					AND 
					(
						(d.SampleTime < s.EndTime) 
						OR	(s.EndTime  IS NULL 
							And d.SampleTime IS NOT NULL)
					)
					AND 
					(
						(d.SampleTime > s.LastImpactProcessedTime) 
						OR	(s.LastImpactProcessedTime  IS NULL 
							And d.SampleTime IS NOT NULL)
					) 
				)		

drop index IX_vw_deviationSample_SplitActivities_Indexex on dbo.vw_deviationSample_SplitActivities_Indexex

CREATE UNIQUE CLUSTERED INDEX IX_vw_deviationSample_SplitActivities_Indexex 
	ON dbo.vw_deviationSample_SplitActivities_Indexex
	(
			Activity_PK_ID,
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
			TagMonitoring_PK_ID
	)
GO



select * from vw_deviationSamples_indexed
select * from dbo.vw_deviationSample_SplitActivities_Indexex