/*
https://www.sqlshack.com/sql-server-memory-performance-metrics-part-5-understanding-lazy-writes-free-list-stallssec-memory-grants-pending/
*/

DECLARE @LazyWrites1 bigint;
SELECT @LazyWrites1 = cntr_value
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Lazy writes/sec';
 
WAITFOR DELAY '00:00:10';
 
SELECT(cntr_value - @LazyWrites1) / 10 AS 'LazyWrites/sec'
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Lazy writes/sec';

  SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Memory Manager%'
AND [counter_name] = 'Memory Grants Pending'
 



SELECT *
FROM sys.dm_exec_query_memory_grants
WHERE grant_time IS NULL


SELECT 
	physical_memory_in_use_kb/1024 Physical_memory_in_use_MB, 
    large_page_allocations_kb/1024 Large_page_allocations_MB, 
    locked_page_allocations_kb/1024 Locked_page_allocations_MB,
    virtual_address_space_reserved_kb/1024 VAS_reserved_MB, 
    virtual_address_space_committed_kb/1024 VAS_committed_MB, 
    virtual_address_space_available_kb/1024 VAS_available_MB,
    page_fault_count Page_fault_count,
    memory_utilization_percentage Memory_utilization_percentage, 
    process_physical_memory_low Process_physical_memory_low, 
    process_virtual_memory_low Process_virtual_memory_low
FROM sys.dm_os_process_memory;
