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


 EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1

exec sp_BlitzFirst @sinceStartUp = 1

exec sp_BlitzIndex @GetAllDatabases = 1


exec sp_BlitzCache @sortorder = 'duration'


exec sp_BlitzIndex  @DatabaseName = 'Honeywell.MES.Operations.DataModel.OperationsDB'