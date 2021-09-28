

ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE CLEAR;



SELECT actual_state_desc, desired_state_desc, current_storage_size_mb,
    max_storage_size_mb, readonly_reason, interval_length_minutes,
    stale_query_threshold_days, size_based_cleanup_mode_desc,
    query_capture_mode_desc
FROM sys.database_query_store_options;


--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_ONLY);

--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (QUERY_CAPTURE_MODE = AUTO);

 
--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);


--select GETUTCDATE()
--GO;





select * from
 (
    SELECT  OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name,
    IDX.name AS Index_Name,
    IDXPS.index_type_desc AS Index_Type,
    IDXPS.page_count,
    IDXPS.avg_fragmentation_in_percent  Fragmentation_Percentage
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) IDXPS
    INNER JOIN sys.indexes IDX  ON IDX.object_id = IDXPS.object_id
    AND IDX.index_id = IDXPS.index_id
   
)A
where Table_Name in ('Activities','SplitActivities')
ORDER BY page_count desc, Fragmentation_Percentage DESC




SELECT * FROM
(
SELECT DISTINCT
OBJECT_SCHEMA_NAME(s.[object_id]) AS SchemaName,
OBJECT_NAME(s.[object_id]) AS TableName,
c.name AS ColumnName,
s.name AS StatName,
STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated,
DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate()) DaysOld,
dsp.modification_counter,
s.auto_created,
s.user_created,
s.no_recompute,
s.[object_id],
s.stats_id,
sc.stats_column_id,
sc.column_id
FROM sys.stats s
JOIN sys.stats_columns sc
ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
JOIN sys.columns c ON c.[object_id] = sc.[object_id] AND c.column_id = sc.column_id
JOIN sys.partitions par ON par.[object_id] = s.[object_id]
JOIN sys.objects obj ON par.[object_id] = obj.[object_id]
CROSS APPLY sys.dm_db_stats_properties(sc.[object_id], s.stats_id) AS dsp
WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
 --AND (s.auto_created = 1 OR s.user_created = 1) -- filter out stats for indexes
)A
where DaysOld is not null and modification_counter is not null
and TableName IN ('activities','splitActivities')
ORDER BY modification_counter desc , DaysOld desc ;
GO



--alter index ALL on dbo.SPlitACtivities rebuild 
--alter index ALL on dbo.Activities rebuild  

update statistics dbo.Activities with fullscan , columns 
update statistics dbo.SplitActivities with fullscan , columns 