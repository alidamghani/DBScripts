-- Find the numver of virtual log files

SELECT name AS 'Database Name', total_vlf_count AS 'VLF count'
FROM sys.databases AS s
CROSS APPLY sys.dm_db_log_stats(s.database_id)
WHERE name = 'nexus-test';


-- Find the last transaction log backup time
SELECT name AS 'Database Name', log_backup_time AS 'last log backup time'
FROM sys.databases AS s CROSS APPLY sys.dm_db_log_stats(s.database_id)
WHERE name = 'nexus-test';