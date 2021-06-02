 SELECT top 25
	db.name AS [db_name],
	qsts.creation_time,
	qsts.last_execution_time,
	qsts.execution_count,
	qtxt.text AS [query_text],
	CAST(CAST(qsts.total_worker_time AS DECIMAL)/CAST(qsts.execution_count AS DECIMAL) AS INT) AS [cpu_per_execution],
	CAST(CAST(qsts.total_logical_reads AS DECIMAL)/CAST(qsts.execution_count AS DECIMAL) AS INT) AS [logical_reads_per_execution],
	CAST(CAST(qsts.total_elapsed_time AS DECIMAL)/CAST(qsts.execution_count AS DECIMAL) AS INT) AS [elapsed_time_per_execution],
	qsts.total_worker_time AS total_cpu_time,
	qsts.max_worker_time AS max_cpu_time, 
	qsts.total_elapsed_time, 
	qsts.max_elapsed_time, 
	qsts.total_logical_reads, 
	qsts.max_logical_reads,
	qsts.total_physical_reads, 
	qsts.max_physical_reads,
	qpln.query_plan,
	cpln.cacheobjtype,
	cpln.objtype,
	cpln.size_in_bytes
FROM sys.dm_exec_query_stats AS qsts 
CROSS APPLY sys.dm_exec_sql_text(qsts.plan_handle) AS qtxt
CROSS APPLY sys.dm_exec_query_plan(qsts.plan_handle) AS qpln
INNER JOIN sys.databases as db
ON qtxt.dbid = db.database_id
INNER JOIN sys.dm_exec_cached_plans AS cpln
ON cpln.plan_handle = qsts.plan_handle
--WHERE qtxt.text LIKE '%part_of_query_text%'  --uncomment line if searching for a specific query
ORDER  BY qsts.last_execution_time DESC;
