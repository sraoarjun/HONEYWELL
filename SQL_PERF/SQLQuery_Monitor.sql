SELECT * FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'Page life expectancy'
GO

SELECT physical_memory_kb FROM sys.dm_os_sys_info;
GO

SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Target Server%';
GO 

SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Total Server%';
GO

select * from 
(
SELECT DISTINCT
OBJECT_NAME(s.[object_id]) AS TableName,
c.name AS ColumnName,
s.name AS StatName,
STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated,
DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate()) DaysOld,
dsp.last_updated as last_updated_date,
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
--AND (s.auto_created = 1 OR s.user_created = 1)
--ORDER BY DaysOld
)A
ORDER BY DaysOld

GO



 -- check DB Fragmentation for a table indexes
 select * from
 (
	SELECT  OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name, 
	IDX.name AS Index_Name, 
	IDXPS.index_type_desc AS Index_Type, 
	IDXPS.avg_fragmentation_in_percent  Fragmentation_Percentage
	FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) IDXPS 
	INNER JOIN sys.indexes IDX  ON IDX.object_id = IDXPS.object_id 
	AND IDX.index_id = IDXPS.index_id 
	--ORDER BY Fragmentation_Percentage DESC
)A
where 
	(Table_Name  LIKE '%StandingOrder%' or Table_Name like '%Assets%')
	ORDER BY Fragmentation_Percentage DESC
GO

