-- Cached Page count , Table_Name  Index Name , Index Description

SELECT COUNT(*) AS cached_pages_count,
name AS BaseTableName, IndexName,
IndexTypeDesc
FROM sys.dm_os_buffer_descriptors AS bd
INNER JOIN
(
SELECT s_obj.name, s_obj.index_id,
s_obj.allocation_unit_id, s_obj.OBJECT_ID,
i.name IndexName, i.type_desc IndexTypeDesc
FROM
(
SELECT OBJECT_NAME(OBJECT_ID) AS name,
index_id ,allocation_unit_id, OBJECT_ID
FROM sys.allocation_units AS au
INNER JOIN sys.partitions AS p
ON au.container_id = p.hobt_id
AND (au.type = 1 OR au.type = 3)
UNION ALL
SELECT OBJECT_NAME(OBJECT_ID) AS name,
index_id, allocation_unit_id, OBJECT_ID
FROM sys.allocation_units AS au
INNER JOIN sys.partitions AS p
ON au.container_id = p.partition_id
AND au.type = 2
) AS s_obj
LEFT JOIN sys.indexes i ON i.index_id = s_obj.index_id
AND i.OBJECT_ID = s_obj.OBJECT_ID ) AS obj
ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = DB_ID()
GROUP BY name, index_id, IndexName, IndexTypeDesc
ORDER BY cached_pages_count DESC;
GO

---- Row_Counts  , Total_Pages ,UsedPages , UnusedPages
SELECT 
    t.NAME AS TableName,
    p.rows AS RowCounts,
    SUM(a.total_pages) AS TotalPages, 
    SUM(a.used_pages) AS UsedPages, 
    (SUM(a.total_pages) - SUM(a.used_pages)) AS UnusedPages
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, p.Rows
ORDER BY 
    t.Name
GO