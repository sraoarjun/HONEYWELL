set statistics io on

select *
--into #temp
from 
(((select a.Activity_PK_ID 
     from Activities a    
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) and a.IsSplit=0  
     )
	 UNION ALL
	 ((select s.SplitActivity_PK_ID  as Activity_PK_ID 
     from SplitActivities s   
     WHERE ((s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
     OR (s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')   
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL))   
     ))))A
set statistics io off


select Activity_PK_ID from 
(

select 
	s.SplitActivity_PK_ID  as Activity_PK_ID 
     from 
	 SplitActivities s 
     where (
		(s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
	OR 
		(s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM') 
	 )
    
	union 

	 select 
		s.SplitActivity_PK_ID  as Activity_PK_ID 
     from 
		SplitActivities s 
	where(
		(s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')   
     OR 
		(s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL)

	 )


)A

	 




	