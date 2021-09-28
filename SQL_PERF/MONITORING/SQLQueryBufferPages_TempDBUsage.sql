
SELECT COUNT(1)/128 AS megabytes_in_cache
,name ,index_id
--INTO #tempBuffer
FROM sys.dm_os_buffer_descriptors AS bd
INNER JOIN
(
SELECT object_name(object_id) AS name
,index_id ,allocation_unit_id
FROM sys.allocation_units AS au
INNER JOIN sys.partitions AS p
ON au.container_id = p.hobt_id
AND (au.type = 1 OR au.type = 3)
UNION ALL
SELECT object_name(object_id) AS name
,index_id, allocation_unit_id
FROM sys.allocation_units AS au
INNER JOIN sys.partitions AS p
ON au.container_id = p.partition_id
AND au.type = 2
) AS obj
ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = DB_ID()
GROUP BY name, index_id
ORDER BY megabytes_in_cache DESC;
--GO

--SELECT
--CASE database_id
--WHEN 32767 THEN 'ResourceDb'
--ELSE db_name(database_id)
--END AS database_name, COUNT(1)/128 AS megabytes_in_cache
--FROM sys.dm_os_buffer_descriptors
--GROUP BY DB_NAME(database_id) ,database_id
--ORDER BY megabytes_in_cache DESC;




SELECT DB_NAME(vsu.database_id) AS DatabaseName,
		FILE_NAME(tu.file_id) as FileName,
		tu.file_id, 
    vsu.reserved_page_count, 
    vsu.reserved_space_kb, 
    tu.total_page_count as tempdb_pages, 
    vsu.reserved_page_count * 100. / tu.total_page_count AS [Snapshot %],
    tu.allocated_extent_page_count * 100. / tu.total_page_count AS [tempdb % used]
FROM sys.dm_tran_version_store_space_usage vsu
    CROSS JOIN tempdb.sys.dm_db_file_space_usage tu
WHERE vsu.database_id = DB_ID(DB_NAME());