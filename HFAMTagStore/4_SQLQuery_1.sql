
USE [HFAMTagStore1]
GO

select * from dbo.Purge_Config

select * from dbo.Purge_Settings_Config

select * from dbo.Purge_Error_Log

select * from dbo.Purge_Execution_Log

select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRunResults  -- 40
select count(1) as cnt from HFAMSchema1.Analytics_Staged_DistinctAlarms --40
select count(1) as cnt from HFAMSchema1.Analytics_Staged_AlarmInstances --18702
select count(1) as cnt from HFAMSchema1.Analytics_Inst_NARJobRuns -- 2
--select count(1) as cnt from HFAMSchema1.Inst_JobRunsStatusHistory   -- 2
select count(1) as cnt from HFAMSChema1.Logs_CommentsHistoryLogs -- 0
select count(1) as cnt from HFAMSChema1.Logs_EnforcementSessionLogs -- 0 
select count(1) as cnt from HFAMSChema1.Logs_ParamEnforcementLogs -- 0 


Begin tran

exec dbo.usp_StartPurge

rollback tran

dbcc opentran