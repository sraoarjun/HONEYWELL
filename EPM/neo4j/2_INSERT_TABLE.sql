USE [HwlAssets_EPM]
GO


-- Application_Type 
INSERT INTO 
	dbo.Application_Type(Application_Type,Application_Type_Full_Name,Version_Number)

SELECT	'M&R','Metrics & Reporting','131.0.0.1'
	UNION 
SELECT	'M&R','Metrics & Reporting','131.2.0.0'
	UNION 
SELECT	'OM','Operations Monitoring','131.0.0.1'
	UNION 
SELECT	'OM','Operations Monitoring','131.2.0.0'
	UNION 
SELECT	'Sentinel','Asset Sentinel','131.0.0.1'
	UNION 
SELECT	'Sentinel','Asset Sentinel','131.2.0.0'

GO


-- Application_Instance
INSERT INTO dbo.Application_Instance(ApplicationType_Id,Application_Instance_Name)
	Select 1,'M&R1'
		union 
	Select 1,'M&R2'
		union 
	Select 3,'OM1'
		union 
	Select 3,'OM2'
		union 
	Select 5,'Sentinel1'
		union 
	Select 5,'Sentinel2'
	
GO

---Equipments_Node_Csv (Generated through the CAM database) 
TRUNCATE TABLE [dbo].[Equipments_Node_Csv]
GO
INSERT INTO 
	[dbo].[Equipments_Node_Csv] (Equipment_PK_ID,HierarchyNode_PK_ID,SourceAssetName,SourceAssetType,Parent_PK_ID,Application_Instance_Id)

SELECT 
		eq.Equipment_PK_ID,
		a.HierarchyNode_PK_ID,a.DisplayName,eqt.DisplayName,
		CASE WHEN b.HierarchyNode_PK_ID IS NULL THEN a.HierarchyNode_PK_ID ELSE b.HierarchyNode_PK_ID END,1 -- M&R
FROM 
	HwlAssets_MR.dbo.HierarchyNodes a 
LEFT JOIN 
	HwlAssets_MR.dbo.HierarchyNodes b 
ON 
	a.Parent_PK_ID = b.HierarchyNode_PK_ID
LEFT JOIN 
		HwlAssets_MR.dbo.Equipments eq 
ON 
	a.EntityRefID = eq.Equipment_PK_ID
LEFT JOIN 
		HwlAssets_MR.dbo.EquipmentTypes eqt 
ON 
		eq.EquipmentType_PK_ID = eqt.EquipmentType_PK_ID
LEFT JOIN 
		HwlAssets_MR.dbo.Equipments eq1 
ON 
	b.EntityRefID = eq1.Equipment_PK_ID
LEFT JOIN 
		HwlAssets_MR.dbo.EquipmentTypes eqt1 
ON 
		eq1.EquipmentType_PK_ID = eqt1.EquipmentType_PK_ID



UNION 


SELECT 
	eq.Equipment_PK_ID,
	a.HierarchyNode_PK_ID,a.DisplayName,eqt.DisplayName,
	CASE WHEN b.HierarchyNode_PK_ID IS NULL THEN a.HierarchyNode_PK_ID ELSE b.HierarchyNode_PK_ID END,3 -- OM 
FROM 
	HwlAssets_OM.dbo.HierarchyNodes a 
LEFT JOIN 
	HwlAssets_OM.dbo.HierarchyNodes b 
ON 
	a.Parent_PK_ID = b.HierarchyNode_PK_ID
LEFT JOIN 
		HwlAssets_OM.dbo.Equipments eq 
ON 
	a.EntityRefID = eq.Equipment_PK_ID
LEFT JOIN 
		HwlAssets_OM.dbo.EquipmentTypes eqt 
ON 
		eq.EquipmentType_PK_ID = eqt.EquipmentType_PK_ID
LEFT JOIN 
		HwlAssets_OM.dbo.Equipments eq1 
ON 
	b.EntityRefID = eq1.Equipment_PK_ID
LEFT JOIN 
		HwlAssets_OM.dbo.EquipmentTypes eqt1 
ON 
		eq1.EquipmentType_PK_ID = eqt1.EquipmentType_PK_ID



UNION 


SELECT 
	eq.Equipment_PK_ID,
	a.HierarchyNode_PK_ID,a.DisplayName,eqt.DisplayName,
	CASE WHEN b.HierarchyNode_PK_ID IS NULL THEN a.HierarchyNode_PK_ID ELSE b.HierarchyNode_PK_ID END,5 -- Sentinel
FROM 
	HwlAssets_Sentinel.dbo.HierarchyNodes a 
LEFT JOIN 
	HwlAssets_Sentinel.dbo.HierarchyNodes b 
ON 
	a.Parent_PK_ID = b.HierarchyNode_PK_ID
LEFT JOIN 
		HwlAssets_Sentinel.dbo.Equipments eq 
ON 
	a.EntityRefID = eq.Equipment_PK_ID
LEFT JOIN 
		HwlAssets_Sentinel.dbo.EquipmentTypes eqt 
ON 
		eq.EquipmentType_PK_ID = eqt.EquipmentType_PK_ID
LEFT JOIN 
		HwlAssets_Sentinel.dbo.Equipments eq1 
ON 
	b.EntityRefID = eq1.Equipment_PK_ID
LEFT JOIN 
		HwlAssets_Sentinel.dbo.EquipmentTypes eqt1 
ON 
		eq1.EquipmentType_PK_ID = eqt1.EquipmentType_PK_ID

GO


--Equipments_MasterNode_Csv 
SET IDENTITY_INSERT [dbo].[Equipments_MasterNode_Csv] ON 

INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (1, N'Enterprise', N'Enterprise')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (2, N'Site_Master_1', N'Site')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (3, N'Site_Master_2', N'Site')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (4, N'Site_Master_3', N'Site')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (5, N'Plant_Master_1', N'Plant')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (6, N'Plant_Master_2', N'Plant')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (7, N'Plant_Master_3', N'Plant')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (8, N'Area_Master_1', N'Area')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (9, N'Area_Master_2', N'Area')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (10, N'Area_Master_3', N'Area')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (11, N'Unit_Master_1', N'Unit')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (12, N'Unit_Master_2', N'Unit')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (13, N'Unit_Master_3', N'Unit')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (14, N'Eq_Master_1', N'Equipment')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (15, N'Eq_Master_2', N'Equipment')
INSERT [dbo].[Equipments_MasterNode_Csv] ([Id], [MasterAssetName], [AssetType]) VALUES (16, N'Eq_Master_3', N'Equipment')

SET IDENTITY_INSERT [dbo].[Equipments_MasterNode_Csv] OFF
GO




