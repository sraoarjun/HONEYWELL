USE [EPM]
GO
---tesing ( not working ) -- STARTS
with Fmly
AS
(
   SELECT 
			r1.SourceAssetName AS TopNode,r2.SourceAssetName AS ChildNode,CAST(CONCAT(r1.SourceAssetName,'-<',r2.SourceAssetName) AS varchar(250)) AS Output,
			r1.$node_id AS parentid, r2.$node_id as bottomnode,1 as Tree
   FROM 
			Equipments_Node r1 
   JOIN 
		PARENT_EDGE e ON e.$from_id = r1.$node_id 
   JOIN 
		Equipments_Node r2 ON r2.$node_id = e.$to_id 
	where  r1.SourceAssetName IN('SampleSite3')  
	--and r1.application_instance_id = 1
	 
   UNION ALL
   SELECT 
			c.ChildNode,r.SourceAssetName,CAST(CONCAT(c.Output,'-<',r.SourceAssetName) AS varchar(250)),c.bottomnode,r.$node_id,Tree + 1
   FROM 
			Fmly c
   JOIN		
		PARENT_EDGE e ON e.$from_id = c.bottomnode
   JOIN 
		Equipments_Node r ON r.$node_id = e.$to_id
	where 
		 r.application_instance_id = 1
)
SELECT output FROM Fmly	



with Fmly
AS
(
	  SELECT 
				e.SourceAssetName AS TopNode,m.SourceAssetName AS ChildNode,CAST(CONCAT(e.SourceAssetName,'-<',m.SourceAssetName) AS varchar(250)) AS Output,
				e.$node_id AS parentid, m.$node_id as bottomnode,1 as Tree
	   FROM		
				Equipments_Node e ,PARENT_EDGE  PARENT, Equipments_Node as m
		WHERE MATCH 
					(e-(PARENT)->m)
	 AND   
					e.SourceAssetName IN('Eq3')   and e.application_instance_id = 1 
	
	 
   UNION ALL
   SELECT 
			c.ChildNode,r.SourceAssetName,CAST(CONCAT(c.Output,'-<',r.SourceAssetName) AS varchar(250)),c.bottomnode,r.$node_id,Tree + 1
   FROM 
			Fmly c
   JOIN		
		PARENT_EDGE e ON e.$from_id = c.bottomnode
   JOIN 
		Equipments_Node r ON r.$node_id = e.$to_id
	where 
		 r.application_instance_id = 1
)
SELECT output FROM Fmly	





GO

 SELECT 
			r1.SourceAssetName AS TopNode,r2.SourceAssetName AS ChildNode,CAST(CONCAT(r1.SourceAssetName,'-<',r2.SourceAssetName) AS varchar(250)) AS Output,
			r1.$node_id AS parentid, r2.$node_id as bottomnode,1 as Tree
   FROM 
			Equipments_Node r1 
   JOIN 
		PARENT_EDGE e ON e.$from_id = r1.$node_id 
   JOIN 
		Equipments_Node r2 ON r2.$node_id = e.$to_id 
	where  r1.SourceAssetName IN('Enterprise')  

SELECT 
e.SourceAssetName AS TopNode,m.SourceAssetName AS ChildNode,CAST(CONCAT(e.SourceAssetName,'-<',m.SourceAssetName) AS varchar(250)) AS Output,
e.$node_id AS parentid, m.$node_id as bottomnode,1 as Tree
FROM	Equipments_Node e ,PARENT_EDGE  PARENT, Equipments_Node as m
WHERE MATCH (e-(PARENT)->m)
and  e.SourceAssetName IN('Enterprise')  
	
---tesing ( not working ) -- ENDS





select * from [Equipments_Node] where SourceASsetName = 'Enterprise'


select * from dbo.Application_Type
select * from dbo.Application_Instance


select $node_id , * from dbo.Equipments_Node
select $node_id , * from dbo.Equipments_MasterNode


select * from dbo.PARENT_EDGE
select * from dbo.MAPS_TO_EDGE

select $node_id,ID,SourceAssetName,* from dbo.Equipments_Node where SourceAssetType = 'Equipment' 
select $node_id,* from dbo.Equipments_MasterNode where AssetType = 'Equipment' and MasterAssetName = 'Eq_Master_3'

select $node_id,* from dbo.Equipments_MasterNode 





select 
	Application_Instance_Id ,ai.ApplicationType_Id, count(1) as cnt  
from 
	dbo.Equipments_Node e join dbo.Application_Instance ai on e.Application_Instance_Id = ai.ApplicationType_Id
group by 
	Application_Instance_Id ,ai.ApplicationType_Id order by Application_Instance_Id 



select * from dbo.Application_Type
select * from dbo.Application_Instance

select * from dbo.Equipments_Node
select * from dbo.Equipments_MasterNode

select * from sys.tables where is_node = 1 


GO

SELECT Eq_Child.SourceAssetName , Eq_Child.SourceAssetType,'----->' AS PARENT ,Eq_Parent.SourceAssetName, Eq_Parent.SourceAssetType
FROM Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent);
GO

SELECT Eq_Child.SourceAssetName , Eq_Child.SourceAssetType,'----->' AS PARENT ,Eq_Parent.SourceAssetName, Eq_Parent.SourceAssetType
FROM Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent) and eq_child.SourceAssetName = 'SampleSite3';
GO


SELECT EqSrc.SourceAssetName , EqSrc.SourceAssetType,'----->' AS MAPS_TO ,EqMaster.MasterAssetName, EqMaster.AssetType
FROM Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster);
GO

SELECT 
	SourceAssetName,SourceAssetType,MasterAssetName,AssetType As MasterAssetType,ai.Application_Instance_Name,att.Application_Type,Version_Number 
FROM 
	(
		SELECT EqSrc.SourceAssetName , EqSrc.SourceAssetType,EqSrc.Application_Instance_Id,EqMaster.MasterAssetName, EqMaster.AssetType
		FROM Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster 
		WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)
	)A
	JOIN 
		 dbo.Application_instance ai on A.Application_Instance_Id = ai.Id
	JOIN  
		dbo.Application_Type att on ai.ApplicationType_Id = att.Id
GO


SELECT EqSrc.SourceAssetName , EqSrc.SourceAssetType,'----->' AS MAPS_TO ,EqMaster.MasterAssetName, EqMaster.AssetType
FROM Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)
AND 
	 EqMaster.MasterAssetName = 'Plant_Master_2';
GO


SELECT Eq_Child.SourceAssetName , Eq_Child.SourceAssetType,'----->' AS PARENT ,Eq_Parent.SourceAssetName, Eq_Parent.SourceAssetType
FROM Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent)
AND Eq_Child.SourceAssetName = 'Unit3' ;
GO



SELECT Eq_Child.SourceAssetName , Eq_Child.SourceAssetType,'----->' AS PARENT ,Eq_Parent.MasterAssetName, Eq_Parent.AssetType
FROM Equipments_Node Eq_Child, MAPS_TO_EDGE  MAPS_TO, Equipments_MasterNode Eq_Parent
WHERE MATCH(Eq_Child-(MAPS_TO)->Eq_Parent)
AND Eq_Parent.MasterAssetName = 'Unit_Master_2' ;
GO


---------------------------------------------------------------------------------------------------------------



SELECT emp.SourceAssetName as Child_Eq, emp2.SourceAssetName as Parent_Eq,emp.Application_instance_id
FROM Equipments_Node as emp, PARENT_EDGE as r, Equipments_Node as emp2 
WHERE MATCH(emp-(r)->emp2) emp.SourceAssetName = 'SiteA' 
--and emp.Application_instance_id = 1 
GO



SELECT EqSrc.SourceAssetName , EqSrc.SourceAssetType,'----->' AS MAPS_TO ,EqMaster.MasterAssetName, EqMaster.AssetType
FROM Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)
AND EqMaster.MasterAssetName = 'Site_master_2'
;

SELECT * FROM (
	SELECT eq.SourceAssetName as AssetName, 
	STRING_AGG(eq2.SourceAssetName, '->') WITHIN GROUP (GRAPH PATH) as [Path], LAST_VALUE(eq2.SourceAssetName) WITHIN GROUP (GRAPH PATH) as LastNode 
	FROM Equipments_Node as eq, 
	PARENT_EDGE FOR PATH as edg, 
	Equipments_Node FOR PATH as eq2 
	WHERE MATCH(SHORTEST_PATH(eq(-(edg)->eq2)+)) 
)as temp 
	WHERE temp.LastNode = 'Plant3' --SampleSite3,Plant3,Area3,Unit3,Eq3

GO

--Same query as above , however have included the MasterAssetName with the dataset
SELECT * FROM (
	SELECT eq.SourceAssetName as AssetName, 
			eqm.MasterAssetName ,
			STRING_AGG(eq2.SourceAssetName, '->') WITHIN GROUP (GRAPH PATH) as [Path], 
			LAST_VALUE(eq2.SourceAssetName) WITHIN GROUP (GRAPH PATH) as LastNode
	FROM Equipments_Node as eq, 
	PARENT_EDGE FOR PATH as edg, 
	Equipments_Node FOR PATH as eq2,
	Equipments_MasterNode eqm,
	MAPS_TO_EDGE mps
	WHERE MATCH(SHORTEST_PATH(eq(-(edg)->eq2)+) AND eq-(mps)->eqm) 
)as temp 
	WHERE temp.LastNode = 'Plant3' --SampleSite3,Plant3,Area3,Unit3,Eq3

GO

SELECT * FROM (
SELECT eq.SourceAssetName as AssetName, 
STRING_AGG(eq2.SourceAssetName, '->') WITHIN GROUP (GRAPH PATH) as [Path], LAST_VALUE(eq2.SourceAssetName) WITHIN GROUP (GRAPH PATH) as LastNode 
FROM Equipments_Node as eq, 
PARENT_EDGE FOR PATH as edg, 
Equipments_Node FOR PATH as eq2 
WHERE MATCH(SHORTEST_PATH(eq(-(edg)->eq2)+)) 
and  eq.Application_instance_id = 5
) as temp 
WHERE temp.LastNode = 'Enterprise'

GO




SELECT * FROM 
(
SELECT 
	eq.SourceAssetName As AssetName, 
	STRING_AGG(eq2.SourceAssetName, '->') WITHIN GROUP (GRAPH PATH) as ParentAssetName,eq.Application_instance_id ,
	LAST_VALUE(eq2.SourceAssetName) WITHIN GROUP (GRAPH PATH) as LastNode 
FROM 
	Equipments_Node as eq, 
	PARENT_EDGE FOR PATH as edg, 
	Equipments_Node FOR PATH as eq2 
WHERE MATCH(SHORTEST_PATH(eq(-(edg)->eq2){1,5})) 


)temp
WHERE 
	 temp.LastNode = 'Enterprise'-- Enterprise,SiteTwo,AreaTwo,PlantTwo,UnitTwo,EqTwo
and 
	 application_instance_id = 5
