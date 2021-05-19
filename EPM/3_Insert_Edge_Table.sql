USE [HwlAssets_EPM]
GO


---Enterprise
INSERT INTO isRelated 
VALUES(
 (SELECT $node_id FROM Equipments_Node src WHERE src.ID = 37),
 (SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 1)
 ),
(
	(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 38),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 1)
),
( 
(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 39),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 1)
)
GO


---Site_1
INSERT INTO isRelated 
VALUES(
 (SELECT $node_id FROM Equipments_Node src WHERE src.ID = 28),
 (SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 2)
 ),
(
	(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 31),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 2)
),
( 
(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 34),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 2)
),

---Site_2
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 29),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 3)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 32),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 3)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 36),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 3)
)

---Site_3

,(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 30),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 4)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 33),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 4)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 35),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 4)
)
GO



---Plant_1
INSERT INTO isRelated 
VALUES(
 (SELECT $node_id FROM Equipments_Node src WHERE src.ID = 40),
 (SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 5)
 ),
(
	(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 43),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 5)
),
( 
(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 46),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 5)
),

---Plant_2
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 41),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 6)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 44),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 6)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 48),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 6)
)

---Plant_3

,(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 42),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 7)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 45),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 7)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 47),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 7)
)

GO



---Area_1
INSERT INTO isRelated 
VALUES(
 (SELECT $node_id FROM Equipments_Node src WHERE src.ID = 1),
 (SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 8)
 ),
(
	(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 4),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 8)
),
( 
(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 7),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 8)
),

---Area_2
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 2),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 9)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 5),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 9)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 9),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 9)
)

---Area_3

,(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 3),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 10)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 6),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 10)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 8),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 10)
)

GO



---Unit_1
INSERT INTO isRelated 
VALUES(
 (SELECT $node_id FROM Equipments_Node src WHERE src.ID = 10),
 (SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 11)
 ),
(
	(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 13),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 11)
),
( 
(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 16),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 11)
),

---Unit_2
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 11),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 12)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 14),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 12)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 18),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 12)
)

---Unit_3

,(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 12),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 13)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 15),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 13)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 17),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 13)
)

GO



---Equipment_1
INSERT INTO isRelated 
VALUES(
 (SELECT $node_id FROM Equipments_Node src WHERE src.ID = 19),
 (SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 14)
 ),
(
	(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 22),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 14)
),
( 
(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 25),
	(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 14)
),

---Equipment_2
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 20),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 15)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 23),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 15)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 27),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 15)
)

---Equipment_3

,(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 21),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 16)
 ),
(
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 24),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 16)
),
( 
		(SELECT $node_id FROM Equipments_Node src WHERE src.ID = 26),
		(SELECT $node_id FROM Equipments_MasterNode mst WHERE mst.ID = 16)
)

GO




 