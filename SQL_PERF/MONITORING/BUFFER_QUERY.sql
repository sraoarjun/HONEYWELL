USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
Drop table if exists #tempBuffer
GO

SELECT COUNT(1)/128 AS megabytes_in_cache
,obj.name as Table_Name,si.name as Index_Name,obj.index_id
INTO #tempBuffer
FROM sys.dm_os_buffer_descriptors AS bd
INNER JOIN
(
SELECT object_id , object_name(object_id) AS name
,index_id ,allocation_unit_id
FROM sys.allocation_units AS au
INNER JOIN sys.partitions AS p
ON au.container_id = p.hobt_id
AND (au.type = 1 OR au.type = 3)
UNION ALL
SELECT object_id ,object_name(object_id) AS name
,index_id, allocation_unit_id
FROM sys.allocation_units AS au
INNER JOIN sys.partitions AS p
ON au.container_id = p.partition_id
AND au.type = 2
) AS obj
ON bd.allocation_unit_id = obj.allocation_unit_id
join sys.indexes si on si.object_id = obj.object_id and si.index_id = obj.index_id
WHERE database_id = DB_ID()
GROUP BY obj.name,si.name, obj.index_id
ORDER BY megabytes_in_cache DESC;
GO


select * from #tempBuffer  order by megabytes_in_cache desc

--select * from #tempBuffer where Table_Name = 'AssetCommentHistory'  

--select * from #tempBuffer where Table_Name = 'StandingOrders' 

--select * from sys.indexes where object_id = OBJECT_ID('DeviationSamples') and index_id IN (1,5)

--- Buffer Cache Pages and Total Cache used in mb
SELECT
	COUNT(*) AS buffer_cache_pages,
	COUNT(*) * 8 / 1024 AS buffer_cache_used_MB
FROM sys.dm_os_buffer_descriptors;
 


 ----MSDN Single use plan cache size 
SELECT objtype, cacheobjtype, 
  AVG(usecounts) AS Avg_UseCount, 
  SUM(refcounts) AS AllRefObjects, 
  SUM(CAST(size_in_bytes AS bigint))/1024/1024 AS Size_MB
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' AND usecounts = 1
GROUP BY objtype, cacheobjtype;

/*
If the AdHoc_Plan_SingleUse_MB or AdHoc_Plan_MB is in more than 
20-30 % of the total Plan Cache size , then its better to turn the 
Optimize for AdHoc workload setting enabled at the server level 

*/
SELECT Total_Cache_MB,AdHoc_Plan_MB, AdHoc_Plan_SingleUse_MB,
        Adhoc_Plan_MB*100 /Total_Cache_mb AS 'AdHoc %',
		AdHoc_Plan_SingleUse_MB*100.0 / Total_Cache_MB AS 'AdHoc Single Use%'
		
FROM (
SELECT SUM(CASE
            WHEN objtype = 'adhoc' and usecounts = 1 
            THEN cast(size_in_bytes as bigint)
            ELSE 0 END) / 1048576.0 AdHoc_Plan_SingleUse_MB,
        SUM(cast(size_in_bytes as bigint)) / 1048576.0 Total_Cache_MB,
		SUM (CASE 
			WHEN objtype = 'adhoc' THEN cast (size_in_bytes as bigint)
			else 0 end) /1048576.0 as Adhoc_Plan_MB
FROM sys.dm_exec_cached_plans) T
GO


--- Dirty and Clean pages in buffer cache 
SELECT Page_Status = CASE 
                       WHEN is_modified = 1 THEN 'Dirty'
                       ELSE 'Clean'
                     END,
       DBName = DB_NAME(database_id),
       Pages = COUNT(1)
FROM sys.dm_os_buffer_descriptors
WHERE database_id = DB_ID('Honeywell.MES.Operations.DataModel.OperationsDB')
GROUP BY database_id,
         is_modified
GO

--dbcc dropcleanbuffers