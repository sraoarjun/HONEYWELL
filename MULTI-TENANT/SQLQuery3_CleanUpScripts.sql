USE [MultiTenantDB]
GO

/*
Clean up scripts to drop all the relavent objects and their dependencies 
*/

-- Drop the Procedures
DROP PROCEDURE IF EXISTS Site_01.sp_select_Equipments
GO
DROP PROCEDURE IF EXISTS Site_02.sp_select_Equipments
GO
DROP PROCEDURE IF EXISTS sch_cmn.sp_select_Configuration
GO

--Drop the tables 
Drop TABLE IF EXISTS Site_01.Equipments
GO
Drop TABLE IF EXISTS Site_02.Equipments 
GO
DROP TABLE IF EXISTS [sch_cmn].[tblConfiguration]
GO

--Drop the Schemas
DROP SCHEMA IF EXISTS [Site_01]
GO
DROP SCHEMA IF EXISTS  [Site_02]
GO
DROP SCHEMA IF EXISTS [sch_cmn]
GO

--- Drop the Users
DROP USER IF EXISTS [Usr_Site_01]
GO
DROP USER IF EXISTS [Usr_Site_02]
GO
