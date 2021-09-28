--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE CLEAR;





--SELECT actual_state_desc, desired_state_desc, current_storage_size_mb,
--    max_storage_size_mb, readonly_reason, interval_length_minutes,
--    stale_query_threshold_days, size_based_cleanup_mode_desc,
--    query_capture_mode_desc
--FROM sys.database_query_store_options;


ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_ONLY);

ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (QUERY_CAPTURE_MODE = AUTO);

 
ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
   
select @@VERSION


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

--ORDER BY Fragmentation_Percentage desc, page_count DESC
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
ORDER BY modification_counter desc , DaysOld desc ;
GO
 

/*
	exec [dbo].[SP_DOORDbIndexDefragmentation] 30,100
*/
alter proc [dbo].[SP_DOORDbIndexDefragmentation]
(@avg_frag_percent float , @page_count int )
AS
Begin


    IF OBJECT_ID(N'tempdb..#tmpORDbIndexfragmentedIndexes') IS NOT NULL
    BEGIN
        EXEC('DROP TABLE #tmpORDbIndexfragmentedIndexes')
    END
    


    -- Query to find the Fragmented Indexes which has fragmentation greater or equal to 30 and page count of 1000 or more
    SELECT S.[name] SchemaName, T.[name] TableName, I.[name] IndexName, IDENTITY(INT) AS Id INTO #tmpORDbIndexfragmentedIndexes
    FROM sys.dm_db_index_physical_stats(DB_ID('Honeywell.MES.Operations.DataModel.OperationsDB'), NULL, NULL, NULL, 'SAMPLED') IPS, 
        sys.schemas S, sys.tables T, sys.indexes I 
    WHERE IPS.index_id = I.index_id AND IPS.[object_id] = I.[object_id]
        AND T.[schema_id] = S.[schema_id] AND T.[object_id] = IPS.[object_id]
        AND t.name not like '%history%' --- Exclude the History tables 
        AND avg_fragmentation_in_percent >= @avg_frag_percent -- Rebuild only if the Fragmentation is greater than 30 %
        AND page_count >=@page_count --check for page count to be  greater than 1000


    DECLARE @FragmentedIndexesCount INT
    DECLARE @LoopCount INT
    DECLARE @SchemaName NVARCHAR(100)
    DECLARE @TableName NVARCHAR(100)
    DECLARE @IndexName NVARCHAR(100)
    DECLARE @SqlStatement NVARCHAR(1000)


    SET @FragmentedIndexesCount = (SELECT COUNT(1) FROM #tmpORDbIndexfragmentedIndexes)
    SET @LoopCount = 1


    WHILE(@LoopCount <= @FragmentedIndexesCount)
    BEGIN
        SELECT @SchemaName = SchemaName, @TableName = TableName, @IndexName = IndexName
        FROM #tmpORDbIndexfragmentedIndexes WHERE Id = @LoopCount
    
        SET @SqlStatement = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD WITH (ONLINE=OFF)'
        --PRINT @SqlStatement
        EXEC(@SqlStatement)
    
        SET @LoopCount = (@LoopCount + 1)
    END


    EXEC('DROP TABLE #tmpORDbIndexfragmentedIndexes')
End
Go


    
--exec [dbo].[SP_DOORDbIndexDefragmentation] 30,500

    
/*
Description :


1)The procedure updates the statistics for the user created / system tables.
2)This procedure should always be run after rebuilding the indexes,so that 
the statistics associated with the index rebuild job can be exclueded here.
3)Additionally the procedure updates statistics only for the tables 
where the modification_counter(Updates/Deletes/Inserts) are greater than default value of 
200 or the configured value for the input parameter @modification_counter


input parameters : 
@modification_counter int = 200. The defalt value is 200 , however this can be 
configured to any other value depending on the workload and the data changes.

exec [dbo].[usp_ORDBUpdateStats]

*/
CREATE PROCEDURE dbo.usp_ORDBUpdateStats (@modification_counter int = 200)
AS
BEGIN
    DECLARE @sqlCommand NVARCHAR(max) = ''
        ,@stat_counter INT = 1
        ,@row_count INT
        ,@schemaname VARCHAR(max)
        ,@tablename VARCHAR(max)
        ,@statname VARCHAR(max)


    DROP TABLE


    IF EXISTS #tempstatistics
        CREATE TABLE #tempstatistics (
            id INT identity(1, 1)
            ,schemaname VARCHAR(max)
            ,tablename VARCHAR(max)
            ,statname VARCHAR(max)
            )


    INSERT INTO #tempstatistics
    SELECT DISTINCT OBJECT_SCHEMA_NAME(s.[object_id]) AS SchemaName
        ,OBJECT_NAME(s.[object_id]) AS TableName
        ,s.name AS StatName
    FROM sys.stats s
    JOIN sys.stats_columns sc ON sc.[object_id] = s.[object_id]
        AND sc.stats_id = s.stats_id
    JOIN sys.columns c ON c.[object_id] = sc.[object_id]
        AND c.column_id = sc.column_id
    JOIN sys.partitions par ON par.[object_id] = s.[object_id]
    JOIN sys.objects obj ON par.[object_id] = obj.[object_id]
    CROSS APPLY sys.dm_db_stats_properties(sc.[object_id], s.stats_id) AS dsp
    WHERE    OBJECTPROPERTY(s.OBJECT_ID, 'IsUserTable') = 1
        AND 
        (
            (
                CAST(last_updated  as date) < CAST(getdate() as date) and s.name not like '%_WA_Sys_%'
            )
            OR 
            ( 
                s.name like '%_WA_Sys_%'
            )
        )


    AND dsp.modification_counter > @modification_counter


    SET @row_count = (
            SELECT count(1)
            FROM #tempstatistics
            )


    WHILE (@stat_counter <= @row_count)
    BEGIN
        SELECT @schemaname = schemaname
            ,@tablename = tablename
            ,@statname = statname
        FROM #tempstatistics
        WHERE id = @stat_counter


        SET @sqlCommand = 'UPDATE STATISTICS [' + @schemaname + '].[' + @tablename + '] ' + '['+@statname +']'+  ' WITH FULLSCAN'
        --Uncomment the below line to see the actual text being executed 
        --PRINT @sqlCommand 
        EXEC sp_executesql @sqlCommand
        SET @stat_counter = @stat_counter + 1
    END
END
GO









