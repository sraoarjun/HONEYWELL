select * from dbo.Archival_Config 



select count(1) as cnt from dbo.ShiftSummaryDisplayHistory with (nolock) -- DBO (schema)

select count(1) as cnt from site1.ShiftSummaryDisplayHistory with (nolock) --- SITE 1 (schema)


begin tran
exec dbo.Sp_Arc_RunArchiving

rollback tran

select * from sys.schemas 


select * from dbo.Archival_Config where is_enabled = 1 


update dbo.Archival_Config set is_enabled = 0 where archival_config_id = 4
update dbo.Archival_Config set is_enabled = 1 where archival_config_id = 4


update dbo.Archival_Config set is_enabled = 0 where archival_config_id = 5
update dbo.Archival_Config set is_enabled = 1 where archival_config_id = 5

update dbo.Archival_Config set batch_size = 100 where archival_config_id = 5
