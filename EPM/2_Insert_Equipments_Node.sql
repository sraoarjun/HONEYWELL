USE [HwlAssets_EPM]
GO
---One time insert script for Equipments_Node Table 
INSERT INTO 
	Equipments_Node ([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
SELECT 
	[Name] , [Description],Equipment_PK_ID,EquipmentType_PK_ID 
from 
	dbo.Equipments
GO
------------=====================ENTERPRISE--=======================================

INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Enterprise','Enterprise',NULL,'F445459A-F3EC-4F95-AFD2-BDFD23D1C290')



------------=====================SITE--=======================================
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Site_1','Site One',NULL,'3F883AFB-1685-4BB9-A043-B189888DDF4E')

INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Site_2','Site Two',NULL,'3F883AFB-1685-4BB9-A043-B189888DDF4E')


INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Site_3','Site Three',NULL,'3F883AFB-1685-4BB9-A043-B189888DDF4E')



------------=====================PLANT--=======================================
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Plant_1','Plant One',NULL,'6C17E1F4-22C0-4447-A674-DC092512E0C1')

INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Plant_2','Plant Two',NULL,'6C17E1F4-22C0-4447-A674-DC092512E0C1')


INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Plant_3','Plant Three',NULL,'6C17E1F4-22C0-4447-A674-DC092512E0C1')




------------=====================AREA--=======================================
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Area_1','Area One',NULL,'FC70A3B1-B8B2-4E17-A188-2996DB931F57')

INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Area_2','Area Two',NULL,'FC70A3B1-B8B2-4E17-A188-2996DB931F57')


INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Area_3','Area Three',NULL,'FC70A3B1-B8B2-4E17-A188-2996DB931F57')




------------=====================UNITS--=======================================
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Unit_1','Unit One',NULL,'9FFC0957-7E25-4183-8ECC-A93FAF2B8C50')
		
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Unit_2','Unit Two',NULL,'9FFC0957-7E25-4183-8ECC-A93FAF2B8C50')

INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Unit_3','Unit Three',NULL,'9FFC0957-7E25-4183-8ECC-A93FAF2B8C50')



------------=====================EQUIPMENTS--=======================================
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Eq_1','Equipment One',NULL,'5F198E68-DF28-43D6-952D-AD8DFC3C79BD')
		
INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Eq_2','Equipment Two',NULL,'5F198E68-DF28-43D6-952D-AD8DFC3C79BD')

INSERT INTO 
	Equipments_MasterNode 
	([Name],[Description],Equipment_PK_ID,EquipmentType_PK_ID)
VALUES 
	('Eq_3','Equipment Three',NULL,'5F198E68-DF28-43D6-952D-AD8DFC3C79BD')




