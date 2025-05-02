-- Script to run for diagnosing possible issues with SQL Server
-- The scripts quries DMVs for session informations
--
-- Author : Ali Damghani
-- Version: 1.0


PRINT N'Diagnostics executed at ' + convert(char, SYSDATETIME(), 120);

-- Active sessions
print N'=============== ACTIVE USER SESSIONS ==============='
SELECT session_id, login_time, host_name, program_name, client_interface_name, 
	   login_name, status, cpu_time, memory_usage, total_elapsed_time, last_request_start_time,
	   last_request_end_time, reads, writes, logical_reads, open_transaction_count
FROM sys.dm_exec_sessions 
where is_user_process = 1;

-- Idle session info
print N'=============== IDLE SESSIONS WITH OPEN TRANSACTION ==============='
SELECT s.*
FROM sys.dm_exec_sessions AS s
WHERE EXISTS (
        SELECT *
        FROM sys.dm_tran_session_transactions AS t
        WHERE t.session_id = s.session_id
    )
    AND NOT EXISTS (
        SELECT *
        FROM sys.dm_exec_requests AS r
        WHERE r.session_id = s.session_id
    );

-- Blocking session info
print N'=============== BLOCKING SESSIONS ==============='
SELECT
    t1.resource_type,
    t1.resource_database_id,
    t1.resource_associated_entity_id,
    t1.request_mode,
    t1.request_session_id as "blocked session",
	des.host_name,
	des.program_name,
	des.login_name,
    t2.blocking_session_id as "blocking session",
	desb.host_name,
	desb.program_name,
	desb.login_name
FROM sys.dm_tran_locks as t1
INNER JOIN sys.dm_os_waiting_tasks as t2
    ON t1.lock_owner_address = t2.resource_address
inner join sys.dm_exec_sessions as des
	on t1.request_session_id = des.session_id
inner join sys.dm_exec_sessions as desb
	on t2.blocking_session_id = desb.session_id
;

-- Locks waiting to be granted
print N'=============== WAITING FOR LOCK GRANT ==============='
select * from sys.dm_tran_locks where request_status <> 'GRANT';

-- Long running queries > 5 minutes
print N'=============== LONG RUNNING QUERIES ================='
SELECT 
    req.session_id
    , req.total_elapsed_time AS duration_ms
    , req.cpu_time AS cpu_time_ms
    , req.total_elapsed_time - req.cpu_time AS wait_time
    , req.logical_reads
    , SUBSTRING (REPLACE (REPLACE (SUBSTRING (ST.text, (req.statement_start_offset/2) + 1, 
       ((CASE statement_end_offset
           WHEN -1
           THEN DATALENGTH(ST.text)  
           ELSE req.statement_end_offset
         END - req.statement_start_offset)/2) + 1) , CHAR(10), ' '), CHAR(13), ' '), 
      1, 512)  AS statement_text  
FROM sys.dm_exec_requests AS req
    CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST
WHERE req.total_elapsed_time > 300000
ORDER BY total_elapsed_time DESC;

-- Database files info
print N'=============== DATABASE FILES ================='
select file_id,type_desc,name,state_desc,size,max_size ,is_read_only  from sys.database_files df ;

