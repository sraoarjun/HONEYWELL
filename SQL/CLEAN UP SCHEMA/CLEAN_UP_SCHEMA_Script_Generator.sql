
begin try 
	begin tran

		ALTER TABLE [Site_04].[TagMappingResults] DROP CONSTRAINT [FK_TagMappingResults_TagMappingRules]-- this will succeed
		ALTER TABLE [Site_04].[ViolationReports] DROP CONSTRAINT [FK_Siteinfo_ViolationsReports] -- this will succeed

		--ALTER TABLE [Site_04].[Variables] DROP CONSTRAINT [FK_Variables_SiteInfo] -- this will fail
 
	commit tran
	Print 'All done - OK'
end try 
begin catch
	 print 'Error occured '
	 rollback tran
end catch




DECLARE @Stmt NVARCHAR(4000)
SET @Stmt='
SELECT ''DROP TABLE ''+ SS.[Name]+''.''+ SO.[Name]
FROM SYS.OBJECTS AS SO INNER JOIN SYS.SCHEMAS AS SS
ON SO.[schema_id]=SS.[schema_id]
WHERE SO.TYPE=''U'' AND SS.[Name]=''SchemaName'''
PRINT @Stmt
--EXEC (@Stmt)
GO


SELECT case when so.type = 'U' then  'DROP TABLE ' else 'DROP PROCEDURE ' end  + SS.[Name]+'.'+ SO.[Name]
FROM SYS.OBJECTS AS SO INNER JOIN SYS.SCHEMAS AS SS
ON SO.[schema_id]=SS.[schema_id]
WHERE SO.TYPE IN('U','P') AND SS.[Name]='Site_05'



---============================================================================================================================================


select  'drop type ' + quotename(schema_name(schema_id)) + '.' + quotename(name)
from sys.types where schema_id = SCHEMA_ID('Site_05')
and  is_user_defined = 1



BEGIN



declare @SQL varchar(4000)
declare @msg varchar(500)
declare @SchemaName varchar(50)= 'Site_04'
declare @WorkTest varchar(1)= 't'

IF OBJECT_ID('tempdb..#dropcode') IS NOT NULL DROP TABLE #dropcode
CREATE TABLE #dropcode
(
ID int identity(1,1)
,SQLstatement varchar(1000)
)

--removes all the foreign keys that reference a PK in the target schema
SELECT @SQL =
'select
'' ALTER TABLE [''+SCHEMA_NAME(fk.schema_id)+''].[''+OBJECT_NAME(fk.parent_object_id)+''] DROP CONSTRAINT [''+ fk.name + '']''
FROM sys.foreign_keys fk
join sys.tables t on t.object_id = fk.referenced_object_id
where t.schema_id = schema_id(''' + @SchemaName+''')
and fk.schema_id = t.schema_id
order by fk.name desc'

IF @WorkTest = 't' 
	PRINT (@SQL )
INSERT INTO #dropcode
EXEC (@SQL)

-- drop all default constraints, check constraints and Foreign Keys
SELECT @SQL =
'SELECT
'' ALTER TABLE [''+schema_name(t.schema_id)+''].[''+OBJECT_NAME(fk.parent_object_id)+''] DROP CONSTRAINT [''+ fk.[Name] + '']''
FROM sys.objects fk
join sys.tables t on t.object_id = fk.parent_object_id
where t.schema_id = schema_id(''' + @SchemaName+''')
and fk.type IN (''D'', ''C'', ''F'')'

IF @WorkTest = 't' 
	PRINT (@SQL )
INSERT INTO #dropcode
EXEC (@SQL)

--drop all other objects in order
SELECT @SQL =
'SELECT
CASE WHEN SO.type=''PK'' THEN '' ALTER TABLE [''+SCHEMA_NAME(SO.schema_id)+''].[''+OBJECT_NAME(SO.parent_object_id)+''] DROP CONSTRAINT [''+ SO.name + '']''
WHEN SO.type=''U'' THEN '' DROP TABLE [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type=''V'' THEN '' DROP VIEW [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type=''P'' THEN '' DROP PROCEDURE [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type=''TR'' THEN '' DROP TRIGGER [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type IN (''FN'', ''TF'',''IF'',''FS'',''FT'') THEN '' DROP FUNCTION [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
END
FROM SYS.OBJECTS SO
WHERE SO.schema_id = schema_id('''+ @SchemaName +''')
AND SO.type IN (''PK'', ''FN'', ''TF'', ''TR'', ''V'', ''U'', ''P'')
ORDER BY CASE WHEN type = ''PK'' THEN 1
WHEN type in (''FN'', ''TF'', ''P'',''IF'',''FS'',''FT'') THEN 2
WHEN type = ''TR'' THEN 3
WHEN type = ''V'' THEN 4
WHEN type = ''U'' THEN 5
ELSE 6
END'

IF @WorkTest = 't' 
	PRINT (@SQL )
INSERT INTO #dropcode
EXEC (@SQL)

DECLARE @ID int, @statement varchar(1000)
DECLARE statement_cursor CURSOR
FOR SELECT SQLStatement
FROM #dropcode
ORDER BY ID ASC

OPEN statement_cursor
FETCH statement_cursor INTO @statement
WHILE (@@FETCH_STATUS = 0)
BEGIN

IF @WorkTest = 't' 
	PRINT (@statement)
ELSE
BEGIN
PRINT (@statement)
EXEC(@statement)
END

FETCH statement_cursor INTO @statement
END

CLOSE statement_cursor
DEALLOCATE statement_cursor

IF @WorkTest = 't' 
	PRINT ('DROP SCHEMA ['+@SchemaName + ']')

ELSE
BEGIN
PRINT ('DROP SCHEMA ['+@SchemaName+']')
EXEC ('DROP SCHEMA ['+@SchemaName+']')
END
END



