select * from dbo.Lookups where Name = 'Batch_Size'

select * from dbo.Lookups Where  LookupType_PK_ID  =(select LookupType_PK_ID from dbo.LookupTypes where name ='Purging Parameters') 

-- move lookuptypes to a differnt look up type 

-- Window time (To take up later) -- setting table

-- continue from where it it left if there is an error or abrupt stoppage

-- Index analysis (Work with SIT)

-- end time  (default 12 AM and duration of 2 hours)-- this should be in the setting tables instead

-- move batch_size from global lookups and move them to a setting tables instead

-- remove the overide batch size , is_enabled  and override retention days from the archival config 

select 
	archival_config_id,description_text,table_schema,table_name,
	--override_batch_size,override_history_data_retention_days,
	filters,is_enabled,db_datetime_last_updated,LookUpName
 from dbo.Archival_Config 
where 
	is_enabled = 1


	
	select * from dbo.Archival_Config
	update dbo.Archival_Config set is_enabled = 0 where archival_config_id not in (23,27,29)
	update dbo.Archival_Config set is_enabled = 0 where archival_config_id not in (37,4)
	update dbo.Archival_Config set is_enabled = 1 where archival_config_id  in (37,4)
	update dbo.Archival_Config set is_enabled = 1 where archival_config_id in (23,27,29)
	
	update dbo.Archival_Config set override_batch_size = 25000 where is_enabled = 1 --archival_config_id = 29

exec dbo.Generate_Dynamic_SQL 23



begin tran

exec dbo.Sp_Arc_RunArchiving

rollback tran


select * from dbo.Archival_Execution_Log 




-- run the below in a new window


set transaction isolation level read uncommitted;
--23 

select count(1) as cnt  from  dbo.TasksHistory  WHERE  ActualEndTime  <= 'May  6 2017 11:04PM'

--27
select count(1) as cnt  from dbo.StandingOrderCommentsHistory INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderCommentsHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID WHERE dbo.StandingOrdersHistory.ActualEndTime  <= 'May  6 2017 10:47PM'

--29
select count(1) as cnt  from dbo.StandingOrdersActionHistoryHistory INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrdersActionHistoryHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID  
WHERE dbo.StandingOrdersHistory.ActualEndTime  <= 'May  6 2017 10:36PM'



select * from dbo.Archival_Execution_Log  with (nolock)

select * from dbo.Archival_Error_Log with (nolock)

exec sp_blitzwho


Exec dbo.Sp_Arc_Delete_From_Source_Test @schemaName = 'dbo',@tableName ='AssetCommentHistory',@filters = ' where Shift_EndTime <= ''May  6 2017 10:36PM''',@pk_column_name= 'AssetCommentHistory_PK_ID'



