CREATE DATABASE [TriggerDemo]
GO

USE [TriggerDemo]
GO
-- Create table for employees
CREATE TABLE Employees 
(EmpCode VARCHAR(8) PRIMARY KEY, Name VARCHAR(50) NOT NULL, 
Designation VARCHAR(50) NOT NULL, QualificationCode TINYINT, 
Deleted BIT NOT NULL DEFAULT 0)
GO
-- Create look up table for employees qualification
CREATE TABLE Lib_Qualification 
(QualificationCode TINYINT PRIMARY KEY, Qualification VARCHAR(20) NOT NULL)
GO
-- Add constraint to lib_qualification
ALTER TABLE dbo.Lib_Qualification ADD CONSTRAINT
FK_Lib_Qualification_Lib_Qualification FOREIGN KEY
( QualificationCode ) REFERENCES dbo.Lib_Qualification
( QualificationCode ) ON UPDATE NO ACTION 
ON DELETE NO ACTION 
GO 
-- Add constraint to employees 
ALTER TABLE dbo.EMPLOYEES ADD CONSTRAINT
FK_EMPLOYEES_Lib_Qualification FOREIGN KEY
( QualificationCode ) REFERENCES dbo.Lib_Qualification
( QualificationCode ) ON UPDATE NO ACTION 
ON DELETE NO ACTION 
GO
-- Insert data into lib_qualification table
Insert into lib_qualification VALUES (1, 'MS')
Insert into lib_qualification VALUES (2, 'MCS')
Insert into lib_qualification VALUES (3, 'BCS')
Insert into lib_qualification VALUES (4, 'MBA')
GO
-- Insert data into employees table
Insert into Employees VALUES ('405-21-1' ,'Emp1' ,'Designation1' ,1 ,0)
Insert into Employees VALUES ('527-54-7' ,'Emp2' ,'Designation2' ,2 ,0)
Insert into Employees VALUES ('685-44-2' ,'Emp3' ,'Designation3' ,1 ,0)
Insert into Employees VALUES ('044-21-3' ,'Emp4' ,'Designation4' ,3 ,0)
Insert into Employees VALUES ('142-21-9' ,'Emp5' ,'Designation5' ,2 ,0)
GO
-- Create view by two base tables
CREATE VIEW vw_EmpQualification
AS
SELECT EmpCode, Name, Designation, Qualification
FROM employees E inner join lib_qualification Q
ON E.qualificationCOde = Q.QualificationCode
WHERE deleted = 0
GO 
Select * from vw_EmpQualification
GO


drop trigger if exists INSTEADOF_TR_I_EmpQualification
go
CREATE TRIGGER INSTEADOF_TR_I_EmpQualification 
ON vw_EmpQualification
INSTEAD OF INSERT AS
BEGIN
DECLARE @Code TINYINT
SELECT @Code = qualificationCode 
FROM lib_Qualification L INNER JOIN INSERTED I
ON L.qualification = I.qualification
IF (@code is NULL )
BEGIN
RAISERROR (N'The provided qualification does not exist in qualification library',
16, 1)
RETURN
END
INSERT INTO employees (empcode, name, designation,qualificationCode,deleted) 
SELECT empcode, name, designation, @code, 0 
FROM inserted 
END
GO



-- Insert data in view
INSERT INTO vw_EmpQualification VALUES ('425-27-1', 'Emp11','Manager','MBA')
GO
-- To confirm the data insertion
SELECT * FROM vw_EmpQualification
GO

select * from dbo.Employees
select * from dbo.Lib_Qualification

-- Try and insert incorrect data , you should get the error 
INSERT INTO vw_EmpQualification VALUES ('425-27-9', 'Emp9','Manager9','MBS')
GO