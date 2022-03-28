USE [HWLASSETS_EPM]
GO

/*

Add more fields to the Archival config :

Archival Storage Type (Yearly\Half Yearly\Quarterly\Monthly) - New Lookup table would be required 

Most Recent Archival Database Name (Update this to the default name of the source database + any prefix depending on the above [Archival Storage type] setting)

Database Backup location (This should point to the Archive Database server only unless archive db is on the same instance)

Archival database run frequency (Daily - preffered , weekly , monthly /yearly so on) - Consider adding a schedule config 

Schedule config should refelect the next run date .

*/


--select TABLE_NAME,* from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME like '%CreatedTime%'
--and TABLE_NAME like '%history%'


--select * from dbo.AssetCommentHistory



--insert into dbo.Archival_Error_Log(archival_config_id,error_description,error_date)
--values 
--(
--	1,'Invalid object name ''dbo.RegUsers'' ',getdate()-1
--)
--,
--(
--	1,'[Error msg] - string or binary data would be truncated,[Errror procedure] -sp_insertArchival_Data, [Error Line] - 40', Getdate()
--)






select * from dbo.Archival_Storage_Options
select * from dbo.Archival_Config
select * from dbo.Archival_Schedule_config
select * from dbo.Archival_Error_Log