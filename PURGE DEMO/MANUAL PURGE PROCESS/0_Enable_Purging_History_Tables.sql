-- Enable Purging for History Tables

Update dbo.Lookups set Value = 'True' where name = 'Enable_Purge_Operation' and LookupType_PK_ID = (select LookupType_PK_ID from dbo.LookupTypes 
where name = 'History Purging parameters')

