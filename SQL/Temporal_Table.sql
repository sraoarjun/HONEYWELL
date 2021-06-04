/*
https://blog.dbi-services.com/sql-server-temporal-table-how-to-store-a-history-table-in-another-file/
*/

USE [master]
GO
DROP DATABASE IF EXISTS [Zoo] 
GO
CREATE DATABASE [Zoo]
GO
ALTER DATABASE [Zoo] ADD FILEGROUP [HISTORY]
GO
ALTER DATABASE [Zoo] ADD FILE ( NAME = N'Zoo_History', FILENAME = N'C:\ARJUN\DATA\Zoo_History.ndf' , SIZE = 131072KB , FILEGROWTH = 131072KB )
 TO FILEGROUP [HISTORY]
GO

USE [Zoo]
GO
CREATE SCHEMA [History] AUTHORIZATION [dbo]
GO
CREATE TABLE [History].[AnimalsHistory]
(
 [AnimalId] [int]  NOT NULL,
 [Name] [varchar](200) NOT NULL,
 [Genus Species] [varchar](200) NOT NULL,
 [Number]  [int] NOT NULL,
 [StartDate] [datetime2]  NOT NULL,
 [EndDate]  [datetime2] NOT NULL,
 
) ON [HISTORY]

GO


CREATE TABLE [dbo].[Animals]
(
 [AnimalId] [int]  NOT NULL,
 [Name] [varchar](200) NOT NULL,
 [Genus Species] [varchar](200) NOT NULL,
 [Number]  [int] NOT NULL,
  CONSTRAINT [PK_Animals] PRIMARY KEY CLUSTERED ([AnimalId] ASC),
  /*Temporal: Define the Period*/
  [StartDate] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
  [EndDate]  [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 PERIOD FOR SYSTEM_TIME([StartDate],[EndDate])
) 
 WITH (SYSTEM_VERSIONING=ON (HISTORY_TABLE = [History].[AnimalsHistory]))

 GO


 INSERT INTO [Zoo].[dbo].[Animals]([AnimalId],[Name],[Genus Species],[Number])
     VALUES(1,'African wild cat','Felis silvestris lybica',10)
GO
 
UPDATE [Zoo].[dbo].[Animals] SET Number = 21 WHERE Name = 'African wild cat' AND  [Genus Species]= 'Felis silvestris lybica';
GO
UPDATE [Zoo].[dbo].[Animals] SET Number = 5 WHERE Name = 'African wild cat' AND  [Genus Species]= 'Felis silvestris lybica';
GO
UPDATE [Zoo].[dbo].[Animals] SET Number = 12 WHERE Name = 'African wild cat' AND  [Genus Species]= 'Felis silvestris lybica';
GO
UPDATE [Zoo].[dbo].[Animals] SET Number = 20 WHERE Name = 'African wild cat' AND  [Genus Species]= 'Felis silvestris lybica';
GO



select * from dbo.Animals

select * from History.AnimalsHistory