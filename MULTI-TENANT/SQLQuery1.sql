CREATE DATABASE [MultiTenantDB]
GO

USE [MultiTenantDB]
GO
/*
1.Create a new schema for the tenant – Site_01
2.Create a new database user T001 with access to the above schema and common schema. The default schema for the user user_Site_01 is set to this schema - Site_01.
3.Create tenant specific tables under the schema user_Site_01
4.Add Configuration details for the tenant in the Common configuration table. This would also include the connection string that will be used by the application to connect to the database.
5.Deny access to T001 on all other tenant schemas in the database.
When a user for this tenant accesses the application, the configuration details are used to connect to the database. Stored procedures will have queries like:

SELECT EmployeeId, EmployeeName FROM tblEmpDtl
 As the tenant user_Site_01 has default schema set to Site_01, the above query will retrieve details from tblVehicle table in Site_01 and not from any other schema. Also as user_Site_01 is denied access on other tenant schemas, this user will not be able to access data from other tenants. For retrieving data from tables in common schema, table names should be prefixed with schema name Schema_Common.tblTenantConfig.

*/