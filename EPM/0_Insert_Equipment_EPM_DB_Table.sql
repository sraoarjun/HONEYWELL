USE [HwlAssets_EPM]
GO

DROP TABLE IF EXISTS dbo.Application_Type
GO
CREATE TABLE dbo.Application_Type
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Instance_Id INT,
	Application_Type VARCHAR(50),
	Application_Type_Full_Name VARCHAR(250),
	Version_Number Varchar(50)
)

INSERT INTO dbo.Application_Type
VALUES 
(
	1,'M&R','Metrics & Reporting','131.0.0.1'
),
(
	2,'M&R','Metrics & Reporting','131.2.0.0'
),
(
	1,'OM','Operations Monitoring','131.0.0.1'
),
(
	2,'OM','Operations Monitoring','131.2.0.0'
),
(
	1,'Sentinel','Asset Sentinel','131.0.0.1'
),
(
	2,'Sentinel','Asset Sentinel','131.2.0.0'
)

GO


--select * from dbo.Application_Type

IF NOT EXISTS 
	(
		SELECT 1 FROM 
					INFORMATION_SCHEMA.COLUMNS 
		WHERE 
			TABLE_NAME = 'Equipments' AND TABLE_SCHEMA = 'dbo'
		AND 
			COLUMN_NAME = 'Application_Type_Id'
	)
BEGIN 
	ALTER TABLE dbo.Equipments ADD Application_Type_Id INT
END 



DELETE FROM dbo.Equipments WHERE EquipmentClusteredId >  0
GO

DBCC CHECKIDENT ('[dbo].[Equipments]', RESEED, 0);
GO

DBCC CHECKIDENT ('[dbo].[Equipments]', RESEED, 0);
GO



INSERT INTO [dbo].[Equipments]
           ([Name]
           ,[Description]
           ,[IsClass]
           ,[Criticality]
           ,[Mode]
           ,[Performance]
           ,[Status]
           ,[Priority]
           ,[Owner]
           ,[SecurityCode]
           ,[ConfirmStatus]
           ,[InheritStatus]
           ,[Transponder]
           ,[Order]
           ,[InheritModeCategory]
           ,[CreatedDate]
           ,[ModifiedDate]
           ,[IsDeleted]
           ,[DeletedTime]
           ,[Equipment_PK_ID]
           ,[EquipmentType_PK_ID]
           ,[Location_PK_ID]
           ,[ModeCategory_PK_ID]
           ,[ModeType_PK_ID]
           ,[DisplayName]
           ,[FilterTag]
           ,[Timezone]
           ,[Latitude]
           ,[Longitude]
           ,[Location]
           ,[AssetId]
		   ,[Application_Type_Id]
		   )
    

	SELECT 
			[Name]
           ,[Description]
           ,[IsClass]
           ,[Criticality]
           ,[Mode]
           ,[Performance]
           ,[Status]
           ,[Priority]
           ,[Owner]
           ,[SecurityCode]
           ,[ConfirmStatus]
           ,[InheritStatus]
           ,[Transponder]
           ,[Order]
           ,[InheritModeCategory]
           ,[CreatedDate]
           ,[ModifiedDate]
           ,[IsDeleted]
           ,[DeletedTime]
           ,[Equipment_PK_ID]
           ,[EquipmentType_PK_ID]
           ,[Location_PK_ID]
           ,[ModeCategory_PK_ID]
           ,[ModeType_PK_ID]
           ,[DisplayName]
           ,[FilterTag]
           ,[Timezone]
           ,[Latitude]
           ,[Longitude]
           ,[Location]
           ,[AssetId]
		   ,1

FROM 
	 [HwlAssets_MR].[dbo].[Equipments]
GO

INSERT INTO [dbo].[Equipments]
           ([Name]
           ,[Description]
           ,[IsClass]
           ,[Criticality]
           ,[Mode]
           ,[Performance]
           ,[Status]
           ,[Priority]
           ,[Owner]
           ,[SecurityCode]
           ,[ConfirmStatus]
           ,[InheritStatus]
           ,[Transponder]
           ,[Order]
           ,[InheritModeCategory]
           ,[CreatedDate]
           ,[ModifiedDate]
           ,[IsDeleted]
           ,[DeletedTime]
           ,[Equipment_PK_ID]
           ,[EquipmentType_PK_ID]
           ,[Location_PK_ID]
           ,[ModeCategory_PK_ID]
           ,[ModeType_PK_ID]
           ,[DisplayName]
           ,[FilterTag]
           ,[Timezone]
           ,[Latitude]
           ,[Longitude]
           ,[Location]
           ,[AssetId]
		   ,[Application_Type_Id]
		   )
    

	SELECT 
			[Name]
           ,[Description]
           ,[IsClass]
           ,[Criticality]
           ,[Mode]
           ,[Performance]
           ,[Status]
           ,[Priority]
           ,[Owner]
           ,[SecurityCode]
           ,[ConfirmStatus]
           ,[InheritStatus]
           ,[Transponder]
           ,[Order]
           ,[InheritModeCategory]
           ,[CreatedDate]
           ,[ModifiedDate]
           ,[IsDeleted]
           ,[DeletedTime]
           ,[Equipment_PK_ID]
           ,[EquipmentType_PK_ID]
           ,[Location_PK_ID]
           ,[ModeCategory_PK_ID]
           ,[ModeType_PK_ID]
           ,[DisplayName]
           ,[FilterTag]
           ,[Timezone]
           ,[Latitude]
           ,[Longitude]
           ,[Location]
           ,[AssetId]
		   ,3

FROM 
		[HwlAssets_OM].[dbo].[Equipments]
GO

INSERT INTO [dbo].[Equipments]
           ([Name]
           ,[Description]
           ,[IsClass]
           ,[Criticality]
           ,[Mode]
           ,[Performance]
           ,[Status]
           ,[Priority]
           ,[Owner]
           ,[SecurityCode]
           ,[ConfirmStatus]
           ,[InheritStatus]
           ,[Transponder]
           ,[Order]
           ,[InheritModeCategory]
           ,[CreatedDate]
           ,[ModifiedDate]
           ,[IsDeleted]
           ,[DeletedTime]
           ,[Equipment_PK_ID]
           ,[EquipmentType_PK_ID]
           ,[Location_PK_ID]
           ,[ModeCategory_PK_ID]
           ,[ModeType_PK_ID]
           ,[DisplayName]
           ,[FilterTag]
           ,[Timezone]
           ,[Latitude]
           ,[Longitude]
           ,[Location]
           ,[AssetId]
		   ,[Application_Type_Id]
		   )
    

	SELECT 
			[Name]
           ,[Description]
           ,[IsClass]
           ,[Criticality]
           ,[Mode]
           ,[Performance]
           ,[Status]
           ,[Priority]
           ,[Owner]
           ,[SecurityCode]
           ,[ConfirmStatus]
           ,[InheritStatus]
           ,[Transponder]
           ,[Order]
           ,[InheritModeCategory]
           ,[CreatedDate]
           ,[ModifiedDate]
           ,[IsDeleted]
           ,[DeletedTime]
           ,[Equipment_PK_ID]
           ,[EquipmentType_PK_ID]
           ,[Location_PK_ID]
           ,[ModeCategory_PK_ID]
           ,[ModeType_PK_ID]
           ,[DisplayName]
           ,[FilterTag]
           ,[Timezone]
           ,[Latitude]
           ,[Longitude]
           ,[Location]
           ,[AssetId]
		   ,5

FROM 
	 [HwlAssets_Sentinel].[dbo].[Equipments]
GO




