set statistics io on

 select s.SplitActivity_PK_ID  as Activity_PK_ID 
     from SplitActivities s 
     WHERE ((s.StartTime >='Mar 14 2019  8:30AM'AND s.StartTime <'Mar 14 2019  4:30PM')  
     OR (s.EndTime >'Mar 14 2019  8:30AM'AND s.EndTime <='Mar 14 2019  4:30PM')  
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime >'Mar 14 2019  4:30PM')   
     OR (s.StartTime < 'Mar 14 2019  8:30AM' AND s.EndTime IS NULL))  

set statistics io off	
go

set statistics io on
	select * from
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
set statistics io off


-- Combine the resultset into one using the Union all statement with an outer select

set statistics io on

select * from
(
	select 
		s.SplitActivity_PK_ID  as Activity_PK_ID 
		 from 
		 SplitActivities s 
		 where (
			(s.StartTime >='Aug 14 2019  8:30AM'AND s.StartTime <'Aug 14 2019  4:30PM')  
		OR 
			(s.EndTime >'Aug 14 2019  8:30AM'AND s.EndTime <='Aug 14 2019  4:30PM') 
		 )
    
		union 

		 select 
			s.SplitActivity_PK_ID  as Activity_PK_ID 
		 from 
			SplitActivities s 
		where(
			(s.StartTime < 'Aug 14 2019  8:30AM' AND s.EndTime >'Aug 14 2019  4:30PM')   
		 OR 
			(s.StartTime < 'Aug 14 2019  8:30AM' AND s.EndTime IS NULL)

		 )
)A


set statistics io off


 --------------ACTIVITIES

set statistics io on

	  select a.Activity_PK_ID 
     from Activities a    
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM')  
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM')   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL)) and a.IsSplit=0  
     
set statistics io off


set statistics io on

	 select a.Activity_PK_ID 
     from Activities a    
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM'))
	 and a.IsSplit = 0
	 
	 select a.Activity_PK_ID 
     from Activities a  
	 Where (
     (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM' and a.IsSplit = 0)   
     OR (a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL and a.IsSplit = 0)) 


set statistics io off


-- Combine the resultset into one using the Union all statement with an outer select


set statistics io on

select * from 
(
	
	select a.Activity_PK_ID 
     from Activities a    
     WHERE ((a.StartTime >='Mar 14 2019  8:30AM'AND a.StartTime <'Mar 14 2019  4:30PM')  
     OR (a.EndTime >'Mar 14 2019  8:30AM'AND a.EndTime <='Mar 14 2019  4:30PM'))
	 and a.IsSplit = 0
	 
	  union  

	 select a.Activity_PK_ID 
     from Activities a  
	 Where 
	 (
		(
			a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime >'Mar 14 2019  4:30PM' --and a.IsSplit = 0
		)   
     OR (
			a.StartTime < 'Mar 14 2019  8:30AM' AND a.EndTime IS NULL --and a.IsSplit = 0
		 )
	 )
	 and a.IsSplit = 0

)A
set statistics io off