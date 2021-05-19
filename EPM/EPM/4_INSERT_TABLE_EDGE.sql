-- PARENT Edge Table Population
TRUNCATE TABLE dbo.PARENT_EDGE
GO
INSERT INTO dbo.PARENT_EDGE
 SELECT 
	a.$node_id , b.$node_id
	
	FROM 
		dbo.Equipments_Node a join dbo.Equipments_Node b 
	on 
		a.Parent_PK_ID = b.HierarchyNode_PK_ID
GO


TRUNCATE TABLE dbo.MAPS_TO_EDGE

INSERT INTO dbo.MAPS_TO_EDGE

--ENTERPRISE
VALUES 
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 4)
	,(SELECT $node_id from dbo.Equipments_MasterNode where AssetType ='Enterprise')
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 43)
	,(SELECT $node_id from dbo.Equipments_MasterNode where AssetType ='Enterprise')
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 45)
	,(SELECT $node_id from dbo.Equipments_MasterNode where AssetType ='Enterprise')
)
,
------------SITE_MASTER_1
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 14)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 2)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 16)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 2)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 47)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 2 )
)
,
--SITE_MASTER_2
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 13)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 3)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 44)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 3)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 46)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 3 )
)
,

--SITE_MASTER_3
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 7)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 4)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 26)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 4)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 27)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 4)
)
,

--PLANT_MASTER_1
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 10)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 5)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 15)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 5)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 18)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 5)
)
,

--PLANT_MASTER_2
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 3)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 6)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 33)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 6)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 35)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 6)
)
,
--PLANT_MASTER_3
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 20)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 7)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 22)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 7)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 40)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 7)
)
,

--AREA_MASTER_1
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 2)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 8)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 11)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 8)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 29)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 8)
)
,
--AREA_MASTER_2
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 31)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 9)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 38)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 9)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 42)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 9)
)
,

--AREA_MASTER_3
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 1)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 10)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 32)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 10)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 48)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 10)
)
,

--UNIT_MASTER_1
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 25)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 11)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 30)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 11)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 36)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 11)
)
,
--UNIT_MASTER_2
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 5)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 12)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 24)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 12)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 28)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 12)
)
,
--UNIT_MASTER_3
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 21)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 13)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 37)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 13)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 41)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 13)
)
,
--Eq_MASTER_1
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 9)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 14)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 12)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 14)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 19)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 14)
)
,

--Eq_MASTER_2
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 6)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 15)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 17)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 15)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 23)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 15)
)
,
--Eq_MASTER_3
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 8)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 16)
),

(
	(SELECT $node_id from dbo.Equipments_Node where Id = 34)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 16)
)
,
(
	(SELECT $node_id from dbo.Equipments_Node where Id = 39)
	,(SELECT $node_id from dbo.Equipments_MasterNode where Id = 16)
)
GO
