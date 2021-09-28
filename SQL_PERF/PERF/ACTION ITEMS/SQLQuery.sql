EXEC sp_readerrorlog @p1 = 0
                    ,@p2 = 1
                    ,@p3 = N'licensing'


EXEC dbo.sp_BlitzIndex
@DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB',
@SchemaName= 'dbo',
@TableName='Activities';


EXEC dbo.sp_BlitzIndex
@DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB',
@SchemaName= 'dbo',
@TableName='SplitActivities';



;WITH CTE_INDEX_DATA AS (
       SELECT
              SCHEMA_DATA.name AS schema_name,
              TABLE_DATA.name AS table_name,
              INDEX_DATA.name AS index_name,
              STUFF((SELECT  ', ' + COLUMN_DATA_KEY_COLS.name + ' ' + CASE WHEN INDEX_COLUMN_DATA_KEY_COLS.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END -- Include column order (ASC / DESC)
                                  FROM    sys.tables AS T
                                                INNER JOIN sys.indexes INDEX_DATA_KEY_COLS
                                                ON T.object_id = INDEX_DATA_KEY_COLS.object_id
                                                INNER JOIN sys.index_columns INDEX_COLUMN_DATA_KEY_COLS
                                                ON INDEX_DATA_KEY_COLS.object_id = INDEX_COLUMN_DATA_KEY_COLS.object_id
                                                AND INDEX_DATA_KEY_COLS.index_id = INDEX_COLUMN_DATA_KEY_COLS.index_id
                                                INNER JOIN sys.columns COLUMN_DATA_KEY_COLS
                                                ON T.object_id = COLUMN_DATA_KEY_COLS.object_id
                                                AND INDEX_COLUMN_DATA_KEY_COLS.column_id = COLUMN_DATA_KEY_COLS.column_id
                                  WHERE   INDEX_DATA.object_id = INDEX_DATA_KEY_COLS.object_id
                                                AND INDEX_DATA.index_id = INDEX_DATA_KEY_COLS.index_id
                                                AND INDEX_COLUMN_DATA_KEY_COLS.is_included_column = 0
                                  ORDER BY INDEX_COLUMN_DATA_KEY_COLS.key_ordinal
                                  FOR XML PATH('')), 1, 2, '') AS key_column_list ,
          STUFF(( SELECT  ', ' + COLUMN_DATA_INC_COLS.name
                                  FROM    sys.tables AS T
                                                INNER JOIN sys.indexes INDEX_DATA_INC_COLS
                                                ON T.object_id = INDEX_DATA_INC_COLS.object_id
                                                INNER JOIN sys.index_columns INDEX_COLUMN_DATA_INC_COLS
                                                ON INDEX_DATA_INC_COLS.object_id = INDEX_COLUMN_DATA_INC_COLS.object_id
                                                AND INDEX_DATA_INC_COLS.index_id = INDEX_COLUMN_DATA_INC_COLS.index_id
                                                INNER JOIN sys.columns COLUMN_DATA_INC_COLS
                                                ON T.object_id = COLUMN_DATA_INC_COLS.object_id
                                                AND INDEX_COLUMN_DATA_INC_COLS.column_id = COLUMN_DATA_INC_COLS.column_id
                                  WHERE   INDEX_DATA.object_id = INDEX_DATA_INC_COLS.object_id
                                                AND INDEX_DATA.index_id = INDEX_DATA_INC_COLS.index_id
                                                AND INDEX_COLUMN_DATA_INC_COLS.is_included_column = 1
                                  ORDER BY INDEX_COLUMN_DATA_INC_COLS.key_ordinal
                                  FOR XML PATH('')), 1, 2, '') AS include_column_list,
       INDEX_DATA.is_disabled -- Check if index is disabled before determining which dupe to drop (if applicable)
       FROM sys.indexes INDEX_DATA
       INNER JOIN sys.tables TABLE_DATA
       ON TABLE_DATA.object_id = INDEX_DATA.object_id
       INNER JOIN sys.schemas SCHEMA_DATA
       ON SCHEMA_DATA.schema_id = TABLE_DATA.schema_id
       WHERE TABLE_DATA.is_ms_shipped = 0
       AND INDEX_DATA.type_desc IN ('NONCLUSTERED', 'CLUSTERED')
)
SELECT
       *
FROM CTE_INDEX_DATA DUPE1
WHERE EXISTS
(SELECT * FROM CTE_INDEX_DATA DUPE2
 WHERE DUPE1.schema_name = DUPE2.schema_name
 AND DUPE1.table_name = DUPE2.table_name
 AND DUPE1.key_column_list = DUPE2.key_column_list
 AND ISNULL(DUPE1.include_column_list, '') = ISNULL(DUPE2.include_column_list, '')
 AND DUPE1.index_name <> DUPE2.index_name)
GO


---------------------------------------------------------------------------------------------------------------------------

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
--and Table_Name = 'SplitActivities'
and Table_Name IN ('DeviationSamples','TargetProcessingHistory','Activities','SplitActivities')
--and a.Index_Name = 'IX_AssetCommentHistory_LinkID'
Order by NumOfSeeks desc 



select * from #TempIndexUsageDetails where NumOfUpdates > 0 and NumOfSeeks = 0
and Index_Type = 'NonClustered' 
and Table_Name = 'StandingORders'
--and Table_Name IN ('DeviationSamples','TargetProcessingHistory','Activities','SplitActivities')
order by NumOfUpdates desc 

---------------------------------------------------------------------------------------------------------------------------
