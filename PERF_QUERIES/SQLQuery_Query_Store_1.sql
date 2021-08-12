SELECT TOP 10 t.query_sql_text, q.query_id, 
	object_name(q.object_id) AS parent_object, 
	SUM(s.count_executions) total_executions
 FROM sys.query_store_query_text t JOIN sys.query_store_query q
   ON t.query_text_id = q.query_text_id 
   JOIN sys.query_store_plan p ON q.query_id = p.query_id 
   JOIN sys.query_store_runtime_stats s ON p.plan_id = s.plan_id
 WHERE s.count_executions > 1 -- used to make the query faster
GROUP BY  t.query_sql_text, q.query_id, object_name(q.object_id)
ORDER BY SUM(s.count_executions) DESC

go


SELECT  top 10 t.query_sql_text, q.query_id, 
	object_name(q.object_id) AS parent_object, 
	s.plan_id, s.avg_rowcount
 FROM sys.query_store_query_text t JOIN sys.query_store_query q
  ON t.query_text_id = q.query_text_id 
  JOIN sys.query_store_plan p ON q.query_id = p.query_id 
  JOIN sys.query_store_runtime_stats s ON p.plan_id = s.plan_id
WHERE s.avg_rowcount > 100
ORDER BY s.avg_rowcount DESC

GO

WITH Query_Stats 
AS 
(
 SELECT plan_id,
 SUM(count_executions) AS total_executions
 FROM sys.query_store_runtime_stats
 GROUP BY plan_id
)
SELECT TOP 10 t.query_sql_text, q.query_id, p.plan_id,
	s.total_executions/p.count_compiles avg_compiles_per_plan
  FROM sys.query_store_query_text t JOIN sys.query_store_query q
    ON t.query_text_id = q.query_text_id 
    JOIN sys.query_store_plan p ON q.query_id = p.query_id 
    JOIN Query_Stats s ON p.plan_id = s.plan_id
ORDER BY s.total_executions/p.count_compiles DESC


