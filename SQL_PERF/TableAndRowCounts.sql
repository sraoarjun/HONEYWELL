drop table if exists #tempA
drop table if exists #tempB
GO
select * into #tempA from 
(
SELECT
      QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS [TableName_fullyQualified]
	  ,sOBJ.Name as [TableName]
      , SUM(sPTN.Rows) AS [RowCount]
FROM 
      sys.objects AS sOBJ
      INNER JOIN sys.partitions AS sPTN
            ON sOBJ.object_id = sPTN.object_id
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
      AND index_id < 2 -- 0:Heap, 1:Clustered
GROUP BY 
      sOBJ.schema_id
      , sOBJ.name
)A
--where A.TableName like '%history%'
ORDER BY [TableName]

GO
		
select * into #tempB from 
(
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
--ORDER BY 
--    TotalSpaceMB DESC, t.Name

)A
--Where A.TableName like '%history%'
Order by A.TableName


GO



select B.SchemaName,B.TableName,B.rows ,B.TotalSpaceMB,B.UsedSpaceMB,B.UsedSpaceMB/1024.00 as UsedSpaceGB,B.UnusedSpaceMB from #tempA a  join #tempB b ON a.TableName = b.TableName
order  by b.rows desc 
--order  by B.UsedSpaceMB/1024.00 desc



select top 10  B.SchemaName,B.TableName,B.rows ,B.TotalSpaceMB,B.UsedSpaceMB,B.UsedSpaceMB/1024.00 as UsedSpaceGB,B.UnusedSpaceMB from #tempA a  join #tempB b ON a.TableName = b.TableName 
--where rows > 100000 
order by b.rows desc 
 

 exec sp_spaceused 'dbo.appl_statistics'
 select 237224 + 136904


 invent_audit and invent_aux_audit
