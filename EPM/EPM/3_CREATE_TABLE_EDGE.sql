USE [EPM]
GO

--PARENT Edge Table Creation
DROP TABLE IF EXISTS PARENT_EDGE;
GO
CREATE TABLE PARENT_EDGE AS EDGE;
GO
---===============================================================================================================================================

--ASSET_TYPE Edge Table Creation 
DROP TABLE IF EXISTS ASSET_TYPE_EDGE;
GO
CREATE TABLE ASSET_TYPE_EDGE AS EDGE;
GO

---================================================================================================================================================

--MAPS_TO Edge Table Creation 
DROP TABLE IF EXISTS MAPS_TO_EDGE;
GO
CREATE TABLE MAPS_TO_EDGE AS EDGE;
GO
