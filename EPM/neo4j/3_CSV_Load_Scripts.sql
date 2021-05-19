USE [HwlAssets_EPM]
GO
----CSV Load Script for Equipments_Node.csv


SELECT 
	Equipment_PK_Id,
	HieararchyNode_PK_Id,
	SourceAssetName,
	SourceAssetType,
	InstanceName,
	ApplicationType,
	VersionNumber,
	Parent_HieararchyNode_PK_Id,
	Parent_Equipment_PK_Id
FROM 
(
SELECT 
	a.Id as Child_Equipment_id,
	a.Equipment_PK_ID as Equipment_PK_Id,
	a.HierarchyNode_PK_ID as HieararchyNode_PK_Id ,
	a.SourceAssetName,
	a.SourceAssetType,
	apt.Application_Instance_Name as InstanceName,
	ap.Application_Type as ApplicationType,
	ap.Version_Number as VersionNumber,
	b.Id as parent_node_id,
	b.HierarchyNode_PK_ID as Parent_HieararchyNode_PK_Id,
	b.Equipment_PK_ID as Parent_Equipment_PK_Id
	
	FROM 
		dbo.Equipments_Node_Csv a join dbo.Equipments_Node_Csv b 
	on 
		a.Parent_PK_ID = b.HierarchyNode_PK_ID
	join
		 dbo.Application_Instance apt 
	on 
		 a.Application_Instance_Id = apt.Id
	join 
		 dbo.Application_Type ap 
	on 
		 apt.ApplicationType_Id = ap.Id 

)A
GO




----CSV Load Script for Equipments_MasterNode.csv
SELECT 
	id , MasterAssetName , AssetType  
FROM 
	dbo.Equipments_MasterNode_Csv
GO

