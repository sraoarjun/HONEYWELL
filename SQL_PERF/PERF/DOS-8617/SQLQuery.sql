CREATE TABLE #UnusedIndexes
(database_name sysname,
table_name sysname,
index_id int,
object_id int,
index_name sysname NULL,
user_updates bigint,
last_user_update datetime,
user_seeks bigint,
user_scans bigint,
user_lookups bigint,
system_seeks bigint,
system_scans bigint,
system_lookups bigint,
system_updates bigint)

INSERT INTO #UnusedIndexes
(database_name, table_name, index_id, [object_id],
user_updates, last_user_update, user_seeks,
user_scans, user_lookups, system_seeks,
system_scans, system_lookups, system_updates)
SELECT db_name(us.database_id) as database_name,
object_name(us.object_id, us.database_id) as table_name,
us.index_id,
us.object_id,
us.user_updates, us.last_user_update,
us.user_seeks, us.user_scans,
us.user_lookups,
us.system_seeks, us.system_scans,
us.system_lookups, us.system_updates
FROM sys.dm_db_index_usage_stats us
WHERE us.user_seeks + us.user_scans + us.user_lookups = 0
AND us.database_id > 5
DECLARE @database_name sysname
DECLARE @statement NVARCHAR(2000)
DECLARE UnusedIndexCursor CURSOR FOR
SELECT distinct database_name FROM #UnusedIndexes
OPEN UnusedIndexCursor
FETCH NEXT FROM UnusedIndexCursor INTO
@database_name
WHILE @@FETCH_STATUS = 0
BEGIN
SET @statement = N'UPDATE ui SET index_name = si.name FROM #UnusedIndexes ui INNER JOIN ' +'['+ @database_name+']' + N'.sys.indexes si ON ui.object_id = si.object_id and ui.index_id = si.index_id'
EXEC sp_executesql @sql = @statement
--PRINT @statement
FETCH NEXT FROM UnusedIndexCursor INTO
@database_name
END
CLOSE UnusedIndexCursor
DEALLOCATE UnusedIndexCursor
SELECT * FROM #UnusedIndexes us
ORDER BY us.user_updates DESC
--DROP TABLE #UnusedIndexes



select * from #UnusedIndexes where [database_name] =  'Honeywell.MES.Operations.DataModel.OperationsDB'
 order by user_updates desc
