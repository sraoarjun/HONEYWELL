declare @plan_handle varbinary(max)
SELECT   plan_handle ,cp.objtype,object_name(st.objectid) as object_name,cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE OBJECT_NAME (st.objectid) LIKE '%sp_GetAssetCmtsAndRespsForUser%'

select @plan_handle = plan_handle 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE OBJECT_NAME (st.objectid) LIKE '%sp_GetAssetCmtsAndRespsForUser%'

DBCC FREEPROCCACHE (0x05000D00A0943D14D015988CC001000001000000000000000000000000000000000000000000000000000000) ;



SELECT plan_handle, st.text  , cp.size_in_bytes,cp.usecounts
FROM sys.dm_exec_cached_plans cp   
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st  
WHERE text LIKE N'%TagMonitorings%';


-- Plan Cache by object

SELECT text, cp.objtype, cp.size_in_bytes
	FROM sys.dm_exec_cached_plans AS cp 
	CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
	WHERE cp.cacheobjtype = N'Compiled Plan'
	AND cp.objtype IN (N'Adhoc', N'Prepared')
	AND cp.usecounts = 1



--- Plan cache size by CacheType 
SELECT 
        [objtype] AS [CacheType],
        COUNT_BIG(*) AS [Total Plans],
        SUM(CAST([size_in_bytes] AS DECIMAL(18,2)))/1024/1024 AS [Total MBs],
        AVG([usecounts]) AS [Avg Use Count],
        SUM(CAST((CASE WHEN [usecounts] = 1 THEN [size_in_bytes] ELSE 0 END) 
        AS DECIMAL(18,2)))/1024/1024 AS [Total MBs – USE Count 1],
        SUM(CASE WHEN [usecounts] = 1 THEN 1 ELSE 0 END) AS [Total Plans – USE Count 1]
    FROM [sys].[dm_exec_cached_plans]
    GROUP BY [objtype]
    ORDER BY [Total MBs – USE Count 1] DESC;

--- Total plan cache Size 
select SUM(CAST([size_in_bytes] AS DECIMAL(18,2)))/1024/1024 AS [Total MBs] from sys.dm_exec_cached_plans