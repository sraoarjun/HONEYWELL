/*
	Constraints 
	Foriegn Keys 
	Table Types 
	Procedures 
	Full text catalogs 
	Triggers
	Tables 

*/



select
' ALTER TABLE ['+SCHEMA_NAME(fk.schema_id)+'].['+OBJECT_NAME(fk.parent_object_id)+'] DROP CONSTRAINT ['+ fk.name + ']'
FROM sys.foreign_keys fk
join sys.tables t on t.object_id = fk.referenced_object_id
where t.schema_id = schema_id('Site_04')
and fk.schema_id = t.schema_id
order by fk.name desc


SELECT
' ALTER TABLE ['+schema_name(t.schema_id)+'].['+OBJECT_NAME(fk.parent_object_id)+'] DROP CONSTRAINT ['+ fk.[Name] + ']'
FROM sys.objects fk
join sys.tables t on t.object_id = fk.parent_object_id
where t.schema_id = schema_id('Site_04')
and fk.type IN ('D', 'C', 'F')


SELECT
CASE WHEN SO.type='PK' THEN ' ALTER TABLE ['+SCHEMA_NAME(SO.schema_id)+'].['+OBJECT_NAME(SO.parent_object_id)+'] DROP CONSTRAINT ['+ SO.name + ']'
WHEN SO.type='U' THEN ' DROP TABLE ['+SCHEMA_NAME(SO.schema_id)+'].['+ SO.[Name] + ']'
WHEN SO.type='V' THEN ' DROP VIEW ['+SCHEMA_NAME(SO.schema_id)+'].['+ SO.[Name] + ']'
WHEN SO.type='P' THEN ' DROP PROCEDURE ['+SCHEMA_NAME(SO.schema_id)+'].['+ SO.[Name] + ']'
WHEN SO.type='TR' THEN ' DROP TRIGGER ['+SCHEMA_NAME(SO.schema_id)+'].['+ SO.[Name] + ']'
WHEN SO.type IN ('FN', 'TF','IF','FS','FT') THEN ' DROP FUNCTION ['+SCHEMA_NAME(SO.schema_id)+'].['+ SO.[Name] + ']'
END
FROM SYS.OBJECTS SO
WHERE SO.schema_id = schema_id('Site_04')
AND SO.type IN ('PK', 'FN', 'TF', 'TR', 'V', 'U', 'P')
ORDER BY CASE WHEN type = 'PK' THEN 1
WHEN type in ('FN', 'TF', 'P','IF','FS','FT') THEN 2
WHEN type = 'TR' THEN 3
WHEN type = 'V' THEN 4
WHEN type = 'U' THEN 5
ELSE 6
END




select  'drop type ' + quotename(schema_name(schema_id)) + '.' + quotename(name)
from sys.types where schema_id = SCHEMA_ID('Site_04')
and  is_user_defined = 1

