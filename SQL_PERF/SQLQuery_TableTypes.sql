select a.name , a.type , b.definition,* from sys.sysobjects a join sys.sql_modules b on a.id = b.object_id
 where a.type in ('P','V','FN')

 and definition like '%dbo.TargetList%'

 --- Determine whether a Type exists, if it exists, rename it and delete it later, otherwise it cannot be deleted directly.
IF EXISTS (SELECT 1 FROM sys.types t join sys.schemas s on t.schema_id=s.schema_id 
      and t.name='MyTableType' and s.name='dbo')
 EXEC sys.sp_rename 'dbo.MyTableType', 'obsoleting_MyTableType';
GO


--- Reconstruct TYPE, such as four fields, and now want to change it to three fields, or three fields want to add one field to four fields.
CREATE TYPE dbo.MyTableType AS TABLE(
 Id INT NOT NULL,
 Name VARCHAR(255) NOT NULL,Remark VARCHAR(255)
)
GO

--- Reconstruct all TYPE references that will be deleted, otherwise the original stored procedure will report an error
DECLARE @Name NVARCHAR(500);
DECLARE REF_CURSOR CURSOR FOR
SELECT referencing_schema_name + '.' + referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.MyTableType', 'TYPE');
 OPEN REF_CURSOR;
 FETCH NEXT FROM REF_CURSOR INTO @Name;
 WHILE (@@FETCH_STATUS = 0)
 BEGIN
  EXEC sys.sp_refreshsqlmodule @name = @Name;
  FETCH NEXT FROM REF_CURSOR INTO @Name;
 END;
CLOSE REF_CURSOR;
DEALLOCATE REF_CURSOR;
GO

--Finally delete the original renamed TableType (the one renamed in the first step)
IF EXISTS (SELECT 1 FROM sys.types t 
   join sys.schemas s on t.schema_id=s.schema_id 
   and t.name='obsoleting_MyTableType' and s.name='dbo')
 DROP TYPE dbo.obsoleting_MyTableType
GO

--- Final Enforcement of Authorization
GRANT EXECUTE ON TYPE::dbo.MyTableType TO public
GO