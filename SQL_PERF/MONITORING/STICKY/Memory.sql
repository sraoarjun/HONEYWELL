SELECT
	CASE instance_name WHEN '' THEN 'Overall' ELSE instance_name END AS NUMA_Node, cntr_value AS PLE_s
	FROM sys.dm_os_performance_counters    
	WHERE counter_name = 'Page life expectancy'

	SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
	FROM sys.dm_os_performance_counters  a
	JOIN  (SELECT cntr_value, OBJECT_NAME 
		FROM sys.dm_os_performance_counters  
		WHERE counter_name = 'Buffer cache hit ratio base'
			AND OBJECT_NAME = 'MSSQL$MES:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
	WHERE a.counter_name = 'Buffer cache hit ratio'
	AND a.OBJECT_NAME = 'MSSQL$MES:Buffer Manager'



SELECT total_physical_memory_kb/1024 [Total Physical Memory in MB],
available_physical_memory_kb/1024 [Physical Memory Available in MB],
system_memory_state_desc
FROM sys.dm_os_sys_memory;


SELECT physical_memory_in_use_kb/1024 [Physical Memory Used in MB],
process_physical_memory_low [Physical Memory Low],
process_virtual_memory_low [Virtual Memory Low]
FROM sys.dm_os_process_memory;



SELECT committed_kb/1024 [SQL Server Committed Memory in MB],
committed_target_kb/1024 [SQL Server Target Committed Memory in MB]
FROM sys.dm_os_sys_info;