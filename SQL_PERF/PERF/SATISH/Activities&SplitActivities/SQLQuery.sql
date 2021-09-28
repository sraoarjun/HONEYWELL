
set statistics io , time on 
	
select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID 
	,a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue,   
     a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName    
     from Activities a  
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM' )  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM' )  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) 
	 and a.IsSplit=0


 


drop table if exists #tempActivityPKIDs

select a.Activity_PK_ID into #tempActivityPKIDs
     from Activities a   
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM' )  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM' )  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) 
	 and a.IsSplit=0


	
select a.Activity_PK_ID, null as ParentID, a.TagMonitoring_PK_ID 
	,a.LimitType, a.LimitName, a.DetectionTime, a.StartTime, a.EndTime, a.Duration, a.ImpactValue,   
     a.DeviationQuantity, a.TagHighValue, a.TagLowValue, a.TagValue, a.UpdatedBy, a.RemarksStatus, a.IsHighDeviation, a.TagLastValue,a.SplitShiftName    
     
from 
	dbo.Activities a WHERE a.Activity_PK_ID in (select Activity_PK_ID from #tempActivityPKIDs)


set statistics io , time off
GO



drop index if exists FI_IX_SplitActivities_Test on dbo.SplitActivities
go
CREATE NONCLUSTERED INDEX FI_IX_SplitActivities_Test
ON dbo.SplitActivities(StartTime)
--INCLUDE(EmpName, HireDate) --Including remaining columns in the index
WHERE EndTime IS NULL 
GO


