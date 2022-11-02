USE [master]
GO
DROP DATABASE [HFAMTagStore1]
GO

RESTORE FILELISTONLY FROM DISK = 'C:\ARJUN\HoneyWell\ALARMS\DynArchive\Purging\HFAMTagStore\HFAMTagStore.bak' WITH FILE = 1
GO


USE [master]
RESTORE DATABASE [HFAMTagStore1] FROM  
DISK = N'C:\ARJUN\HoneyWell\ALARMS\DynArchive\Purging\HFAMTagStore\HFAMTagStore.bak'
WITH  FILE = 1,  NOUNLOAD,  STATS = 5,
MOVE 'HFAMTagStore1' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER01\MSSQL\DATA\HFAMTagStore1.mdf',
MOVE 'HFAMTagStore1_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER01\MSSQL\DATA\HFAMTagStore1_log_1.ldf'
GO


