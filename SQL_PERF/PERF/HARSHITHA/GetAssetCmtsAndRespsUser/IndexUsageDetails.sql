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
--and Table_Name IN('AssetCommentHistory','Comments','CommentCategoryHistory')
and Table_Name ='AssetCommentHistory'
--and a.Index_Name = 'IX_AssetCommentHistory_LinkID'
Order by NumOfSeeks desc 