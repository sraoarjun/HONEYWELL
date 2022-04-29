USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

/*
Need to use  lookup table for global configuration settings 
a.	Batch Size - (Can be overridden at the archival configuration level)
b.	Enable Purge - On /Off 
c.	Purge cut-off Date in Days – Records older than this date to be purged (Can be overridden at the archival configuration level)


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
where lt.name Like '%purge%'

select * from dbo.Lookups where name like '%history%'

select * from dbo.Archival_Config 
select * from dbo.Lookups where name like '%history%'


update dbo.Lookups set Value  = 1908 where name = 'ShiftSummaryHistory_Data_Retention_Days'


select * from dbo.Lookups where LookupType_PK_ID = 'C77C866E-B81D-4A2C-BFC8-BB253E7CEDFD' and Lookup_PK_ID <> 'A34CA610-82B1-4841-A590-EAE64B97EBCB'

select 
	archival_config_id,table_schema,table_name,override_batch_size,override_history_data_retention_days,PurgeOnly,filters,is_enabled,db_datetime_last_updated from dbo.Archival_Config 
where 
	is_enabled = 1



	select * from dbo.Lookups where Name = 'ShiftSummaryHistory_Data_Retention_Days' 

	
	

select count(1) as cnt from dbo.ShiftSummaryDisplayHistory with (nolock) -- DBO (schema)

select count(1) as cnt from site1.ShiftSummaryDisplayHistory with (nolock) --- SITE 1 (schema)

 select DATEADD(day,-1908,getdate())

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) --- 

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) where Shift_EndTime < DATEADD(day,-1908,getdate())

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) where Shift_EndTime < DATEADD(day,-1940,getdate())

begin tran
exec dbo.Sp_Arc_RunArchiving



rollback tran


exec sp_whoisactive


select * from dbo.Archival_Config where is_enabled = 1 






select * from dbo.Lookups








select * from [dbo].[ShiftSummaryDisplayHistory]
select * from [site1].[ShiftSummaryDisplayHistory]





select 
	count(case when Shift_EndTime < '2017-06-30 12:00:00.000' then 1 end) as sumShiftCount_lessThanJuly2017, 
	count(case when Shift_EndTime > '2017-06-30 12:00:00.000' then 1 end) as sumShiftCount_GreaterThanJuly2017, 
	count(1) as Totalcnt
 from dbo.ShiftSummaryHistory with (nolock)

 select 
	62918 + 4322 






	USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO


select * from dbo.Lookups where LookupType_PK_ID = 'C77C866E-B81D-4A2C-BFC8-BB253E7CEDFD'

select 
	archival_config_id,table_schema,table_name,override_batch_size,override_history_data_retention_days,PurgeOnly,filters,is_enabled,db_datetime_last_updated from dbo.Archival_Config 
where 
	is_enabled = 1

select count(1) as cnt from dbo.ShiftSummaryDisplayHistory with (nolock) -- DBO (schema)

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) where Shift_EndTime < DATEADD(day,-1908,getdate()) --30043

select count(1) as cnt from dbo.ShiftSummaryHistory with (nolock) where Shift_EndTime < DATEADD(day,-1940,getdate()) --5520


begin tran
exec dbo.Sp_Arc_RunArchiving



rollback tran




select * from dbo.Archival_Execution_Log with (nolock)

update dbo.Archival_Config set override_batch_size = null where is_enabled = 1 
update dbo.Archival_Config set override_history_data_retention_days = null where is_enabled = 1 




select * from dbo.Archival_Execution_Log


select override_batch_size , override_history_data_retention_days from dbo.Archival_Config where is_enabled = 1 



select * from dbo.Archival_Execution_Log



