CREATE OR ALTER VIEW vw_Equipments AS

SELECT 
	Eq.Equipment_PK_ID,
	Eq.HierarchyNode_PK_ID,
	Eq.ChildAssetName, 
	Eq.ChildAssetType,
	app.Application_Instance_Name		AS	ApplicationInstanceName,
	app.Application_Type				AS	Application_Type,
	app.Application_Type_Full_Name		AS	Application_Type_FullName,
	app.Version_Number					AS	VersionNumber,
	Eq.ParentAssetName, 
	Eq.ParentAssetType,
	Eq.ParentEquipment_PK_ID,
	Eq.ParentHierarchyNode_PK_ID

FROM 
(
SELECT 
	DISTINCT
	Eq_Child.Equipment_PK_ID			AS	Equipment_PK_ID,
	Eq_Child.HierarchyNode_PK_ID		AS	HierarchyNode_PK_ID,
	--Eq_Child.Parent_PK_ID				AS	Parent_PK_ID,
	Eq_Child.SourceAssetName			AS	ChildAssetName, 
	Eq_Child.SourceAssetType			AS	ChildAssetType,
	Eq_Child.Application_Instance_Id	AS	Application_Instance_Id,
	Eq_Parent.SourceAssetName			AS	ParentAssetName, 
	Eq_Parent.SourceAssetType			AS	ParentAssetType,
	Eq_Parent.Equipment_PK_ID			AS	ParentEquipment_PK_ID,
	Eq_Parent.HierarchyNode_PK_ID		AS	ParentHierarchyNode_PK_ID
	--Eq_Parent.Parent_PK_ID				AS	Parent_PK_ID,
	
FROM 
	Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent)
)Eq
	JOIN 
	(
	 SELECT 
		ai.id,ai.Application_Instance_Name ,aty.Application_Type, aty.Application_Type_Full_Name,aty.Version_Number 
	FROM 
		dbo.Application_Instance ai 
	JOIN 
		dbo.Application_Type aty 
	ON 
		ai.ApplicationType_Id = aty.id 
	)app
ON 
	Eq.Application_Instance_Id = app.id
	



GO

CREATE OR ALTER VIEW vw_Equipment_Master AS
SELECT DISTINCT
		EqSrc.Equipment_PK_ID		AS	Equipment_PK_ID, 
		EqSrc.SourceAssetName		AS	SourceAssetName , 
		EqSrc.SourceAssetType		AS	SourceAssetType,
		EqMaster.MasterAssetName	AS	EPMAssetName, 
		EqMaster.AssetType			AS	EPMAssetType
FROM 
	Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)
GO

-------------
