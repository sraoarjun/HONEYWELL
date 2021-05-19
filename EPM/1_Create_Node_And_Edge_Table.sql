USE [HwlAssets_EPM]
GO


DROP TABLE IF EXISTS Equipments_Node
GO
CREATE TABLE Equipments_Node
(
[ID] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
[Name] VARCHAR(20) NOT NULL,
[Description] VARCHAR(50) NULL,
[Equipment_PK_ID] [uniqueidentifier] NOT NULL,
[EquipmentType_PK_ID] [uniqueidentifier] NOT NULL,
[CreatedDate] [datetime] default (getdate()),
) AS NODE


DROP TABLE IF EXISTS Equipments_MasterNode
GO
CREATE TABLE Equipments_MasterNode
(
[ID] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
[Name] VARCHAR(20) NOT NULL,
[Description] VARCHAR(50) NULL,
[Equipment_PK_ID] [uniqueidentifier] NULL,
[EquipmentType_PK_ID] [uniqueidentifier] NOT NULL,
[CreatedDate] [datetime] default (getdate()),
) AS NODE

GO



--- CREATION OF EDGE TABLE(s)
DROP TABLE IF EXISTS isRelated 
GO
CREATE TABLE isRelated AS EDGE
GO
