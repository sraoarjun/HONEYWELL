/*
Check the below properties: 

	1)  Server Authentication should be "SQL Server and Windows Authentication mode"
	2)  SQL Collation - This should be "SQL_Latin1_General_CP1_CI_AS"
	3)	Check if SQL Server Agent is running - Check for the value of Status_desc as  "Running" and Start_type_desc as "Automatic"
*/

-- Check SQL Sevrer info

declare @version varchar(4)
select @version = substring(@@version,22,4)


IF CONVERT(SMALLINT, @version) >= 2012
EXEC ('SELECT	
		SERVERPROPERTY(''ServerName'') AS [Instance Name],
		CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY(''ProductVersion'')),4) 
			WHEN ''11.0'' THEN ''SQL Server 2012''
			WHEN ''12.0'' THEN ''SQL Server 2014''
			ELSE ''Newer than SQL Server 2014''
		END AS [Version Build],
		SERVERPROPERTY (''Edition'') AS [Edition],
		SERVERPROPERTY(''ProductLevel'') AS [Service Pack],
		CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'') 
			WHEN 0 THEN ''SQL Server and Windows Authentication mode''
			WHEN 1 THEN ''Windows Authentication mode''
		END AS [Server Authentication],
		CASE SERVERPROPERTY(''IsClustered'') 
			WHEN 0 THEN ''False''
			WHEN 1 THEN ''True''
		END AS [Is Clustered?],
		SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
		SERVERPROPERTY(''Collation'') AS [ SQL Collation],
		[cpu_count] AS [CPUs],
		[physical_memory_kb]/1024 AS [RAM (MB)]
	FROM	
		[sys].[dm_os_sys_info]')
ELSE IF CONVERT(SMALLINT, @version) >= 2005
EXEC ('SELECT	
		SERVERPROPERTY(''ServerName'') AS [Instance Name],
		CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY(''ProductVersion'')),4) 
			WHEN ''9.00'' THEN ''SQL Server 2005''
			WHEN ''10.0'' THEN ''SQL Server 2008''
			WHEN ''10.5'' THEN ''SQL Server 2008 R2''
		END AS [Version Build],
		SERVERPROPERTY (''Edition'') AS [Edition],
		SERVERPROPERTY(''ProductLevel'') AS [Service Pack],
		CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'') 
			WHEN 0 THEN ''SQL Server and Windows Authentication mode''
			WHEN 1 THEN ''Windows Authentication mode''
		END AS [Server Authentication],
		CASE SERVERPROPERTY(''IsClustered'') 
			WHEN 0 THEN ''False''
			WHEN 1 THEN ''True''
		END AS [Is Clustered?],
		SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
		SERVERPROPERTY(''Collation'') AS [ SQL Collation],
		[cpu_count] AS [CPUs],
		[physical_memory_in_bytes]/1048576 AS [RAM (MB)]
	FROM	
		[sys].[dm_os_sys_info]')
ELSE 
SELECT 'This SQL Server instance is running SQL Server 2000 or lower! You will need alternative methods in getting the SQL Server instance level information.'

GO




SELECT * FROM sys.dm_server_services where servicename = 'SQLAgent$MSSQLSERVER01';

SELECT * FROM sys.dm_os_sys_info;

SELECT *
             FROM master.dbo.sysprocesses 
             WHERE program_name = N'SQLAgent - Generic Refresher'

SELECT status_desc FROM sys.dm_server_services  where process_id = (select hostprocess from master.dbo.sysprocesses where program_name = N'SQLAgent - Generic Refresher')





IF EXISTS (SELECT 1 
             FROM master.dbo.sysprocesses 
             WHERE program_name = N'SQLAgent - Generic Refresher')
BEGIN
	PRINT 'SQL Server Agent is Running'
    SELECT @@SERVERNAME AS 'InstanceName', 1 AS 'SQLServerAgentRunning'
END
ELSE 
BEGIN
	PRINT 'SQL Server Agent is Stopped'
    SELECT @@SERVERNAME AS 'InstanceName', 0 AS 'SQLServerAgentRunning'
END


