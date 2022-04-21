
/*
https://www.sqlshack.com/an-introduction-to-sp_msforeachtable-run-commands-iteratively-through-all-tables-in-a-database/
*/

exec sp_MSforeachtable 
@precommand = 'CREATE TABLE ##Statistics 
		(TableName varchar(128) NOT NULL, 
		NumOfRows int,
		SpaceUsed float)'
,@command1='INSERT INTO ##Statistics (TableName, NumOfRows)
		SELECT ''?'' TableName, COUNT(1) NumOfRows FROM ?'
,@command2='UPDATE S
	SET s.SpaceUsed = g.SizeKB
	FROM ##Statistics s
	INNER JOIN (SELECT p.object_id TableID, sum(a.total_pages) * 8192 / 1024.0 SizeKB
			FROM sys.partitions p 
			INNER JOIN sys.allocation_units a on p.partition_id = a.container_id
			GROUP BY p.object_id) g
		ON OBJECT_ID(s.TableName) = g.TableID
	WHERE s.TableName = ''?'''
,@postcommand = 'SELECT TableName, NumOfRows, SpaceUsed
			FROM ##Statistics
			ORDER BY SpaceUsed DESC, NumOfRows DESC;
		DROP TABLE ##Statistics'
,@whereand='AND schema_name(schema_id) = ''dbo''' -- Filter on any additional logic (In this case we are filtering on the schema)


