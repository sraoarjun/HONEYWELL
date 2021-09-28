exec sp_updatestats 
update statistics dbo.Comments						  with fullscan
update statistics dbo.ShiftSummaryDisplays			  with fullscan
update statistics dbo.TagMonitorings				  with fullscan
update statistics dbo.DataEntryTableSnippets		  with fullscan
update statistics dbo.ShiftSummaries				  with fullscan
update statistics dbo.ShiftSummaryDisplayTagGroupData with fullscan
update statistics dbo.Tasks  with fullscan
update statistics dbo.TagMonitorings  [_WA_Sys_00000011_1EA48E88] with fullscan
																	

exec [dbo].[SP_DOORDbIndexDefragmentation] 30,100
exec [dbo].[usp_ORDBUpdateStats]
GO

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
Where Fragmentation_Percentage > 30 and page_count > 100 and Index_Name is not null
--and Table_Name not like '%history%'
ORDER BY Fragmentation_Percentage desc,page_count desc
GO

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
and modification_counter > 200
ORDER BY modification_counter desc , DaysOld desc ;
GO
 

 