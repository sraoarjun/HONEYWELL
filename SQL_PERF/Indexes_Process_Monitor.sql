--Existing Index Information
SELECT
   @@SERVERNAME AS [ServerName]
   , DB_NAME() AS [DatabaseName]
   , [SchemaName]
   , [ObjectName]
   , [ObjectType]
   , [IndexID]
   , [IndexName]
   , [IndexType]
   , COALESCE([0],[1],'') AS [Column1]
   , ISNULL([2],'') AS [Column2]
   , ISNULL([3],'') AS [Column3]
   , ISNULL([4],'') AS [Column4]
   , ISNULL([5],'') AS [Column5]
   , ISNULL([6],'') AS [Column6]
   , ISNULL([7],'') AS [Column7]
   , ISNULL([8],'') AS [Column8]
   , ISNULL([9],'') AS [Column9]
   , ISNULL([10],'') AS [Column10]
   , CASE 
      WHEN [IsIncludedColumn] = 0x1 THEN 'Yes'
      WHEN [IsIncludedColumn] = 0x0 THEN 'No'
      WHEN [IsIncludedColumn] IS NULL THEN 'N/A'
     END AS [IsCoveringIndex]
   , [IsDisabled]
FROM (
   SELECT
      SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
      , [sObj].[name] AS [ObjectName]
      , CASE
         WHEN [sObj].[type] = 'U' THEN 'Table'
         WHEN [sObj].[type] = 'V' THEN 'View'
         END AS [ObjectType]
      , [sIdx].[index_id] AS [IndexID]  -- 0: Heap; 1: Clustered Idx; > 1: Nonclustered Idx;
      , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
      , CASE
         WHEN [sIdx].[type] = 0 THEN 'Heap'
         WHEN [sIdx].[type] = 1 THEN 'Clustered'
         WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
         WHEN [sIdx].[type] = 3 THEN 'XML'
         WHEN [sIdx].[type] = 4 THEN 'Spatial'
         WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
         WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
        END AS [IndexType]
      , [sCol].[name] AS [ColumnName]
   , [sIdxCol].[is_included_column] AS [IsIncludedColumn]
      , [sIdxCol].[key_ordinal] AS [KeyOrdinal]
      , [sIdx].[is_disabled] AS [IsDisabled]
   FROM 
      [sys].[indexes] AS [sIdx]
      INNER JOIN [sys].[objects] AS [sObj]
         ON [sIdx].[object_id] = [sObj].[object_id]
      LEFT JOIN [sys].[index_columns] AS [sIdxCol]
         ON [sIdx].[object_id] = [sIdxCol].[object_id]
         AND [sIdx].[index_id] = [sIdxCol].[index_id]
      LEFT JOIN [sys].[columns] AS [sCol]
         ON [sIdxCol].[object_id] = [sCol].[object_id]
         AND [sIdxCol].[column_id] = [sCol].[column_id]
   WHERE
      [sObj].[type] IN ('U','V')      -- Look in Tables & Views
      AND [sObj].[is_ms_shipped] = 0x0  -- Exclude System Generated Objects
) AS [UnpivotedData]
PIVOT 
(
   MIN([ColumnName])
   FOR [KeyOrdinal] IN ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10])
) AS [ColumnPivot]

GO

--Covering Index Information
SELECT
    SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
    , [sObj].[name] AS [ObjectName]
    , CASE
        WHEN [sObj].[type] = 'U' THEN 'Table'
        WHEN [sObj].[type] = 'V' THEN 'View'
        END AS [ObjectType]
    , [sIdx].[index_id] AS [IndexID]  -- 0: Heap; 1: Clustered Idx; > 1: Nonclustered Idx;
    , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
    , CASE
        WHEN [sIdx].[type] = 0 THEN 'Heap'
        WHEN [sIdx].[type] = 1 THEN 'Clustered'
        WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
        WHEN [sIdx].[type] = 3 THEN 'XML'
        WHEN [sIdx].[type] = 4 THEN 'Spatial'
        WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
        WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
    END AS [IndexType]
    , [sCol].[name] AS [ColumnName]
   , CASE 
  WHEN [sIdxCol].[is_included_column] = 0x1 THEN 'Yes'
  WHEN [sIdxCol].[is_included_column] = 0x0 THEN 'No'
  WHEN [sIdxCol].[is_included_column] IS NULL THEN 'N/A'
  END AS [IsIncludedColumn]
    , [sIdxCol].[key_ordinal] AS [KeyOrdinal]
FROM 
    [sys].[indexes] AS [sIdx]
    INNER JOIN [sys].[objects] AS [sObj]
        ON [sIdx].[object_id] = [sObj].[object_id]
    LEFT JOIN [sys].[index_columns] AS [sIdxCol]
        ON [sIdx].[object_id] = [sIdxCol].[object_id]
        AND [sIdx].[index_id] = [sIdxCol].[index_id]
    LEFT JOIN [sys].[columns] AS [sCol]
        ON [sIdxCol].[object_id] = [sCol].[object_id]
        AND [sIdxCol].[column_id] = [sCol].[column_id]
WHERE
    SCHEMA_NAME([sObj].[schema_id]) = 'Production'
 AND [sObj].[name] = 'ProductReview'
    AND [sIdx].[name] = 'IX_ProductReview_ProductID_Name'
GO

--Existing Indexes Physical Statistics
SELECT
   @@SERVERNAME AS [ServerName]
   , DB_NAME() AS [DatabaseName]
   , SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
   , [sObj].[name] AS [ObjectName]
   , CASE
      WHEN [sObj].[type] = 'U' THEN 'Table'
      WHEN [sObj].[type] = 'V' THEN 'View'
      END AS [ObjectType]
   , [sIdx].[index_id] AS [IndexID]
   , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
   , CASE
         WHEN [sIdx].[type] = 0 THEN 'Heap'
         WHEN [sIdx].[type] = 1 THEN 'Clustered'
         WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
         WHEN [sIdx].[type] = 3 THEN 'XML'
         WHEN [sIdx].[type] = 4 THEN 'Spatial'
         WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
         WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
     END AS [IndexType]
   , ISNULL([sPtn].[partition_number], 1) AS [PartitionNumber]
   , [sdmfIPS].[alloc_unit_type_desc] AS [IndexAllocationUnitType]
   , [IdxSizeDetails].[IndexSizeInKB]
   , [sIdx].[fill_factor] AS [FillFactor]
   , CAST([sdmfIPS].[avg_fragmentation_in_percent] AS NUMERIC(5,2)) AS [AvgPctFrag]
FROM 
   [sys].[indexes] AS [sIdx]
   INNER JOIN [sys].[objects] AS [sObj]
      ON [sIdx].[object_id] = [sObj].[object_id]
   LEFT JOIN  [sys].[partitions] AS [sPtn]
      ON [sIdx].[object_id] = [sPtn].[object_id]
      AND [sIdx].[index_id] = [sPtn].[index_id]
   LEFT JOIN (
            SELECT
               [sIdx].[object_id]
               , [sIdx].[index_id]
               , SUM([sAU].[used_pages]) * 8 AS [IndexSizeInKB]
            FROM 
               [sys].[indexes] AS [sIdx]
               INNER JOIN [sys].[partitions] AS [sPtn]
                  ON [sIdx].[object_id] = [sPtn].[object_id]
                  AND [sIdx].[index_id] = [sPtn].[index_id]
               INNER JOIN [sys].[allocation_units] AS [sAU]
                  ON [sPtn].[partition_id] = [sAU].[container_id]
            GROUP BY [sIdx].[object_id], [sIdx].[index_id]
   ) [IdxSizeDetails]
      ON [sIdx].[object_id] = [IdxSizeDetails].[object_id]
      AND [sIdx].[index_id] = [IdxSizeDetails].[index_id]
   LEFT JOIN [sys].[dm_db_index_physical_stats] (DB_ID(),NULL,NULL,NULL,'LIMITED') [sdmfIPS]
      ON [sIdx].[object_id] = [sdmfIPS].[object_id]
      AND [sIdx].[index_id] = [sdmfIPS].[index_id]
      AND [sdmfIPS].[database_id] = DB_ID()
WHERE
   [sObj].[type] IN ('U','V')         -- Look in Tables & Views
   AND [sObj].[is_ms_shipped] = 0x0   -- Exclude System Generated Objects
   AND [sIdx].[is_disabled] = 0x0     -- Exclude Disabled Indexes

GO

--Existing Indexes Usage Statistics
SELECT
   @@SERVERNAME AS [ServerName]
   , DB_NAME() AS [DatabaseName]
   , SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
   , [sObj].[name] AS [ObjectName]
   , CASE
      WHEN [sObj].[type] = 'U' THEN 'Table'
      WHEN [sObj].[type] = 'V' THEN 'View'
      END AS [ObjectType]
   , [sIdx].[index_id] AS [IndexID]
   , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
   , CASE
      WHEN [sIdx].[type] = 0 THEN 'Heap'
      WHEN [sIdx].[type] = 1 THEN 'Clustered'
      WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
      WHEN [sIdx].[type] = 3 THEN 'XML'
      WHEN [sIdx].[type] = 4 THEN 'Spatial'
      WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
      WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
     END AS [IndexType]
   , [sdmvIUS].[user_seeks] AS [TotalUserSeeks]
   , [sdmvIUS].[user_scans] AS [TotalUserScans]
   , [sdmvIUS].[user_lookups] AS [TotalUserLookups]
   , [sdmvIUS].[user_updates] AS [TotalUserUpdates]
   , [sdmvIUS].[last_user_seek] AS [LastUserSeek]
   , [sdmvIUS].[last_user_scan] AS [LastUserScan]
   , [sdmvIUS].[last_user_lookup] AS [LastUserLookup]
   , [sdmvIUS].[last_user_update] AS [LastUserUpdate]
   , [sdmfIOPS].[leaf_insert_count] AS [LeafLevelInsertCount]
   , [sdmfIOPS].[leaf_update_count] AS [LeafLevelUpdateCount]
   , [sdmfIOPS].[leaf_delete_count] AS [LeafLevelDeleteCount]
FROM
   [sys].[indexes] AS [sIdx]
   INNER JOIN [sys].[objects] AS [sObj]
      ON [sIdx].[object_id] = [sObj].[object_id]
   LEFT JOIN [sys].[dm_db_index_usage_stats] AS [sdmvIUS]
      ON [sIdx].[object_id] = [sdmvIUS].[object_id]
      AND [sIdx].[index_id] = [sdmvIUS].[index_id]
      AND [sdmvIUS].[database_id] = DB_ID()
   LEFT JOIN [sys].[dm_db_index_operational_stats] (DB_ID(),NULL,NULL,NULL) AS [sdmfIOPS]
      ON [sIdx].[object_id] = [sdmfIOPS].[object_id]
      AND [sIdx].[index_id] = [sdmfIOPS].[index_id]
WHERE
   [sObj].[type] IN ('U','V')         -- Look in Tables & Views
   AND [sObj].[is_ms_shipped] = 0x0   -- Exclude System Generated Objects
   AND [sIdx].[is_disabled] = 0x0     -- Exclude Disabled Indexes
GO


--Missing Index Information
SELECT
   @@SERVERNAME AS [ServerName]
   , DB_NAME() AS [DatabaseName]
   , SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
   , [sObj].[name] AS [ObjectName]
   , CASE [sObj].[type]
      WHEN 'U' THEN 'Table'
      WHEN 'V' THEN 'View'
      ELSE 'Unknown'
     END AS [ObjectType]
   , [sdmvMID].[equality_columns] AS [EqualityColumns]
   , [sdmvMID].[inequality_columns] AS [InequalityColumns]
   , [sdmvMID].[included_columns] AS [IncludedColumns]
   , [sdmvMIGS].[user_seeks] AS [ExpectedIndexSeeksByUserQueries]
   , [sdmvMIGS].[user_scans] AS [ExpectedIndexScansByUserQueries]
   , [sdmvMIGS].[last_user_seek] AS [ExpectedLastIndexSeekByUserQueries]
   , [sdmvMIGS].[last_user_scan] AS [ExpectedLastIndexScanByUserQueries]
   , [sdmvMIGS].[avg_total_user_cost] AS [ExpectedAvgUserQueriesCostReduction]
   , [sdmvMIGS].[avg_user_impact] AS [ExpectedAvgUserQueriesBenefitPct]
FROM 
   [sys].[dm_db_missing_index_details] AS [sdmvMID]
   LEFT JOIN [sys].[dm_db_missing_index_groups] AS [sdmvMIG]
      ON [sdmvMID].[index_handle] = [sdmvMIG].[index_handle]
   LEFT JOIN [sys].[dm_db_missing_index_group_stats] AS [sdmvMIGS]
      ON [sdmvMIG].[index_group_handle] = [sdmvMIGS].[group_handle]
   INNER JOIN [sys].[objects] AS [sObj]
      ON [sdmvMID].[object_id] = [sObj].[object_id]
WHERE
   [sdmvMID].[database_id] = DB_ID()  -- Look in the Current Database
   AND [sObj].[type] IN ('U','V')     -- Look in Tables & Views
   AND [sObj].[is_ms_shipped] = 0x0   -- Exclude System Generated Objects
GO

--Unused Index Information
SELECT
   @@SERVERNAME AS [ServerName]
   , DB_NAME() AS [DatabaseName]
   , SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
   , [sObj].[name] AS [ObjectName]
   , CASE
      WHEN [sObj].[type] = 'U' THEN 'Table'
      WHEN [sObj].[type] = 'V' THEN 'View'
     END AS [ObjectType]
   , [sIdx].[index_id] AS [IndexID]
   , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
   , CASE
      WHEN [sIdx].[type] = 0 THEN 'Heap'
      WHEN [sIdx].[type] = 1 THEN 'Clustered'
      WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
      WHEN [sIdx].[type] = 3 THEN 'XML'
      WHEN [sIdx].[type] = 4 THEN 'Spatial'
      WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
      WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
     END AS [IndexType]
FROM
   [sys].[indexes] AS [sIdx]
   INNER JOIN [sys].[objects] AS [sObj]
      ON [sIdx].[object_id] = [sObj].[object_id]
WHERE
   NOT EXISTS (
               SELECT *
               FROM [sys].[dm_db_index_usage_stats] AS [sdmfIUS]
               WHERE 
                  [sIdx].[object_id] = [sdmfIUS].[object_id]
                  AND [sIdx].[index_id] = [sdmfIUS].[index_id]
                  AND [sdmfIUS].[database_id] = DB_ID()
            )
   AND [sObj].[type] IN ('U','V')     -- Look in Tables & Views
   AND [sObj].[is_ms_shipped] = 0x0   -- Exclude System Generated Objects
   AND [sIdx].[is_disabled] = 0x0     -- Exclude Disabled Indexes