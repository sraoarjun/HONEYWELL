set statistics io , time on 

select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID 
	,a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue,   
     a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName    
     from Activities a   --with (index([IX_Activities_IsSplit_INCLUDE_StartTime_EndTime])) 
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM' )  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM' )  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) 
	 and a.IsSplit=0

set statistics io , time off

GO


set statistics io , time on 

;with cte (Activity_PK_ID) as 
(
select Activity_PK_ID  from Activities a   
     WHERE
	 ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM' )  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM' )  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) 
	 and a.IsSplit=0 
)

select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue,   
     a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName  
from 
	dbo.Activities a where a.Activity_PK_ID in (select Activity_PK_ID from cte)

set statistics io , time off
 
GO

set statistics io , time on

--declare @start_time datetime ='Mar 14 2019  8:30AM', @end_time datetime = 'Mar 14 2019  4:30PM'

drop table if exists #tempActivityPKIDs

select a.Activity_PK_ID into #tempActivityPKIDs
     from Activities a   
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM' AND a.StartTime < 'Mar 14 2019  4:30PM' )  
     OR (a.EndTime >'Mar 14 2019  8:30AM' AND a.EndTime <='Mar 14 2019  4:30PM' )  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) 
	 and a.IsSplit=0 


	 
select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue,   
     a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName  
from 
	dbo.Activities a WHERE a.Activity_PK_ID in (select Activity_PK_ID from #tempActivityPKIDs)


set statistics io , time off
GO


select * into #temp from 
(((select a.Activity_PK_ID 
     from Activities a    
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) and a.IsSplit=0  
     ) UNION ALL(select   a.ActivityHistory_PK_ID as Activity_PK_ID 
     from ActivityHistory a     
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) and a.IsSplit=0  
     )) UNION ALL((select s.SplitActivity_PK_ID  as Activity_PK_ID 
     from SplitActivities s   
     WHERE ((s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
     OR (s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')   
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL))   
     ) UNION ALL(select  s.SplitActivityHistory_PK_ID as Activity_PK_ID     
     from SplitActivitiesHistory s   
     WHERE ((s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
     OR (s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL))   
     )))A

GO

drop table if exists #tempActivities
select a.Activity_PK_ID into #tempActivities  from Activities a    
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) and a.IsSplit=0   


drop table if exists #tempActivityHistory
select   a.ActivityHistory_PK_ID  into #tempActivityHistory
     from ActivityHistory a     
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) and a.IsSplit=0  

	
drop table if exists #tempSplitActivity
select s.SplitActivity_PK_ID  into #tempSplitActivity
     from SplitActivities s   
     WHERE ((s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
     OR (s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')   
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL)) 



drop table if exists #tempSplitActivityHistory
select  s.SplitActivityHistory_PK_ID into #tempSplitActivityHistory   
     from SplitActivitiesHistory s   
     WHERE ((s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
     OR (s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL))   

--select * from #temp


set statistics io  on

(Select * from (((select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue,   
     a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName    
     from Activities a    where a.Activity_PK_ID in (select Activity_PK_ID from #tempActivities)   
		) UNION ALL(select   a.ActivityHistory_PK_ID as Activity_PK_ID ,null  as ParentID, a.TagMonitoring_PK_ID, a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue, a.DeviationQuantity,  
     a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName  
     from ActivityHistory a   where a.ActivityHistory_PK_ID in (select ActivityHistory_PK_ID from #tempActivityHistory)  
  
     )) UNION ALL((select s.SplitActivity_PK_ID  as Activity_PK_ID,  s.Activity_PK_ID as ParentID, s.TagMonitoring_PK_ID, s.LimitType, s.LimitName, s.DetectionTime, s.StartTime, s.EndTime,   
     s.Duration, s.ImpactValue, s.DeviationQuantity,s.TagHighValue, s.TagLowValue, s.TagValue, s.UpdatedBy, s.RemarksStatus, s.IsHighDeviation, s.TagLastValue,s.SplitShiftName  
     from SplitActivities s  where s.SplitActivity_PK_ID in (select SplitActivity_PK_ID from #tempSplitActivity)
     
     ) UNION ALL(select  s.SplitActivityHistory_PK_ID as Activity_PK_ID ,s.Activity_PK_ID  as ParentID, s.TagMonitoring_PK_ID, s.LimitType, s.LimitName, s.DetectionTime, s.StartTime, s.EndTime, s.Duration, s.ImpactValue, s.DeviationQuantity,  
     s.TagHighValue, s.TagLowValue, s.TagValue, s.UpdatedBy, s.RemarksStatus, s.IsHighDeviation, s.TagLastValue,s.SplitShiftName    
     from SplitActivitiesHistory s where s.SplitActivityHistory_PK_ID in (select SplitActivityHistory_PK_ID from #tempSplitActivityHistory)
    ))) C) 

set statistics io  off
