SELECT db.name as [db_name],
       qsts.creation_time,
       qsts.last_execution_time, 
       qsts.execution_count, 
       qtxt.text AS [query_text],
       qpln.query_plan
FROM   sys.dm_exec_query_stats AS qsts 
       CROSS apply sys.dm_exec_sql_text(qsts.plan_handle) AS qtxt 
       CROSS apply sys.dm_exec_query_plan(qsts.plan_handle) AS qpln
	   INNER JOIN sys.databases AS db
	   ON qtxt.dbid = db.database_id
	   where qtxt.text like '%part_of_query_text%'  --uncomment line if searching for a specific query
ORDER  BY qsts.last_execution_time DESC;
