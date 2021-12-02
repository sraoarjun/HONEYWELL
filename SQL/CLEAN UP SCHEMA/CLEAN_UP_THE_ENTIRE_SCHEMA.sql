BEGIN

declare @SQL varchar(4000)
declare @msg varchar(500)
declare @SchemaName varchar(50)= 'Site_04' -- Site_Name (Schema_Name) as a parameter
declare @debug_flag varchar(1)= 'n'-- Put 'Y' if you want to only print the executing statement , else any other character would actually drop the objects 
declare @full_text_catalog_name varchar(100)= '_catalog_'+@schemaName -- Look for FullTextCatalogs with the prefix "_catalog_{Schema_Name}" 


IF OBJECT_ID('tempdb..#dropObjectsCode') IS NOT NULL DROP TABLE #dropObjectsCode
CREATE TABLE #dropObjectsCode
(
ID int identity(1,1)
,SQLstatement varchar(1000)
)

--removes the foreign key constraints that reference a PK in the target schema
SELECT @SQL =
'select
'' ALTER TABLE [''+SCHEMA_NAME(fk.schema_id)+''].[''+OBJECT_NAME(fk.parent_object_id)+''] DROP CONSTRAINT [''+ fk.name + '']''
FROM sys.foreign_keys fk
join sys.tables t on t.object_id = fk.referenced_object_id
where t.schema_id = schema_id(''' + @SchemaName+''')
and fk.schema_id = t.schema_id
order by fk.name desc'

IF @debug_flag = 'y' 
	PRINT (@SQL )
INSERT INTO #dropObjectsCode
EXEC (@SQL)

-- drop the default constraints and check constraints 
SELECT @SQL =
'SELECT
'' ALTER TABLE [''+schema_name(t.schema_id)+''].[''+OBJECT_NAME(fk.parent_object_id)+''] DROP CONSTRAINT [''+ fk.[Name] + '']''
FROM sys.objects fk
join sys.tables t on t.object_id = fk.parent_object_id
where t.schema_id = schema_id(''' + @SchemaName+''')
and fk.type IN (''D'', ''C'')'

IF @debug_flag = 'y' 
	PRINT (@SQL )
INSERT INTO #dropObjectsCode
EXEC (@SQL)

--drop all the dependent objects in the correct order 
SELECT @SQL =
'SELECT
CASE WHEN SO.type=''PK'' THEN '' ALTER TABLE [''+SCHEMA_NAME(SO.schema_id)+''].[''+OBJECT_NAME(SO.parent_object_id)+''] DROP CONSTRAINT [''+ SO.name + '']''
WHEN SO.type=''U'' THEN '' DROP TABLE [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type=''V'' THEN '' DROP VIEW [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type=''P'' THEN '' DROP PROCEDURE [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type=''TR'' THEN '' DROP TRIGGER [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type IN (''FN'', ''TF'',''IF'',''FS'',''FT'') THEN '' DROP FUNCTION [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
WHEN SO.type =''TT'' THEN '' DROP TYPE [''+SCHEMA_NAME(SO.schema_id)+''].[''+ SO.[Name] + '']''
END
FROM SYS.OBJECTS SO
WHERE SO.schema_id = schema_id('''+ @SchemaName +''')
AND SO.type IN (''PK'', ''FN'', ''TF'', ''TR'', ''V'', ''U'', ''P'')
ORDER BY CASE WHEN type = ''PK'' THEN 1
WHEN type in (''FN'', ''TF'', ''P'',''IF'',''FS'',''FT'') THEN 2
WHEN type = ''TR'' THEN 3
WHEN type = ''V'' THEN 4
WHEN type = ''U'' THEN 5
WHEN type = ''TT'' THEN 6
ELSE 7
END'

IF @debug_flag = 'y' 
	PRINT (@SQL )
INSERT INTO #dropObjectsCode
EXEC (@SQL)

--- Table Types 
INSERT INTO #dropObjectsCode
select  'drop type ' + quotename(schema_name(schema_id)) + '.' + quotename(name)
from sys.types where schema_id = SCHEMA_ID(''+ @SchemaName +'')
and  is_user_defined = 1


-- FullText Catalogs 
INSERT INTO #dropObjectsCode
SELECT 
	'drop fulltext catalog [' + [name] + ']' FROM sys.sysfulltextcatalogs
WHERE 
	SUBSTRING([name],CHARINDEX(@full_text_catalog_name,[name]),DATALENGTH([name])-CHARINDEX(@full_text_catalog_name,[name])+1) = @full_text_catalog_name
	

--- Delete duplicates if any 
;WITH CTE AS
(
SELECT *,ROW_NUMBER() OVER (PARTITION BY SQLstatement ORDER BY ID) AS RN
FROM #dropObjectsCode
)

DELETE FROM CTE WHERE RN<>1


DECLARE @ID int, @statement varchar(1000)
DECLARE statement_cursor CURSOR
FOR SELECT SQLStatement
FROM #dropObjectsCode
ORDER BY ID ASC

OPEN statement_cursor
FETCH statement_cursor INTO @statement
WHILE (@@FETCH_STATUS = 0)
BEGIN

IF @debug_flag = 'y' 
	PRINT (@statement)
ELSE
BEGIN
	EXEC(@statement)
END

FETCH statement_cursor INTO @statement
END

CLOSE statement_cursor
DEALLOCATE statement_cursor

IF @debug_flag = 'y' 
	PRINT ('DROP SCHEMA ['+@SchemaName + ']')

ELSE
BEGIN
	EXEC ('DROP SCHEMA ['+@SchemaName+']')
END
END

