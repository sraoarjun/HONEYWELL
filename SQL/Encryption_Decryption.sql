CREATE DATABASE CustomerData;
            Go 
            USE CustomerData;
            GO
                 
            CREATE TABLE CustomerData.dbo.CustomerInfo
            (CustID        INT PRIMARY KEY, 
             CustName     VARCHAR(30) NOT NULL, 
             BankACCNumber VARCHAR(10) NOT NULL
            );
            GO

Insert into CustomerData.dbo.CustomerInfo (CustID,CustName,BankACCNumber)
            Select 1,'Rajendra',11111111 UNION ALL
            Select 2, 'Manoj',22222222 UNION ALL
            Select 3, 'Shyam',33333333 UNION ALL
            Select 4,'Akshita',44444444 UNION ALL
            Select 5, 'Kashish',55555555

	go

select * from dbo.CustomerInfo

go


USE CustomerData;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SQLShack@1';
go

SELECT name KeyName, 
    symmetric_key_id KeyID, 
    key_length KeyLength, 
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;

go


USE CustomerData;
GO
CREATE CERTIFICATE Certificate_test WITH SUBJECT = 'Protect my data';
GO


SELECT name CertName, 
    certificate_id CertID, 
    pvt_key_encryption_type_desc EncryptType, 
    issuer_name Issuer
FROM sys.certificates;
go

CREATE SYMMETRIC KEY SymKey_test WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE Certificate_test;
GO

SELECT name KeyName, 
    symmetric_key_id KeyID, 
    key_length KeyLength, 
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO

ALTER TABLE CustomerData.dbo.CustomerInfo
ADD BankACCNumber_encrypt varbinary(MAX)
GO

select * from dbo.CustomerInfo

OPEN SYMMETRIC KEY SymKey_test
        DECRYPTION BY CERTIFICATE Certificate_test;

GO

UPDATE dbo.CustomerInfo
        SET BankACCNumber_encrypt = EncryptByKey (Key_GUID('SymKey_test'), BankACCNumber)
        FROM CustomerData.dbo.CustomerInfo;
        GO
GO

select * from dbo.CustomerInfo
GO

CLOSE SYMMETRIC KEY SymKey_test;
 GO

 

ALTER TABLE CustomerData.dbo.CustomerInfo DROP COLUMN BankACCNumber;
GO


select * from dbo.CustomerInfo

GO


OPEN SYMMETRIC KEY SymKey_test
        DECRYPTION BY CERTIFICATE Certificate_test;
GO




SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
            CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
            FROM CustomerData.dbo.CustomerInfo;


USE [master]
GO
CREATE LOGIN [SQLShack] WITH PASSWORD=N'sqlshack', DEFAULT_DATABASE=[CustomerData], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [CustomerData]
GO
CREATE USER [SQLShack] FOR LOGIN [SQLShack]
GO
USE [CustomerData]
GO
ALTER ROLE [db_datareader] ADD MEMBER [SQLShack]
GO



EXECUTE AS login = 'SQLShack'
select SUSER_NAME()

OPEN SYMMETRIC KEY SymKey_test
DECRYPTION BY CERTIFICATE Certificate_test;
    
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
FROM CustomerData.dbo.CustomerInfo;

REVERT

CLOSE SYMMETRIC KEY SymKey_test;
 GO


 select SUSER_NAME()

 


 
OPEN SYMMETRIC KEY SymKey_test
DECRYPTION BY CERTIFICATE Certificate_test;
    
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
FROM CustomerData.dbo.CustomerInfo;