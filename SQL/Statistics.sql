SELECT sp.stats_id, 
       name, 
       filter_definition, 
       last_updated, 
       rows, 
       rows_sampled, 
       steps, 
       unfiltered_rows, 
       modification_counter
FROM sys.stats AS stat
     CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE 
	--stat.object_id = OBJECT_ID('dbo.Author')
--and 
name like '_WA%';

GO


SELECT stat.name AS 'Statistics',
 OBJECT_NAME(stat.object_id) AS 'Object',
 COL_NAME(scol.object_id, scol.column_id) AS 'Column'
FROM sys.stats AS stat (NOLOCK) Join sys.stats_columns AS scol (NOLOCK)
 ON stat.stats_id = scol.stats_id AND stat.object_id = scol.object_id
 INNER JOIN sys.tables AS tab (NOLOCK) on tab.object_id = stat.object_id
WHERE stat.name like '_WA%'
ORDER BY stat.name
GO


SELECT stat.name AS 'Statistics',
 OBJECT_NAME(stat.object_id) AS 'Object',
 COL_NAME(scol.object_id, scol.column_id) AS 'Column'
FROM sys.stats AS stat (NOLOCK) Join sys.stats_columns AS scol (NOLOCK)
 ON stat.stats_id = scol.stats_id AND stat.object_id = scol.object_id
 INNER JOIN sys.tables AS tab (NOLOCK) on tab.object_id = stat.object_id
WHERE stat.name = '_WA_Sys_00000002_6FB49575'
ORDER BY stat.name

GO


SELECT sp.stats_id, 
       name, 
       filter_definition, 
       last_updated, 
       rows, 
       rows_sampled, 
       steps, 
       unfiltered_rows, 
       modification_counter
FROM sys.stats AS stat
     CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE 
	--stat.object_id = OBJECT_ID('dbo.Author')
--and 
name like '_WA_Sys_00000002_6FB49575%';

GO

select TerritoryID, *  from [Sales].[SalesPerson]  


DBCC SHOW_STATISTICS('Sales.SalesPerson', '_WA_Sys_00000002_6FB49575')


select TerritoryID , count(1) as cnt  from Sales.SalesPerson group by TerritoryID order by cnt desc 



select count(1) as cnt from [Person].[Person]
select * from [Person].[Person]

GO

SELECT  LastName ,
        modifieddate
FROM    [Person].[Person]
WHERE   LastName BETWEEN 'Abbas' AND 'Ashe'
GO


SELECT  LastName ,
        modifieddate
FROM    [Person].[Person]
WHERE   LastName BETWEEN 'Abbas' AND 'Bailey'
GO



select LastName, count(1) as cnt from [Person].[Person] where LastName IN ('Ashe','Abbas','Bailey') group by LastName order by LastName 