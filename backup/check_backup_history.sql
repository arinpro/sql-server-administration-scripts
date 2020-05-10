SELECT @@SERVERNAME AS ServerName, 
       a.NAME       'database name', 
       'backup date & time'= CASE
                               WHEN m.backup_date IS NULL THEN '---'
                               ELSE m.backup_date 
                             END, 
       'backup type'= CASE
                        WHEN m.backup_type IS NULL THEN '---'
                        ELSE m.backup_type 
                      END, 
       'elapsed time'= CASE
                         WHEN m.elapsed_time IS NULL THEN '---'
                         ELSE CONVERT(VARCHAR(12), m.elapsed_time) 
                              + ' min.'
                       END, 
       'backup size'= CASE
                        WHEN m.backup_size IS NULL THEN '---'
                        ELSE CONVERT(VARCHAR(12), m.backup_size) 
                             + Space(1) + 'mb'
                      END, 
       'days from last backup'= CASE
                                  WHEN m.backup_date IS NULL THEN
                                  'without backup'
                                  ELSE
       CONVERT(VARCHAR(12), Datediff(d, m.backup_date, Getdate()) ) 
       + ' days'
                                END, 
       'backup device'= CASE
                          WHEN m.backup_target IS NULL THEN '---'
                          ELSE CONVERT(VARCHAR(200), m.backup_target) 
                               + Space(1) + ' '
                        END
FROM   master..sysdatabases a 
       INNER JOIN (SELECT b.database_name, 
                          b.backup_date, 
                          b.backup_type, 
                          b.elapsed_time, 
                          b.backup_size, 
                          r.physical_device_name 'backup_target'
                   FROM   msdb..backupmediafamily r 
                          INNER JOIN (SELECT
                                                            database_name, 
       CONVERT(VARCHAR(26), k.backup_start_date, 100) 
                      'backup_date'
                      , 
       'backup_type'= CASE
                        WHEN type = 'D' THEN 'FULL'
                        WHEN type = 'L' THEN 'LOG'
                        WHEN type = 'F' THEN
                        'File or Filegroup'
                        WHEN type = 'G' THEN
                        'File Differential'
                        WHEN type = 'P' THEN 'Partial'
                        WHEN type = 'Q' THEN
                        'Partial Differential'
                        WHEN type = 'I' THEN 'Differential'
                      END, 
       Datediff(n, backup_start_date, backup_finish_date) AS
                      'elapsed_time', 
       Ceiling(( backup_size / 1024 ) / 1024) 
                      'backup_size', 
       media_set_id 
                      'backup_device'
       FROM   msdb..backupset k 
       INNER JOIN (SELECT database_name         AS db, 
                          type                  AS tipo, 
                          Max(backup_start_date)AS fecha 
                   FROM   msdb..backupset 
                   GROUP  BY database_name, 
                             type) z 
               ON k.database_name = z.db 
                  AND k.backup_start_date = z.fecha 
                  AND k.type = z.tipo) b 
       ON r.media_set_id = b.backup_device) AS m 
               ON a.NAME = m.database_name 
                  AND a.NAME NOT IN ( 'tempdb', 'model', 'ReportServerTempDB', 
                                      'ReportServer', 
                                      'pubs', 'Northwind' )
