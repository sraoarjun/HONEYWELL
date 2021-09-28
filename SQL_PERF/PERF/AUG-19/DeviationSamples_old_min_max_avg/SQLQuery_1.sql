--declare @activity_pk_id uniqueidentifier = 'D5940C23-89D8-4E1F-931F-C625834BDCDC'
declare @DeviationSample table (activity_pk_id uniqueidentifier )

insert into @DeviationSample 
Values
('9C1FA78C-B9BC-4D1D-B297-4F9271D1487B')
,('059CD2A1-BB7D-45E7-B199-268E3C78E560')
,('D5940C23-89D8-4E1F-931F-C625834BDCDC')

set statistics io on


;with cte (acitivuty_pk_id,TagValue,TagHighValue)
as
(

SELECT s.Activity_PK_ID, TagValue = CASE 
		WHEN t.IsAverageDevValues = '1'
			THEN AVG(d.SampleValue)
		ELSE CASE 
				WHEN a.IsHighDeviation = '1'
					THEN (
							SELECT TOP 1 SampleValue
							FROM DeviationSamples
							WHERE SampleTime <= max(d.SampleTime)
								AND SampleTime > = min(d.SampleTime)
								AND DeviationQuantity = MAX(d.DeviationQuantity)
								AND Activity_PK_ID = s.Activity_PK_ID
							)
				ELSE (
						SELECT TOP 1 SampleValue
						FROM DeviationSamples
						WHERE SampleTime <= max(d.SampleTime)
							AND SampleTime > = min(d.SampleTime)
							AND DeviationQuantity = MAX(d.DeviationQuantity)
							AND Activity_PK_ID = s.Activity_PK_ID
						)
				END
		END,
		TagHighValue =   CASE WHEN a.IsHighDeviation = '1' THEN   
																	(select TOP 1 DeviatingLimit from DeviationSamples where SampleTime <= max(d.SampleTime) 
																	and SampleTime > = min (d.SampleTime) and DeviationQuantity = MAX(d.DeviationQuantity) and Activity_PK_ID = s.activity_pk_id 
																	order by SampleTime desc)
                                
                                   ELSE
                                                        Avg(a.TagHighValue)
                                   END   

FROM @DeviationSample AS s
JOIN [dbo].Activities AS a ON a.Activity_PK_ID = s.Activity_PK_ID
JOIN [dbo].TagMonitorings AS t ON t.TagMonitoring_PK_ID = a.TagMonitoring_PK_ID
JOIN [dbo].DeviationSamples AS d ON d.Activity_PK_ID = a.Activity_PK_ID
--Where a.Activity_PK_ID = @activity_pk_id

GROUP BY t.IsAverageDevValues
	,a.IsHighDeviation
	,s.Activity_PK_ID
)
select * from cte
set statistics io off 