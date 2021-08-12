EXEC sp_BlitzCache @SortOrder = 'query hash'

EXEC sp_BlitzCache @OnlyQueryHashes='0xC259DE4FA9522677'


EXEC master.dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='HangFire', @TableName='Set';

EXEC sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB'  , @BringThePain = 1
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB'

exec sp_helpindex 'Hangfire.Set'

select * from [HangFire].[Hash]
select * from [HangFire].[Set]
GO



 EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1

 EXEC dbo.sp_BlitzIndex @Mode =4 

 select @@SERVERNAME

sp_configure 'Show Advanced Options', 1
GO
RECONFIGURE
GO
sp_configure 'Ad Hoc Distributed Queries', 1
GO
RECONFIGURE
GO
 

 SELECT
  *
INTO
  #tmpBlitzIndexMode_4
FROM
  OPENROWSET(
    'SQLNCLI',
    'Server=WIN16DBRIL\MES;Trusted_Connection=yes;',
    'EXEC dbo.sp_BlitzIndex @Mode =4'
)