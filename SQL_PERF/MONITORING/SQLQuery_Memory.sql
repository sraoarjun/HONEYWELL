USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

-- SQL Server Core and CPU information 

EXEC sys.xp_readerrorlog 0, 1, N'detected', N'socket';


SELECT socket_count, cores_per_socket, cpu_count
FROM sys.dm_os_sys_info;

GO


-- Get SQL  Server Memory Details  -- Pinal Dave

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





SELECT
(total_physical_memory_kb/1024) AS Total_OS_Memory_MB,
(available_physical_memory_kb/1024)  AS Available_OS_Memory_MB
FROM sys.dm_os_sys_memory;

SELECT  
(physical_memory_in_use_kb/1024) AS Memory_used_by_Sqlserver_MB,  
(locked_page_allocations_kb/1024) AS Locked_pages_used_by_Sqlserver_MB,  
(total_virtual_address_space_kb/1024) AS Total_VAS_in_MB,
process_physical_memory_low,  
process_virtual_memory_low  
FROM sys.dm_os_process_memory;


SELECT
sqlserver_start_time,
(committed_kb/1024) AS Total_Server_Memory_MB,
(committed_target_kb/1024)  AS Target_Server_Memory_MB
FROM sys.dm_os_sys_info;



SELECT
CASE instance_name WHEN '' THEN 'Overall' ELSE instance_name END AS NUMA_Node, cntr_value AS PLE_s
FROM sys.dm_os_performance_counters    
WHERE counter_name = 'Page life expectancy';


--SELECT * FROM sys.dm_os_performance_counters
--WHERE object_name LIKE '%Buffer Manager%';