--declare @activity_pk_id uniqueidentifier = 'D5940C23-89D8-4E1F-931F-C625834BDCDC'
declare @DeviationSample table (activity_pk_id uniqueidentifier )

insert into @DeviationSample 
Values
('9C1FA78C-B9BC-4D1D-B297-4F9271D1487B')
,('059CD2A1-BB7D-45E7-B199-268E3C78E560')
,('D5940C23-89D8-4E1F-931F-C625834BDCDC')

set statistics io on

select * into #temp from @DeviationSample

;with cte  (acitivity_pk_id,minSampleTime,maxSampleTime,maxDeviationQty,AvgSampleValue)
as
(
	select d.Activity_PK_ID,min(SampleTime) as minSampleTime,max(SampleTime) as maxSampleTime,max(DeviationQuantity)
	as maxDeviationQty ,avg(SampleValue) as AvgSampleValue
	from dbo.DeviationSamples d 
	where exists (select 1 from #temp b where d.Activity_PK_ID = b.activity_pk_id)
	group by Activity_PK_ID
)
--select * from cte

SELECT s.Activity_PK_ID, TagValue = CASE 
		WHEN t.IsAverageDevValues = '1'
			THEN cte.AvgSampleValue
		ELSE CASE 
				WHEN a.IsHighDeviation = '1'
					THEN (
							SELECT TOP 1 SampleValue
							FROM DeviationSamples
							WHERE SampleTime <= cte.maxSampleTime
								AND SampleTime > = cte.minSampleTime
								AND DeviationQuantity = cte.maxDeviationQty
								AND Activity_PK_ID = s.Activity_PK_ID
							)
				ELSE (
						SELECT TOP 1 SampleValue
						FROM DeviationSamples
						WHERE SampleTime <= cte.maxSampleTime
							AND SampleTime > = cte.minSampleTime
							AND DeviationQuantity = cte.AvgSampleValue
							AND Activity_PK_ID = s.Activity_PK_ID
						)
				END
		END,
		TagHighValue =   CASE WHEN a.IsHighDeviation = '1' THEN   
							(select TOP 1 DeviatingLimit from DeviationSamples 
							where SampleTime <= cte.maxSampleTime 
							and SampleTime > = cte.minSampleTime 
							and DeviationQuantity = cte.maxDeviationQty 
							and Activity_PK_ID = s.activity_pk_id 
							order by SampleTime desc)
                                
                                   ELSE
                                         Avg(a.TagHighValue)
                                   END   

FROM @DeviationSample AS s join cte on s.activity_pk_id = cte.acitivity_pk_id
JOIN [dbo].Activities AS a ON a.Activity_PK_ID = s.Activity_PK_ID
JOIN [dbo].TagMonitorings AS t ON t.TagMonitoring_PK_ID = a.TagMonitoring_PK_ID
JOIN [dbo].DeviationSamples AS d ON d.Activity_PK_ID = a.Activity_PK_ID


GROUP BY t.IsAverageDevValues
--	,a.IsHighDeviation
	,s.Activity_PK_ID

set statistics io off 