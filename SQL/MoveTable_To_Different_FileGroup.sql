/*
https://www.mssqltips.com/sqlservertip/5832/move-sql-server-tables-to-different-filegroups/
*/

USE TestDB
GO

DROP TABLE IF EXISTS dbo.UserData
GO

--Tables
CREATE TABLE dbo.UserData
(
  UserID INT NOT NULL,
  LoginName NVARCHAR(50),
  PRIMARY KEY (UserID)
)
GO 

DROP TABLE IF EXISTS dbo.UserLog
GO

CREATE TABLE dbo.UserLog
(
  UserLogID INT NOT NULL IDENTITY(1,1),
  UserID INT NOT NULL,
  LoginDate DATETIME DEFAULT GETDATE(),
  PRIMARY KEY (UserLogID)
)
GO 

--Data
INSERT INTO UserData(UserID,LoginName)
VALUES(1,'tom@testuniversity.com'),
      (2,'sam@testuniversity.com '),
      (3,'jane@testuniversity.com'),
      (4,'ann@testuniversity.com')

INSERT INTO UserLog(UserID)
VALUES(1),(2)

WAITFOR DELAY '00:00:10'

INSERT INTO UserLog(UserID)
VALUES(1),(3),(4)

WAITFOR DELAY '00:00:10'

INSERT INTO UserLog(UserID)
VALUES(2),(3),(1)

GO


select * from dbo.UserData
select * from dbo.UserLog

ALTER DATABASE TestDB ADD FILEGROUP HISTORY
ALTER DATABASE TestDB
ADD FILE
(
NAME='History_Data',
FILENAME = 'C:\ARJUN\DATA\TesDB_2.mdf'
)
TO FILEGROUP HISTORY
GO


SELECT * FROM sys.filegroups
GO
select * from sys.database_files

SELECT o.[name] AS TableName, i.[name] AS IndexName, fg.[name] AS FileGroupName
FROM sys.indexes i
INNER JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id]
WHERE i.data_space_id = fg.data_space_id AND o.type = 'U'

GO


--- Drop the clustered index and move to secondary file group 

--ALTER TABLE UserLog
--DROP CONSTRAINT PK__UserLog__7F8B815160CC916E WITH (MOVE TO HISTORY)
--GO


--- Drop and re-create the clustered index on the secondary file group 
CREATE UNIQUE CLUSTERED INDEX [PK__UserLog__7F8B815155669706] ON UserLog (UserLogID)  
    WITH (DROP_EXISTING = ON)  
    ON HISTORY

GO


SELECT o.[name] AS TableName, i.[name] AS IndexName, fg.[name] AS FileGroupName
FROM sys.indexes i
INNER JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id]
WHERE i.data_space_id = fg.data_space_id AND o.type = 'U'

GO


--- Move the data from Secondary file group back to Primary File Group 
CREATE UNIQUE CLUSTERED INDEX [PK__UserLog__7F8B815155669706] ON UserLog (UserLogID)  
    WITH (DROP_EXISTING = ON)  
    ON [PRIMARY]

GO


------

-- Create copy of the table and all data in different filegroup
SELECT * INTO UserLogHistory1 ON HISTORY 
FROM UserLog
GO


SELECT * INTO UserLogHistory2 ON HISTORY 
FROM UserLog 
WHERE LoginDate > '2018-11-15 16:31:33.983'
GO


SELECT * INTO UserLogHistory3 ON HISTORY 
FROM UserLog 
WHERE 1=4
GO



SELECT o.[name] AS TableName, i.[name] AS IndexName, fg.[name] AS FileGroupName
FROM sys.indexes i 
INNER JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id]
WHERE i.data_space_id = fg.data_space_id AND o.type = 'U'
GO


------------------------------CELAN UP SCRIPTS-------------------

-- Drop the associated tables

DROP TABLE IF EXISTS dbo.UserData
DROP TABLE IF EXISTS dbo.UserLog
DROP TABLE IF EXISTS dbo.UserLogHistory1
DROP TABLE IF EXISTS dbo.UserLogHistory2
DROP TABLE IF EXISTS dbo.UserLogHistory3

GO


ALTER DATABASE [TestDB] REMOVE FILE [History_Data]
GO

ALTER DATABASE [TestDB] REMOVE FILEGROUP [History]
GO


