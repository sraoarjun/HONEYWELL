
set statistics io , time on


Select * from (

		(

		select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue, 
			a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName 
			from Activities a  
			WHERE ((a.StartTime >='Sep 20 2021  6:00AM'AND a.StartTime <'Sep 20 2021  7:00AM')
			OR (a.EndTime >'Sep 20 2021  6:00AM'AND a.EndTime <='Sep 20 2021  7:00AM')
			OR (a.StartTime < 'Sep 20 2021  6:00AM' AND a.EndTime >'Sep 20 2021  7:00AM')
			OR (a.StartTime < 'Sep 20 2021  6:00AM' AND a.EndTime IS NULL)) and a.IsSplit=0
		) 
					)C
					--UNION ALL 
					
					--(select s.SplitActivity_PK_ID  as Activity_PK_ID,  s.Activity_PK_ID as ParentID, s.TagMonitoring_PK_ID, s.LimitType, s.LimitName, s.DetectionTime, s.StartTime, s.EndTime, 
					--s.Duration, s.ImpactValue, s.DeviationQuantity,s.TagHighValue, s.TagLowValue, s.TagValue, s.UpdatedBy, s.RemarksStatus, s.IsHighDeviation, s.TagLastValue,s.SplitShiftName  
					--from SplitActivities s 
					--WHERE ((s.StartTime >='Sep 20 2021  6:00AM'AND s.StartTime <'Sep 20 2021  7:00AM')
					--OR (s.EndTime >'Sep 20 2021  6:00AM'AND s.EndTime <='Sep 20 2021  7:00AM')
					--OR (s.StartTime < 'Sep 20 2021  6:00AM' AND s.EndTime >'Sep 20 2021  7:00AM')
					--OR (s.StartTime < 'Sep 20 2021  6:00AM' AND s.EndTime IS NULL))					
					--))  C


set statistics io , time off 

GO

set statistics io , time on

select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue, 
			a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName 
			from Activities a  
			WHERE ((a.StartTime >='Sep 20 2021  6:00AM'AND a.StartTime <'Sep 20 2021  7:00AM')
			OR (a.EndTime >'Sep 20 2021  6:00AM'AND a.EndTime <='Sep 20 2021  7:00AM')
			OR (a.StartTime < 'Sep 20 2021  6:00AM' AND a.EndTime >'Sep 20 2021  7:00AM')
			OR (a.StartTime < 'Sep 20 2021  6:00AM' AND a.EndTime IS NULL)) and a.IsSplit=0
			
set statistics io , time off 


drop INDEX [IX-test_Acti] on [dbo].[Activities]

CREATE NONCLUSTERED INDEX [IX-test_Acti]
ON [dbo].[Activities] ([IsSplit])
INCLUDE ([StartTime],[EndTime],[Activity_PK_ID])


drop INDEX [IX-test_Acti-1] on [dbo].[Activities]

CREATE NONCLUSTERED INDEX [IX-test_Acti-1]
ON [dbo].[Activities] ([IsSplit],[StartTime],[EndTime])
INCLUDE ([Activity_PK_ID])



drop INDEX [IX-test_Acti-2] on [dbo].[Activities]

CREATE NONCLUSTERED INDEX [IX-test_Acti-2]
ON [dbo].[Activities] ([EndTime])
INCLUDE ([Activity_PK_ID])





set statistics io on

select * from 
(
	
	select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue, 
			a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName 
			from Activities a     
     WHERE ((a.StartTime >='Sep 20 2021  6:00AM'AND a.StartTime <'Sep 20 2021  7:00AM')  
     OR (a.EndTime >'Sep 20 2021  6:00AM'AND a.EndTime <='Sep 20 2021  7:00AM'))
	 and a.IsSplit = 0
	 
	  union  all

	 select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue, 
			a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName 
			  
     from Activities a  
	 Where 
	 (
		(
			a.StartTime < 'Sep 20 2021  6:00AM' AND a.EndTime >'Sep 20 2021  7:00AM' --and a.IsSplit = 0
		)   
     OR (
			a.StartTime < 'Sep 20 2021  6:00AM' AND a.EndTime IS NULL --and a.IsSplit = 0
		 )
	 )
	 and a.IsSplit = 0

)A
OPTION (QUERYTRACEON 9481)
set statistics io off

	