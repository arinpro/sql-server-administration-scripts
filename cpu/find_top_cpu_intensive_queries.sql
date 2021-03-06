SELECT TOP 10 
   s.session_id,
   r.status,
   r.blocking_session_id,
   r.wait_type,
   wait_resource,
   r.wait_time / ( 1000 * 60 ) 'wait_time(Min)',
   r.cpu_time,
   r.logical_reads,
   r.reads,
   r.writes,
   r.total_elapsed_time / ( 1000 * 60 ) 'total_elapsed_time(Min)',
   Substring(st.text, 
   (
      r.statement_start_offset / 2 
   )
   + 1, 
   (
( 
      CASE
         r.statement_end_offset 
         WHEN
            - 1 
         THEN
            Datalength(st.text) 
         ELSE
            r.statement_end_offset 
      END
      - r.statement_start_offset ) / 2 
   )
   + 1) AS statement_text, COALESCE(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text, r.command, qp.query_plan, s.login_name, s.host_name, s.program_name, s.last_request_end_time, s.login_time, r.open_transaction_count 
FROM
   sys.dm_exec_sessions AS s 
   JOIN
      sys.dm_exec_requests AS r 
      ON r.session_id = s.session_id CROSS apply sys.Dm_exec_sql_text(r.sql_handle) AS st CROSS apply sys.Dm_exec_query_plan(r.plan_handle) AS qp 
WHERE
   r.session_id != @@SPID 
ORDER BY
   r.cpu_time DESC
