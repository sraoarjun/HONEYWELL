USE [DBATools]
GO

truncate table Blitzresults
GO

exec sp_Blitz @OutputDatabaseName = 'DBAtools', @OutputSchemaName = 'dbo', @OutputTableName = 'BlitzResults';
GO

select * from dbo.BlitzResults
 where FindingsGroup IN('File Configuration','Performance','Non-Default Server Config','Non-Default Database Config') 
 and 
 (DatabaseName  ='Honeywell.MES.Operations.DataModel.OperationsDB' or DatabaseName is null)

 GO


exec sp_BlitzCache @DatabaseName = 'Honeywell.MES.Operations.DataModel.OperationsDB',@SortOrder = 'cpu'
exec sp_BlitzCache @DatabaseName = 'Honeywell.MES.Operations.DataModel.OperationsDB',@SortOrder = 'reads'


exec sp_BlitzFirst @sinceStartUp = 1

exec sp_BlitzIndex @GetAllDatabases = 1