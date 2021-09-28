  
 -- check DB Fragmentation for a table indexes
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
where  Index_Name IN ('IX_vw_deviationSample_SplitActivities_Indexex','IX_vw_deviationSamples_indexed','PK_Activities','PK_DeviationSamples','PK_splitActivites',
'PK_tagmonitorings')


