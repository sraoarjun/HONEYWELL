USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

/*
Need to use  lookup table for global configuration settings 
a.	Batch Size - (Can be overridden at the archival configuration level)
b.	Enable Purge - On /Off 
c.	Purge cut-off Date in Days – Records older than this date to be purged (Can be overridden at the global level)


Execution Log :
Need to log the purge details :
 
a.	The table the records are purged from
b.	The number of records purged
c.	The date criteria based on which the records are purged (Duration basically the date criteria for the purge).

*/



select 
	l.Application,l.ApplicationDisplayName,l.Asset,l.Description,l.DisplayName,l.LookupValueDataType,l.Name,l.Value,
	lt.Description,lt.Name,lt.Owner
from 
	dbo.Lookups l join dbo.LookupTypes lt on l.LookupType_PK_ID = lt.LookupType_PK_ID

select * from dbo.Lookups where name like '%history%'

select * from dbo.Archival_Config 
select * from dbo.Lookups where name like '%history%'


update dbo.Lookups set Value  = 1940 where name = 'ShiftSummaryHistory_Data_Retention_Days'

select 
	archival_config_id,table_schema,table_name,batch_size,PurgeOnly,filters,is_enabled,db_datetime_last_updated from dbo.Archival_Config 
where 
	is_enabled = 1




select count(1) as cnt from dbo.ShiftSummaryDisplayHistory with (nolock) -- DBO (schema)

select count(1) as cnt from site1.ShiftSummaryDisplayHistory with (nolock) --- SITE 1 (schema)

 select DATEADD(day,-1940,getdate())

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) --- 

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) where Shift_EndTime < DATEADD(day,-1940,getdate())



begin tran
exec dbo.Sp_Arc_RunArchiving

rollback tran


exec sp_whoisactive


select * from dbo.Archival_Config where is_enabled = 1 


select * from dbo.Lookups



update dbo.Archival_Config set is_enabled = 0 where archival_config_id <> 6



begin tran 


/*
Use the lookup table for global configuration 

Purging date criteria - At global level
Enabled/Disabled : On/OFF

Number of records purged and its duration (Execution log)

batch size in lookups 

Need to decide which settings can be overriden at the archival configuration level from global level

*/


select * from [dbo].[ShiftSummaryDisplayHistory]
select * from [site1].[ShiftSummaryDisplayHistory]





select 
	count(case when Shift_EndTime < '2017-06-30 12:00:00.000' then 1 end) as sumShiftCount_lessThanJuly2017, 
	count(case when Shift_EndTime > '2017-06-30 12:00:00.000' then 1 end) as sumShiftCount_GreaterThanJuly2017, 
	count(1) as Totalcnt
 from dbo.ShiftSummaryHistory with (nolock)

 select 
	62918 + 4322 





	
insert into tempdb..Staging_IDs 

select * from tempdb..Staging_IDs 


select top (1000) ShiftSummaryHistory_PK_ID from dbo.ShiftSummaryHistory  where Shift_EndTime < 'Jan  3 2017  7:44PM'