SELECT *
FROM sys.dm_os_wait_stats dows
ORDER BY dows.wait_time_ms DESC;

SELECT *
FROM sys.dm_os_waiting_tasks dowt
WHERE dowt.wait_type LIKE '%IO%';


SELECT *
FROM sys.dm_io_virtual_file_stats(DB_ID('AdventureWorks2014'), NULL) divfs
ORDER BY divfs.io_stall DESC;





USE [DBATools]
GO

truncate table Blitzresults
GO

exec sp_Blitz @OutputDatabaseName = 'DBAtools', @OutputSchemaName = 'dbo', @OutputTableName = 'BlitzResults';

GO


EXEC sp_BlitzFirst @expertmode=1

where FindingsGroup IN('File Configuration','Performance','Non-Default Server Config','Non-Default Database Config') 
 and 
 (DatabaseName  ='Honeywell.MES.Operations.DataModel.OperationsDB' or DatabaseName is null)

 GO


 
EXEC master.dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='ShiftSummaries';


exec sp_BlitzCache @DatabaseName = 'Honeywell.MES.Operations.DataModel.OperationsDB',@SortOrder = 'cpu'
exec sp_BlitzCache @DatabaseName = 'Honeywell.MES.Operations.DataModel.OperationsDB',@SortOrder = 'reads'


 EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1

exec sp_BlitzFirst @sinceStartUp = 1

exec sp_BlitzIndex @GetAllDatabases = 1


exec sp_BlitzCache @OutputTableName = 'BlitzCacheResults_Temp',@OutputSchemaName= 'dbo',@OutputDatabaseName= 'DBATools', @sortorder = 'duration' 


exec sp_BlitzIndex  @DatabaseName = 'Honeywell.MES.Operations.DataModel.OperationsDB'

EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1

select * from dbo.BlitzCacheResults


EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1 , @OutputDatabaseName= 'DBATools',@OutputSchemaName= 'dbo',@OutputTableName = 'Temp_BlitzIndexResults'
GO



