Drop table if exists #tempBuffer
GO

SELECT COUNT(1)/128 AS megabytes_in_cache
,name ,index_id
INTO #tempBuffer
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
GO


select * from #tempBuffer  order by megabytes_in_cache desc