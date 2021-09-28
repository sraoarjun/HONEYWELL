
declare @NameOfProcedure varchar(100) = 'ChangeNotes_selectchanges'
DECLARE @planHandle VARBINARY(64) = (SELECT top 1 plan_handle
   FROM   sys.dm_exec_cached_plans AS cp
          CROSS APPLY sys.dm_exec_sql_text(plan_handle)
   WHERE  cp.cacheobjtype = N'Compiled Plan'
          AND cp.objtype = N'Proc'
          AND cp.usecounts = 1
          AND TEXT LIKE '%' + @NameOfProcedure + '%')

	select @NameOfProcedure as nameOfProcedure , @planHandle as planHandle

IF @planHandle IS NOT NULL
  BEGIN     
      PRINT 'Procedure with name like ' + @NameOfProcedure + ' plan handle found with value as given below:'
      PRINT @planHandle   
      DBCC FREEPROCCACHE (@planHandle)
      PRINT 'Execution plan cleared for the procedure'
  END
ELSE
  BEGIN
      PRINT 'No Plan was found for the selected procedure '
            + @NameOfProcedure
  END 

GO

select top 100 local_update_peer_timestamp from dbo.OperatingLimits_tracking order by local_update_peer_timestamp desc 


 select * from INFORMATION_SCHEMA.columns where COLUMN_NAME = 'local_update_peer_timestamp'

 exec sp_sqlskills_helpindex 'dbo.OperatingLimits_tracking'

DROP INDEX IF EXISTS [IX_OperatingLimits_Tracking_TEST_1] on [dbo].[OperatingLimits_tracking]
GO
CREATE NONCLUSTERED INDEX [IX_OperatingLimits_Tracking_TEST_1]
ON [dbo].[OperatingLimits_tracking] ([local_update_peer_timestamp])
INCLUDE ([sync_row_is_tombstone])


set statistics io on

	declare @sync_min_timestamp bigint = 50566320
	select 
	[side].[sync_row_is_tombstone]
	,[side].[local_update_peer_timestamp] AS sync_row_timestamp
	from 

	dbo.OperatingLimits_tracking side 
	where 
		[side].[local_update_peer_timestamp] > @sync_min_timestamp 

set statistics io off
GO

set statistics io on

	declare @sync_min_timestamp bigint = 50566320
	select 
	[side].[sync_row_is_tombstone]
	,[side].[local_update_peer_timestamp] AS sync_row_timestamp
	from 

	dbo.OperatingLimits_tracking side 
	where 
		[side].[local_update_peer_timestamp] > cast(@sync_min_timestamp as timestamp)

set statistics io off

GO

SELECT *
FROM sys.dm_os_wait_stats dows
ORDER BY dows.wait_time_ms DESC;

SELECT *
FROM sys.dm_os_waiting_tasks dowt
WHERE dowt.wait_type LIKE '%IO%';


SELECT *
FROM sys.dm_io_virtual_file_stats(DB_ID('Honeywell.MES.LimitRepository.DataModel.LRModel'), NULL) divfs
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
 (DatabaseName  ='Honeywell.MES.LimitRepository.DataModel.LRModel' or DatabaseName is null)

 GO


 
EXEC master.dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.LimitRepository.DataModel.LRModel', @SchemaName='dbo', @TableName='ShiftSummaries';


exec sp_BlitzCache @DatabaseName = 'Honeywell.MES.LimitRepository.DataModel.LRModel',@SortOrder = 'cpu'
exec sp_BlitzCache @DatabaseName = 'Honeywell.MES.LimitRepository.DataModel.LRModel',@SortOrder = 'reads'


 EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1

exec sp_BlitzFirst @sinceStartUp = 1

exec sp_BlitzIndex @GetAllDatabases = 1


exec sp_BlitzCache @OutputTableName = 'BlitzCacheResults_Temp',@OutputSchemaName= 'dbo',@OutputDatabaseName= 'DBATools', @sortorder = 'duration' 


exec sp_BlitzIndex  @DatabaseName = 'Honeywell.MES.LimitRepository.DataModel.LRModel'

EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1

select * from dbo.BlitzCacheResults


EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1 , @BringThePain = 1 , @OutputDatabaseName= 'DBATools',@OutputSchemaName= 'dbo',@OutputTableName = 'Temp_BlitzIndexResults'
GO



