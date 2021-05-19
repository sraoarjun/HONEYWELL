
USE [HwlAssets_EPM]
GO

-----------------------------------
select * from Equipments_Node
select * from Equipments_MasterNode


select * from dbo.Equipments where Equipment_PK_ID IN ('797beb71-e50e-410d-8048-ed8565c820d8','0698286D-F827-4501-B244-6123773E5B2F')
-----------------------------------



DECLARE @MyString NVARCHAR(MAX), @c nchar(1) = N'\';
SET @MyString = 'Enterprise\SampleSite1\Plant1\Area1\Unit1\eq1'
--SELECT LEFT(@MyString, LEN(@MyString) - CHARINDEX('\',REVERSE(LEFT(@MyString, LEN(@MyString) - 1)))) AS Result    
SELECT top 2 
	value , CHARINDEX(@c + value + @c, @c + @MyString + @c) as indexPos
FROM 
	STRING_SPLIT(@MyString, '\')  as t order  by CHARINDEX(@c + value + @c, @c + @MyString + @c)  desc  ;

GO

DECLARE @MyString NVARCHAR(MAX), @c nchar(1) = N'\';
SET @MyString = 'Enterprise\SampleSite1\Plant1\Area1\Unit1\eq1'

select top 1  value from 
(
SELECT TOP 2 
	VALUE , CHARINDEX(@c + value + @c, @c + @MyString + @c) as indexPos
FROM 
	STRING_SPLIT(@MyString, '\')  as t order  by CHARINDEX(@c + value + @c, @c + @MyString + @c) desc

	)A order  by indexPos asc;
GO




DBCC CHECKIDENT ('[TestTable]', RESEED, 0);
GO

select * from HWlAssets_MR..Equipments
select * from HWlAssets_OM..Equipments
select * from HWlAssets_Sentinel..Equipments


select * from Equipments_Node where EquipmentType_PK_ID = '5F198E68-DF28-43D6-952D-AD8DFC3C79BD'

select * from Equipments_Node where EquipmentType_PK_ID = '6C17E1F4-22C0-4447-A674-DC092512E0C1'

select *  from EquipmentTypes


select b.Name , b.EquipmentType_PK_ID ,a.Name  from Equipments_Node a join 
(
		select EquipmentType_PK_ID ,Name from EquipmentTypes where Name = 'Enterprise'
			union 
		select EquipmentType_PK_ID ,Name from EquipmentTypes where Name = 'Site'
			union 
		select EquipmentType_PK_ID ,Name from EquipmentTypes where Name = 'Plant'
			union				   
		select EquipmentType_PK_ID ,Name from EquipmentTypes where Name = 'Area'
			union				   
		select EquipmentType_PK_ID ,Name from EquipmentTypes where Name = 'Unit'
			union				   
		select EquipmentType_PK_ID ,Name from EquipmentTypes where Name = 'Equipment'
)B 
ON 
	 a.EquipmentType_PK_ID = b.EquipmentType_PK_ID
--Group by 
--	 b.Name , b.EquipmentType_PK_ID 


select 
	en.EquipmentType_PK_ID , eqt.Name,eqt.DisplayName from Equipments_Node en join dbo.EquipmentTypes eqt on 
	en.EquipmentType_PK_ID= eqt.EquipmentType_PK_ID
order  by eqt.Name 
 

GO


SELECT eq_src.ID,eq_src.Name Src_Name,'-------->' MapsTo,eq_mst.Name Master_Name,  eq_src.Description , eq_mst.ID , eq_mst.Description
FROM Equipments_Node eq_src, isRelated, Equipments_MasterNode eq_mst
WHERE MATCH(eq_src-(isRelated)->eq_mst)
GO



SELECT 
	eq_src.ID				AS [Source_Asset_ID],
	eq_src.[Name]			AS [Source_Asset_Name],
	'-------->'				AS	[MapsTo],
	eq_mst.[Name]			AS	[Master_Asset_Name], 
	eq_mst.ID				AS	[Master_Asset_ID], 
	eq_mst.[Description]	AS	[Asset Description]
FROM 
	Equipments_Node eq_src, isRelated, Equipments_MasterNode eq_mst
WHERE 
	MATCH(eq_src-(isRelated)->eq_mst)
GO

/*
 Data Points to be added :

 a)	Application Type -- (Whether  M&R , OM or Sentinel etc) 
 b) Version No -- What is the application versionNumber for the installed Application ?(Refer table --> dbo.Versions)
 c)	Instance ID  -- What is the instance ID for this application ?
 d) Asset Type - Pull this from the source system 

 To identify the Source system / Application Types

*/

DECLARE @VersionNumber NVARCHAR(200) = (select top 1 versionNumber from dbo.Versions order by InstalledDate desc)
--select @VersionNumber as VersionNumber 

SELECT DISTINCT --A.*,eqt.Name AS [Asset_Type] FROM 
	--Grph.Source_Asset_ID,
	Grph.Source_Asset_Name,
	eqt.[Name] As [Source_Asset_Type],
	--MapsTo,
	Master_Asset_Name,	
	eq.Application_Type AS [Application_Type],
	@VersionNumber AS [Version Number]
	--Grph.Master_Asset_ID
	--[Asset Description]
FROM 
(
SELECT 
	eq_src.ID				AS [Source_Asset_ID],
	eq_src.[Name]			AS [Source_Asset_Name],
	'-------->'				AS	[MapsTo],
	eq_mst.[Name]			AS	[Master_Asset_Name], 
	eq_mst.ID				AS	[Master_Asset_ID], 
	eq_mst.[Description]	AS	[Asset Description]
FROM 
	Equipments_Node eq_src, isRelated, Equipments_MasterNode eq_mst
WHERE 
	MATCH(eq_src-(isRelated)->eq_mst)

)Grph

JOIN 
	Equipments_Node eqn 
ON 
	 Grph.Source_Asset_Name =  eqn.[Name]
JOIN 
	 EquipmentTypes eqt 
ON 
	 eqn.EquipmentType_PK_ID = eqt.EquipmentType_PK_ID
JOIN 
	 dbo.Equipments eq 
ON 
	eqn.Equipment_PK_ID = eq.Equipment_PK_ID

ORDER BY 
		Master_Asset_Name
GO

SELECT DISTINCT 
	Grph.Source_Asset_Name	AS	[Source Asset Name],
	eqt.[Name]				AS	[Source AssetType],
	Master_Asset_Name		AS	[Master Asset Name],	
	ap.Instance_Id			AS	[Instance Id],
	ap.Application_Type		AS	[Application Type],
	ap.Version_Number		AS	[Version Number]
FROM 
(
SELECT 
	eq_src.ID				AS [Source_Asset_ID],
	eq_src.[Name]			AS [Source_Asset_Name],
	'-------->'				AS	[MapsTo],
	eq_mst.[Name]			AS	[Master_Asset_Name], 
	eq_mst.ID				AS	[Master_Asset_ID], 
	eq_mst.[Description]	AS	[Asset Description]
FROM 
	Equipments_Node eq_src, isRelated, Equipments_MasterNode eq_mst
WHERE 
	MATCH(eq_src-(isRelated)->eq_mst)

)Grph

JOIN 
	Equipments_Node eqn 
ON 
	 Grph.Source_Asset_Name =  eqn.[Name]
JOIN 
	 EquipmentTypes eqt 
ON 
	 eqn.EquipmentType_PK_ID = eqt.EquipmentType_PK_ID
JOIN 
	 dbo.Equipments eq 
ON 
	eqn.Equipment_PK_ID = eq.Equipment_PK_ID

JOIN 
	 dbo.Application_Type ap 
ON 
	 eq.Application_Type_Id = ap.ID
ORDER BY 
		Master_Asset_Name
GO



select Source_ID , Master_Asset_ID from 
(

SELECT DISTINCT 
	eqn.ID					AS	[Source_ID],
	Master_Asset_ID			AS	[Master_Asset_ID],
	Grph.Source_Asset_Name	AS	[Source Asset Name],
	eqt.[Name]				AS	[Source AssetType],
	Master_Asset_Name		AS	[Master Asset Name],	
	ap.Instance_Id			AS	[Instance Id],
	ap.Application_Type		AS	[Application Type],
	ap.Version_Number		AS	[Version Number]
FROM 
(
SELECT 
	eq_src.ID				AS [Source_Asset_ID],
	eq_src.[Name]			AS [Source_Asset_Name],
	'-------->'				AS	[MapsTo],
	eq_mst.[Name]			AS	[Master_Asset_Name], 
	eq_mst.ID				AS	[Master_Asset_ID], 
	eq_mst.[Description]	AS	[Asset Description]
FROM 
	Equipments_Node eq_src, isRelated, Equipments_MasterNode eq_mst
WHERE 
	MATCH(eq_src-(isRelated)->eq_mst)

)Grph

JOIN 
	Equipments_Node eqn 
ON 
	 Grph.Source_Asset_Name =  eqn.[Name]
JOIN 
	 EquipmentTypes eqt 
ON 
	 eqn.EquipmentType_PK_ID = eqt.EquipmentType_PK_ID
JOIN 
	 dbo.Equipments eq 
ON 
	eqn.Equipment_PK_ID = eq.Equipment_PK_ID

JOIN 
	 dbo.Application_Type ap 
ON 
	 eq.Application_Type_Id = ap.ID

)A
Order by Master_Asset_Id
GO


SELECT 
				a.HierarchyNode_PK_ID,a.DisplayName,eqt.DisplayName,
				CASE WHEN b.HierarchyNode_PK_ID IS NULL THEN a.HierarchyNode_PK_ID ELSE b.HierarchyNode_PK_ID END,1
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
