
 declare @schema_name varchar(10)= 'site_04'
 declare @fulltextCatalog_Name varchar(100) = '_catalog_'+ @schema_name
 declare @sqlAgentJobName varchar(100) = '_'+@schema_name
 declare @schema_id int = (select SCHEMA_ID from sys.schemas where name = @schema_name)
 select
 (select count(1) as objects_count from sys.objects where schema_id = @schema_id)as objects_count,
 (select count(1) as tables_count from sys.tables where schema_id = @schema_id)as tables_count,
 (select count(1) as procedures_count from sys.procedures where schema_id = @schema_id)as procedures_count,
 (select count(1) as tableTypes_count from sys.table_types where schema_id = @schema_id)as tableTypes_count,
 (select count(1) as foreignKeys_count from sys.foreign_keys where schema_id = @schema_id) as foreignKeys_count,
 (
	select count(1) as triggers_count from sys.triggers where object_id in (select object_id from sys.objects where schema_id = @schema_id)
 ) as triggers_count,
 (
	SELECT 
	count(1) as fullTextCatalogs_count  FROM sys.sysfulltextcatalogs
WHERE 
	SUBSTRING([name],CHARINDEX(@fulltextCatalog_Name,[name]),DATALENGTH([name])-CHARINDEX(@fulltextCatalog_Name,[name])+1) = @fulltextCatalog_Name

 ) as fullTextCatalogs_count
 ,
 (
	SELECT 
	count(1) as sqlAgentJobs_Count  FROM msdb.dbo.sysjobs 
WHERE 
	SUBSTRING([name],CHARINDEX(@sqlAgentJobName,[name]),DATALENGTH([name])-CHARINDEX(@sqlAgentJobName,[name])+1) = @sqlAgentJobName

 ) as sqlAgentJobs_Count