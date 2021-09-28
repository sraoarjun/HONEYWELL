-- Updating Statistics for all the columns in a table with Full scan

--UPDATE STATISTICS PERSON.PERSON WITH FULLSCAN, ALL -- All the columns
--UPDATE STATISTICS PERSON.PERSON WITH FULLSCAN, Columns -- Only updates the statistics for auto created column statistics  

DECLARE @tbl nvarchar(265) , @schema nvarchar(265) 
SELECT @tbl = 'person' , @schema = 'person'


SELECT sc.name as schemaName,o.name, i.index_id, i.name, i.type_desc,
       substring(ikey.cols, 3, len(ikey.cols)) AS key_cols,
       substring(inc.cols, 3, len(inc.cols)) AS included_cols,
       stats_date(o.object_id, i.index_id) AS stats_date,
       i.filter_definition
FROM   sys.objects o join sys.schemas sc on sc.schema_id = o.schema_id
JOIN   sys.indexes i ON i.object_id = o.object_id
OUTER  APPLY (SELECT ', ' + c.name +
                     CASE ic.is_descending_key
                          WHEN 1 THEN ' DESC'
                          ELSE ''
                     END
              FROM   sys.index_columns ic
              JOIN   sys.columns c ON ic.object_id = c.object_id
                                  AND ic.column_id = c.column_id
              WHERE  ic.object_id = i.object_id
                AND  ic.index_id  = i.index_id
                AND  ic.is_included_column = 0
              ORDER  BY ic.key_ordinal
              FOR XML PATH('')) AS ikey(cols)
OUTER  APPLY (SELECT ', ' + c.name
              FROM   sys.index_columns ic
              JOIN   sys.columns c ON ic.object_id = c.object_id
                                  AND ic.column_id = c.column_id
              WHERE  ic.object_id = i.object_id
                AND  ic.index_id  = i.index_id
                AND  ic.is_included_column = 1
              ORDER  BY ic.index_column_id
              FOR XML PATH('')) AS inc(cols)
WHERE  o.name = @tbl
	and 
		sc.name = @schema
ORDER  BY o.name, i.index_id

GO


DECLARE @tbl nvarchar(265) , @schema nvarchar(265) 
SELECT @tbl = 'person' , @schema = 'person'

SELECT sc.name,o.name, s.stats_id, s.name, s.auto_created, s.user_created,
       substring(scols.cols, 3, len(scols.cols)) AS stat_cols,
       stats_date(o.object_id, s.stats_id) AS stats_date,
       s.filter_definition
FROM   sys.objects o join sys.schemas sc on sc.schema_id = o.schema_id
JOIN   sys.stats s ON s.object_id = o.object_id
CROSS  APPLY (SELECT ', ' + c.name
              FROM   sys.stats_columns sc
              JOIN   sys.columns c ON sc.object_id = c.object_id
                                  AND sc.column_id = c.column_id
              WHERE  sc.object_id = s.object_id
                AND  sc.stats_id  = s.stats_id
              ORDER  BY sc.stats_column_id
              FOR XML PATH('')) AS scols(cols)
WHERE  o.name = @tbl
AND	sc.name = @schema
ORDER  BY o.name, s.stats_id


