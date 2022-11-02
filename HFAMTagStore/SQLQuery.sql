USE [HFAMTagStore1]
GO

SELECT
t.name,
[RowCount] = SUM
(
CASE
WHEN (p.index_id < 2) AND (a.type = 1) THEN p.rows
ELSE 0
END
)
FROM
sys.tables t
INNER JOIN sys.partitions p
ON t.object_id = p.object_id
INNER JOIN sys.allocation_units a
ON p.partition_id = a.container_id
GROUP BY
t.name
ORDER BY [RowCount] DESC



select * from INFORMATION_SCHEMA.tables where TABLE_NAME like '%NARJobRuns%'
select * from INFORMATION_SCHEMA.tables where TABLE_NAME like '%Comm%'

select * from HFAMSchema1.Analytics_Inst_NARJobRuns


exec sp_pkeys 'Analytics_Staged_AlarmInstances','HFAMSchema1'
exec sp_fkeys 'Analytics_Staged_AlarmInstances','HFAMSchema1'

exec sp_pkeys 'Analytics_Inst_NARJobRuns','HFAMSchema1'
exec sp_fkeys 'Analytics_Inst_NARJobRuns','HFAMSchema1'


exec sp_pkeys 'Analytics_Inst_NARJobRunResults','HFAMSchema1'
exec sp_fkeys 'Analytics_Inst_NARJobRunResults','HFAMSchema1'


select * from HFAMSChema1.Analytics_Inst_NARJobRunResults


exec sp_pkeys 'Analytics_Staged_AlarmInstances','HFAMSchema1'


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
AND TABLE_NAME = 'Analytics_Staged_AlarmInstances' AND TABLE_SCHEMA = 'HFAMSchema1'
order by ORDINAL_POSITION




select JobRunId, count(1) as cnt  from HFAMSchema1.Analytics_Staged_AlarmInstances
 group by JobRunId order by cnt desc 

select JobRunId , EventId ,count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances
 group by JobRunId , EventId  order by cnt desc 

select  EventId ,count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances
 group by EventId  order by cnt desc 

 
select JobRunId, count(1) as cnt  from  HFAMSchema1.Analytics_Inst_NARJobRuns
 group by JobRunId order by cnt desc 



HFAMSchema1.Analytics_Inst_NARJobRuns


select * from HFAMSchema1.Analytics_Staged_AlarmInstances



select JobRunId, MapId, OPName, TagName, BlockName, IntervalIdentifier , count(1) as cnt from HFAMSchema1.Analytics_Staged_DistinctAlarms
 group by JobRunId, MapId, OPName, TagName, BlockName , IntervalIdentifier  order by cnt desc 



select * from HFAMSchema1.Analytics_Staged_AlarmInstances
select * from HFAMSchema1.Analytics_Staged_DistinctAlarms
select * from HFAMSchema1.Analytics_Inst_NARJobRuns




exec sp_pkeys 'Analytics_Staged_AlarmInstances','HFAMSchema1'
exec sp_fkeys 'Analytics_Staged_AlarmInstances','HFAMSchema1'
exec sp_pkeys 'Analytics_Inst_NARJobRuns','HFAMSchema1'

exec sp_pkeys 'Analytics_Staged_DistinctAlarms','HFAMSchema1'
exec sp_fkeys 'Analytics_Staged_DistinctAlarms','HFAMSchema1'

exec sp_pkeys 'Analytics_Inst_NARJobRuns','HFAMSchema1'
exec sp_fkeys 'Analytics_Inst_NARJobRuns','HFAMSchema1'




select * from HFAMSchema1.Analytics_Inst_NARJobRuns
select * from HFAMSchema1.Analytics_Inst_NARJobRunResults

--'Where HFAMSchema1.Analytics_Staged_AlarmInstances HFAM_Ai join HFAMSchema1.Analytics_Inst_NARJobRuns HFAM_Jr on 
--HFAM_Ai.JobRunId = HFAM_Jr.JobRunId where HFAM_Jr.JobStartTime < {Date_Parameter}'
 
select * from HFAMSchema1.Analytics_Inst_NARJobRunResults narJRR  inner join HFAMSchema1.Analytics_Inst_NARJobRuns narJR on 
narJRR.JobRunId = narJR.JobRunId where narJR.JobStartTime <= DATEADD(DAY,-180,GETDATE())


select * from HFAMSchema1.Analytics_Inst_NARJobRuns WHERE HFAMSchema1.Analytics_Inst_NARJobRuns.JobStartTime <= {Date_Parameter}

 
 --update HFAMSchema1.Analytics_Inst_NARJobRuns
 -- set JobStartTime = DATEADD(year,-1,JobStartTime)


 select * from dbo.Purge_Error_Log

 select * from dbo.Purge_Config

 select * from dbo.Purge_Settings_Config

 select * from dbo.Purge_Execution_Log


 
begin tran 

	exec dbo.usp_startpurge

rollback tran


dbcc opentran



select * from HFAMSchema1.Analytics_Inst_NARJobRunResults

exec sp_pkeys 'Analytics_Inst_NARJobRunResults','HFAMSchema1'
exec sp_fkeys 'Analytics_Inst_NARJobRunResults','HFAMSchema1'




select datediff(day ,getdate(),'2021-08-21 00:01:00.000')


select count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances --18702
select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRunResults  -- 40
select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRuns -- 2


delete top (1000) HFAMSchema1.Analytics_Staged_AlarmInstances  from HFAMSchema1.Analytics_Staged_AlarmInstances inner join HFAMSchema1.Analytics_Inst_NARJobRuns  on   HFAMSchema1.Analytics_Staged_AlarmInstances.JobRunId = HFAMSchema1.Analytics_Inst_NARJobRuns.JobRunId where HFAMSchema1.Analytics_Inst_NARJobRuns.JobStartTime <= getdate() -180


select * from HFAMSchema1.Analytics_Inst_NARJobRuns



exec sp_pkeys 'Analytics_Staged_AlarmInstances','HFAMSchema1'
exec sp_pkeys 'Analytics_Staged_DistinctAlarms','HFAMSchema1'
exec sp_pkeys 'Analytics_Inst_NARJobRunResults','HFAMSchema1'
exec sp_pkeys 'Analytics_Inst_NARJobRuns','HFAMSchema1'
exec sp_pkeys 'Inst_JobRunsStatusHistory','HFAMSchema1'



update dbo.Purge_Config set history_retention_days_override = 440 where history_retention_days_override = 180

update dbo.Purge_Config set history_retention_days_override = 180 where history_retention_days_override = 440


update dbo.Purge_Config set purge_status = 1 where purge_status = 0

select purge_status,purge_config_id,history_retention_days_override,table_name from dbo.Purge_Config

exec dbo.usp_StartPurge


select dbo.udf_GetHoursAndMinutes(GETDATE(),'02:00')

select * from dbo.Purge_Config
select * from dbo.Purge_Settings_Config
select * from dbo.Purge_Error_Log
select * from dbo.Purge_Execution_Log

select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRunResults  -- 40
select count(1) as cnt from HFAMSchema1.Analytics_Staged_DistinctAlarms --40
select count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances --18702
select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRuns -- 2
select count(1) as cnt from HFAMSChema1.Logs_CommentsHistoryLogs -- 0
select count(1) as cnt from HFAMSChema1.Logs_EnforcementSessionLogs -- 0 
select count(1) as cnt from HFAMSChema1.Logs_ParamEnforcementLogs -- 0 


Begin tran

exec dbo.usp_StartPurge

rollback tran

--ALter table HFAMSchema1.Analytics_Staged_AlarmInstances drop constraint PK_Analytics_Staged_AlarmInstances 

select @@TRANCOUNT

dbcc opentran



select JobRunId, count(1) as cnt  from HFAMSchema1.Analytics_Staged_AlarmInstances group by JobRunId


select * from HFAMSchema1.Analytics_Inst_NARJobRuns
 
6B9C6951-D52F-4576-8B39-1497F660E7BE
D10B1AB7-C429-43A1-B04D-CD2B0DDCE9A8
D10B1AB7-C429-43A1-B04D-CD2B0DDCE9A8

select DATEDIFF(day,getdate(),'2021-08-21 00:01:00.000')


2021-07-01 00:05:00.000
2021-08-21 00:01:00.000


select count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances a join HFAMSchema1.Analytics_Inst_NARJobRuns b 
 on a.JobRunId = b.JobRunId where b.JobStartTime < dateadd(day,-10,getdate())

 GO




 
select purge_status,purge_config_id,history_retention_days_override,table_name from dbo.Purge_Config

exec dbo.usp_StartPurge


select dbo.udf_GetHoursAndMinutes(GETDATE(),'02:00')



select purge_status,purge_config_id,history_retention_days_override,table_name from dbo.Purge_Config


select * from dbo.Purge_Config
select * from dbo.Purge_Settings_Config


select * from dbo.Purge_Error_Log

select * from dbo.Purge_Execution_Log

select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRunResults  -- 40
select count(1) as cnt from HFAMSchema1.Analytics_Staged_DistinctAlarms --40
select count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances --18702
select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRuns -- 2
select count(1) as cnt from HFAMSChema1.Logs_CommentsHistoryLogs -- 0
select count(1) as cnt from HFAMSChema1.Logs_EnforcementSessionLogs -- 0 
select count(1) as cnt from HFAMSChema1.Logs_ParamEnforcementLogs -- 0 


Begin tran

exec dbo.usp_StartPurge

rollback tran

dbcc opentran