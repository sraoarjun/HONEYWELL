DROP FUNCTION IF EXISTS dbo.udf_Get_DB_Cpu_Pct 
GO

/*

SELECT d.name,dbo.udf_Get_DB_Cpu_Pct (d.name) as usagepct
FROM sysdatabases d
ORDER BY usagepct desc

*/

CREATE FUNCTION dbo.udf_Get_DB_Cpu_Pct (@dbName sysname)
RETURNS decimal (6, 3)AS
BEGIN
 
   DECLARE @pct decimal (6, 3) = 0

   SELECT @pct = T.[CPUTimeAsPercentage]
   FROM
    (SELECT 
        [Database],
        CONVERT (DECIMAL (6, 3), [CPUTimeInMiliSeconds] * 1.0 / 
        SUM ([CPUTimeInMiliSeconds]) OVER () * 100.0) AS [CPUTimeAsPercentage]
     FROM 
      (SELECT 
          dm_execplanattr.DatabaseID,
          DB_Name(dm_execplanattr.DatabaseID) AS [Database],
          SUM (dm_execquerystats.total_worker_time) AS CPUTimeInMiliSeconds
       FROM sys.dm_exec_query_stats dm_execquerystats
       CROSS APPLY 
        (SELECT 
            CONVERT (INT, value) AS [DatabaseID]
         FROM sys.dm_exec_plan_attributes(dm_execquerystats.plan_handle)
         WHERE attribute = N'dbid'
        ) dm_execplanattr
       GROUP BY dm_execplanattr.DatabaseID
      ) AS CPUPerDb
    )  AS T
   WHERE T.[Database] = @dbName

   RETURN @pct
END
GO