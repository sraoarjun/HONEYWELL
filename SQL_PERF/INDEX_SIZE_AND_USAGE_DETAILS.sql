------------------ -------------------------------------INDEX SIZE DETAILS ---------------------------------------

;WITH CTE (TableName,RowCounts,TotalSpaceKB,UsedSpaceKB)
AS
(
SELECT
    t.[Name] AS TableName,
    p.[rows] AS [RowCount],
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 
    AND i.OBJECT_ID > 255
	GROUP BY t.[Name], p.[Rows]
--ORDER BY t.[Name]
)
,CTE_Index(IndexName,TableName,IndexSizeKB)
AS
(
SELECT
    i.[name] AS IndexName,
    t.[name] AS TableName,
    SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
INNER JOIN sys.tables t ON t.OBJECT_ID = i.object_id

GROUP BY i.[name], t.[name]
--ORDER BY i.[name], t.[name]

)

select 
	CTE.TableName,CTE.RowCounts,CTE.TotalSpaceKB,CTE.UsedSpaceKB ,CTE_Index.TableName,CTE_Index.IndexName,CTE_Index.IndexSizeKB
from 
	CTE join CTE_Index ON CTE.TableName = CTE_Index.TableName 
Where 
--	 CTE.TableName = 'StandingOrders'
	 CTE.TableName in ('Activities','ActivityReasons','SplitActivityReasons','SplitActivityRemarks','StandingOrders')

GO



------------------------------------------------------------------------------------------------------------------
------------------ -------------------------------------INDEX USAGE DETAILS ---------------------------------------

Drop table if exists #TempIndexUsageDetails
GO
Drop table if exists #TempIndexUpdateUsageDetails
GO

SELECT OBJECT_NAME(IX.OBJECT_ID) Table_Name
	   ,IX.name AS Index_Name
	   ,IX.type_desc Index_Type
	   ,SUM(PS.[used_page_count]) * 8 IndexSizeKB
	   ,IXUS.user_seeks AS NumOfSeeks
	   ,IXUS.user_scans AS NumOfScans
	   ,IXUS.user_lookups AS NumOfLookups
	   ,IXUS.user_updates AS NumOfUpdates
	   ,IXUS.last_user_seek AS LastSeek
	   ,IXUS.last_user_scan AS LastScan
	   ,IXUS.last_user_lookup AS LastLookup
	   ,IXUS.last_user_update AS LastUpdate
INTO #TempIndexUsageDetails
FROM sys.indexes IX
INNER JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.index_id = IX.index_id AND IXUS.OBJECT_ID = IX.OBJECT_ID
INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
WHERE OBJECTPROPERTY(IX.OBJECT_ID,'IsUserTable') = 1
GROUP BY OBJECT_NAME(IX.OBJECT_ID) ,IX.name ,IX.type_desc ,IXUS.user_seeks ,IXUS.user_scans ,IXUS.user_lookups,IXUS.user_updates ,IXUS.last_user_seek ,IXUS.last_user_scan ,IXUS.last_user_lookup ,IXUS.last_user_update
GO

SELECT OBJECT_NAME(IXOS.OBJECT_ID)  Table_Name 
       ,IX.name  Index_Name
	   ,IX.type_desc Index_Type
	   ,SUM(PS.[used_page_count]) * 8 IndexSizeKB
       ,IXOS.LEAF_INSERT_COUNT NumOfInserts
       ,IXOS.LEAF_UPDATE_COUNT NumOfupdates
       ,IXOS.LEAF_DELETE_COUNT NumOfDeletes
INTO #TempIndexUpdateUsageDetails   
FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) IXOS 
INNER JOIN SYS.INDEXES AS IX ON IX.OBJECT_ID = IXOS.OBJECT_ID AND IX.INDEX_ID =    IXOS.INDEX_ID 
	INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
WHERE  OBJECTPROPERTY(IX.[OBJECT_ID],'IsUserTable') = 1
GROUP BY OBJECT_NAME(IXOS.OBJECT_ID), IX.name, IX.type_desc,IXOS.LEAF_INSERT_COUNT, IXOS.LEAF_UPDATE_COUNT,IXOS.LEAF_DELETE_COUNT
GO


select * from #TempIndexUsageDetails a where exists 
(select 1 from #TempIndexUpdateUsageDetails b where a.Index_Name = b.Index_Name and a.Table_Name = b.Table_Name)
and Table_Name = 'ActivityReasons' --- Give any table name as filter 
--and a.Index_Name = 'IX_AssetCommentHistory_LinkID'  -- Give any index name as filter
--and Table_Name in ('Activities','ActivityReasons','SplitActivityReasons','SplitActivityRemarks','StandingOrders')
Order by NumOfSeeks desc 

GO


-- indexes that are not being used 
select IndexSizeKB/1024 as Index_Size_MB, * from #TempIndexUsageDetails where NumOfUpdates > 0 and NumOfSeeks = 0
and Index_Type = 'NonClustered' 
--and Table_Name = 'StandingOrders'
--and Table_Name  in ('Activities','ActivityReasons','SplitActivityReasons','SplitActivityRemarks','StandingOrders')
GO


select * from 
(
select IndexSizeKB/1024 as Index_Size_MB, * from #TempIndexUsageDetails where NumOfUpdates > 0 and NumOfSeeks = 0
and Index_Type = 'NonClustered' 
and Table_Name not like '%history%'
)A order by NumOfUpdates desc, Index_Size_MB desc 

GO

---- Get The Size Of all the indexe(s) for a given table 

SELECT
    i.[name] AS IndexName,
    t.[name] AS TableName,
    SUM(s.[used_page_count]) * 8  AS IndexSizeKB,
	SUM(s.[used_page_count]) * 8/1024.00 AS IndexSizeMB,
	SUM(s.[used_page_count]) * 8/1024.00/1024.00 AS IndexSizeGB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
INNER JOIN sys.tables t ON t.OBJECT_ID = i.object_id
where t.name = 'StandingOrders'
 --where t.Name not  like '%history%'
GROUP BY i.[name], t.[name]
ORDER BY i.[name], t.[name]