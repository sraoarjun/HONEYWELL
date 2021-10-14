-- Create the user "Usr_Site_01"
DECLARE @schema_name VARCHAR(100) = 'Usr_Site_01'
IF NOT EXISTS (SELECT 1 FROM SYS.SYSUSERS WHERE NAME = @schema_name)
BEGIN
	CREATE USER Usr_Site_01 WITHOUT LOGIN
END 
GO

-- Create the user "Usr_Site_02"
DECLARE @schema_name VARCHAR(100) = 'Usr_Site_02'
IF NOT EXISTS (SELECT 1 FROM SYS.SYSUSERS WHERE NAME = @schema_name)
BEGIN
	CREATE USER Usr_Site_02 WITHOUT LOGIN
END 
GO


-- Create the schema with the name for the user and associate it with the user 

CREATE SCHEMA [Site_01] AUTHORIZATION [Usr_Site_01]
GO

CREATE SCHEMA [Site_02] AUTHORIZATION [Usr_Site_02]
GO


-- Check the schema owner
SELECT 
    s.name AS schema_name, 
    u.name AS schema_owner
FROM 
    sys.schemas s
INNER JOIN sys.sysusers u ON u.uid = s.principal_id
Where s.name like 'site_%'
ORDER BY 
    s.name;
GO


-- Populate some data for the user 
drop table if exists Site_01.employees 
create table Site_01.employees (id int primary key identity(1,1) , F_Name varchar(100))

declare @prefix varchar(100) = 'Site_01'
insert into Site_01.employees 
select  @prefix+'_'+'Reliance_1_1'
union all
select  @prefix+'_'+'Reliance_1_2'
union all
select  @prefix+'_'+'Reliance_1_3'
union all
select  @prefix+'_'+'Reliance_1_4'
union all
select  @prefix+'_'+'Reliance_1_5'

GO



drop table if exists Site_02.employees 
create table Site_02.employees (id int primary key identity(1,1) , F_Name varchar(100))

declare @prefix varchar(100) = 'Site_02'
insert into Site_02.employees 
select  @prefix+'_'+'Reliance_2_1'
union all					 
select  @prefix+'_'+'Reliance_2_1'
union all					  
select  @prefix+'_'+'Reliance_2_1'
union all					  
select  @prefix+'_'+'Reliance_2_1'
union all					 
select  @prefix+'_'+'Reliance_2_1'
GO

-- Verify the data being populated
select * from Site_01.employees
select * from Site_02.employees


CREATE PROCEDURE Site_01.sp_select_employees
AS
SET NOCOUNT ON
BEGIN
	
	SELECT * FROM employees
END 
GO

CREATE PROCEDURE Site_02.sp_select_employees
AS
SET NOCOUNT ON
BEGIN
	
	SELECT * FROM employees

END 
GO


SELECT SUSER_NAME(), USER_NAME() as  Current_User_Name;

EXECUTE AS USER = 'Usr_Site_01';  
SELECT SUSER_NAME(), USER_NAME() as  Current_User_Name;  
REVERT;  

EXECUTE AS USER = 'Usr_Site_02';  
SELECT SUSER_NAME(), USER_NAME() as Current_User_Name;  
REVERT;  


SELECT SUSER_NAME(), USER_NAME() as  Current_User_Name;   
GO


select * from Site_01.employees
select * from Site_02.employees

exec Site_01.sp_select_employees 'usr_Site_01'-- Needs to be called from the User for Site 1 only (Will fail for all other Users except dbo users)
exec Site_02.sp_select_employees 'usr_Site_02' -- Needs to be called from the User for Site 2 only (Will fail for all other Users except dbo users)



GO




DROP PROCEDURE IF EXISTS Site_01.sp_select_employees
GO
DROP PROCEDURE IF EXISTS Site_02.sp_select_employees
GO

/*
	exec Site_01.sp_select_employees 'Usr_Site_01'
*/
CREATE PROCEDURE Site_01.sp_select_employees (@user_name varchar(100))
AS
BEGIN
	
	EXECUTE AS USER = @user_name;  

	SELECT * FROM employees;

	REVERT 
END 
GO

/*
	exec Site_02.sp_select_employees 'Usr_Site_02'
*/


CREATE PROCEDURE Site_02.sp_select_employees (@user_name varchar(100))
AS
BEGIN
	
	EXECUTE AS USER = @user_name;  

	SELECT * FROM employees;

	REVERT 
END 
GO



---- Grant Access to Common Schema for the users
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_01
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_02

---- Deny Access to Common Schema for the users
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_01
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_02
