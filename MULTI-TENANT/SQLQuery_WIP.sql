CREATE DATABASE SampleDB;
GO
USE SampleDB;
GO

CREATE TABLE dbo.SomeTable (SomeID int IDENTITY);

INSERT INTO dbo.SomeTable
DEFAULT VALUES;
GO

select * from dbo.SomeTable
GO


--create test user login
CREATE LOGIN [User1] WITH PASSWORD=N'p@55w0rd'
GO
--create user in test database
CREATE USER [User1] FOR LOGIN [User1] WITH DEFAULT_SCHEMA=[Dev]
GO
--create role
CREATE ROLE [DevRole] AUTHORIZATION [dbo]
GO
--create schema
CREATE SCHEMA [Dev] AUTHORIZATION [User1]
GO


GRANT ALTER ON SCHEMA::[Dev] TO [DevRole]
GO
GRANT CONTROL ON SCHEMA::[Dev] TO [DevRole]
GO
GRANT SELECT ON SCHEMA::[Dev] TO [DevRole]
GO

GRANT DELETE ON SCHEMA::[dbo] TO [DevRole]
GO
GRANT INSERT ON SCHEMA::[dbo] TO [DevRole]
GO
GRANT SELECT ON SCHEMA::[dbo] TO [DevRole]
GO
GRANT UPDATE ON SCHEMA::[dbo] TO [DevRole]
GO
GRANT REFERENCES ON SCHEMA::[dbo] TO [DevRole]
GO

--ensure role membership is correct
EXEC sp_addrolemember N'DevRole ', N'User1'
GO
--allow users to create tables in Developer_Schema
GRANT CREATE TABLE TO [DevRole]
GO
--Allow user to connect to database
GRANT CONNECT TO [User1]

GO

execute as user = 'User1'

select SUSER_NAME(),USER_NAME() 

Revert;




/*
For the table "SomeTable" to be created in the default schema of the executing user , it needs the below permissions for the user 
GRANT CREATE TABLE TO [DevRole]
GO
--Allow user to connect to database
GRANT CONNECT TO [User1]
*/

CREATE TABLE SomeTable (SomeID int IDENTITY);

INSERT INTO SomeTable
DEFAULT VALUES;
GO

