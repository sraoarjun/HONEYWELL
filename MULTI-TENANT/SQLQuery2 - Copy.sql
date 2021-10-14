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


-- Create a common shared schema that will contain all the common and shared tables like configuration data etc
CREATE SCHEMA [sch_cmn]
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
Where s.name like 'site_%' or s.name like '%sch_cmn%'
ORDER BY 
    s.name;
GO


-- Create a common configuration data to hold the Site specific user information 

CREATE TABLE [sch_cmn].[tblConfiguration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](100) NULL,
	[SchemaName] [varchar](100) NULL,
	[DatbaseName] [varchar](100) NULL,
	[UserName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Insert sample configuration data 
INSERT INTO [sch_cmn].[tblConfiguration]
	SELECT null,'Site_01','MultiTenantDB','Usr_site_01'
	UNION ALL 
	SELECT null,'Site_02','MultiTenantDB','Usr_site_02'
GO

-- Check to verify the sample configuration data 
SELECT * FROM [sch_cmn].[tblConfiguration]
GO

-- Populate some data for the user 
drop table if exists Site_01.Equipments 
create table Site_01.Equipments (id int primary key identity(1,1) , F_Name varchar(100))

declare @prefix varchar(100) = 'Site_01'
insert into Site_01.Equipments 
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



drop table if exists Site_02.Equipments 
create table Site_02.Equipments (id int primary key identity(1,1) , F_Name varchar(100))

declare @prefix varchar(100) = 'Site_02'
insert into Site_02.Equipments 
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
select * from Site_01.Equipments
select * from Site_02.Equipments


CREATE PROCEDURE Site_01.sp_select_Equipments
AS
SET NOCOUNT ON
BEGIN
	
	SELECT * FROM Equipments
END 
GO

CREATE PROCEDURE Site_02.sp_select_Equipments
AS
SET NOCOUNT ON
BEGIN
	
	SELECT * FROM Equipments

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


select * from Site_01.Equipments
select * from Site_02.Equipments


GO


DROP PROCEDURE IF EXISTS sch_cmn.sp_select_Configuration
GO
/*
	exec sch_cmn.sp_select_Configuration 
*/
CREATE PROCEDURE sch_cmn.sp_select_Configuration 
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT * FROM sch_cmn.tblConfiguration;
END 
GO




DROP PROCEDURE IF EXISTS Site_01.sp_select_Equipments
GO
DROP PROCEDURE IF EXISTS Site_02.sp_select_Equipments
GO

/*
	exec Site_01.sp_select_employees 'Usr_Site_01'
*/
CREATE PROCEDURE Site_01.sp_select_Equipments (@user_name varchar(100))
AS
BEGIN
	
	EXECUTE AS USER = @user_name;  

	SELECT * FROM Equipments;

	REVERT 
END 
GO

/*
	exec Site_02.sp_select_employees 'Usr_Site_02'
*/


CREATE PROCEDURE Site_02.sp_select_Equipments (@user_name varchar(100))
AS
BEGIN
	
	EXECUTE AS USER = @user_name;  

	SELECT * FROM Equipments;

	REVERT 
END 
GO



exec Site_01.sp_select_Equipments 'usr_Site_01'-- Needs to be called from the User for Site 1 only (Will fail for all other Users except dbo users)
exec Site_02.sp_select_Equipments 'usr_Site_02' -- Needs to be called from the User for Site 2 only (Will fail for all other Users except dbo users)




---- Grant Access to Common Schema for the users
GRANT EXECUTE ,SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_01
GRANT EXECUTE ,SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_02

---- Deny Access to Common Schema for the users
DENY EXECUTE,SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_01
DENY EXECUTE,SELECT, INSERT, UPDATE, DELETE ON SCHEMA::sch_cmn TO Usr_Site_02


exec sch_cmn.sp_select_Configuration 

EXECUTE AS USER = 'USR_Site_01'

EXECUTE AS USER = 'USR_Site_02'

select SUSER_NAME () , USER_NAME()

REVERT 