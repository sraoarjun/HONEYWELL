
SELECT * FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Buffer Manager%';

--Readahead time/sec                                                                                                              
--Page lookups/sec                                                                                                                




SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
FROM sys.dm_os_performance_counters  a
JOIN  (SELECT cntr_value, OBJECT_NAME 
    FROM sys.dm_os_performance_counters  
    WHERE counter_name = 'Buffer cache hit ratio base'
        AND OBJECT_NAME = 'MSSQL$MES:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
WHERE a.counter_name = 'Buffer cache hit ratio'
AND a.OBJECT_NAME = 'MSSQL$MES:Buffer Manager'