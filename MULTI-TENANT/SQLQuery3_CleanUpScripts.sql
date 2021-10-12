-- Drop the Procedures
DROP PROCEDURE IF EXISTS Site_01.sp_select_employees
GO
DROP PROCEDURE IF EXISTS Site_02.sp_select_employees
GO

--Drop the tables 
Drop table if exists Site_01.employees 
GO
Drop table if exists Site_02.employees 
GO

--Drop the Schemas
DROP SCHEMA IF EXISTS [Site_01]
GO
DROP SCHEMA IF EXISTS  [Site_02]
GO

--- Drop the Users
DROP USER IF EXISTS [Usr_Site_01]
GO
DROP USER IF EXISTS [Usr_Site_02]
GO
