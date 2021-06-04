USE master
GO
DROP DATABASE IF EXISTS [CorruptionTest]
GO
CREATE DATABASE [CorruptionTest]
GO
ALTER DATABASE [CorruptionTest] MODIFY FILE ( NAME = N'CorruptionTest', SIZE = 2GB )
GO
ALTER DATABASE [CorruptionTest] MODIFY FILE ( NAME = N'CorruptionTest_log', SIZE = 2GB )
GO
ALTER DATABASE [CorruptionTest] SET RECOVERY FULL;
GO
ALTER DATABASE [CorruptionTest] SET PAGE_VERIFY CHECKSUM  
GO

USE [CorruptionTest]
GO
CREATE TABLE dbo.mssqltips 
(increment INT, randomGUID uniqueidentifier, randomValue INT, BigCol CHAR(2000) DEFAULT 'a',
INDEX CIX_SQLShack_increment1 UNIQUE CLUSTERED (increment))
GO

SET NOCOUNT ON;
DECLARE @counter INT = 1;
BEGIN TRAN
   WHILE @counter <= 250000
   BEGIN
      INSERT INTO dbo.mssqltips (increment, randomGUID, randomValue) 
      VALUES (@counter, NEWID(), ABS(CHECKSUM(NewId())) % 140000000)

      SET @counter += 1
   END;
COMMIT TRAN;
GO


SELECT TOP 10
   sys.fn_PhysLocFormatter(%%physloc%%) PageId,
   *
FROM [CorruptionTest].[dbo].[mssqltips]

GO


DBCC TRACEON (3604);
GO
DBCC PAGE ('CorruptionTest', 1, 8426, 3);
GO