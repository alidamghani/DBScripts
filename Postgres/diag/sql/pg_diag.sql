-- Script to run for diagnosing possible issues with PostgreSQL
-- The scripts quries catalog views for session informations
--
-- Author : Ali Damghani
-- Version: 1.0

select 'Diagnostics executed at ' || now() as "Current date";

\qecho '\n================ACTIVE SESSION USE================\n'
SELECT * FROM PG_STAT_ACTIVITY;

\qecho '\n===============LOCKS=============================\n'
SELECT * FROM pg_locks;

\qecho '\n===============BLOCKING SESSIONS==================\n'
SELECT blocked_locks.pid     AS blocked_pid,
         blocked_activity.usename  AS blocked_user,
         blocking_locks.pid     AS blocking_pid,
         blocking_activity.usename AS blocking_user,
         blocked_activity.query    AS blocked_statement,
         blocking_activity.query   AS current_statement_in_blocking_process
   FROM  pg_catalog.pg_locks         blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks         blocking_locks 
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
   WHERE NOT blocked_locks.GRANTED;


\qecho '\n================DATABASES INFO====================\n'
SELECT * FROM pg_stat_database;

\qecho '\n================USER''S INDEX STATISTICS===========\n'
SELECT * FROM pg_stat_user_indexes;

\qecho '\n================USER''S TABLE STATISTICS===========\n'
SELECT * FROM pg_stat_user_tables;


