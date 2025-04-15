ALTER DATABASE Regwerx 
	SET QUERY_STORE = ON;
GO
ALTER DATABASE Regwerx 
	SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
GO

ALTER DATABASE Regwerx 
	SET AUTOMATIC_TUNING (
		FORCE_LAST_GOOD_PLAN = ON
	);

ALTER DATABASE Regwerx
SET QUERY_STORE = ON ( WAIT_STATS_CAPTURE_MODE = ON );

ALTER DATABASE CURRENT
    SET QUERY_STORE = ON
    (
        OPERATION_MODE = READ_WRITE,
        CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
        DATA_FLUSH_INTERVAL_SECONDS = 900,
        MAX_STORAGE_SIZE_MB = 1000,
        INTERVAL_LENGTH_MINUTES = 60,
        SIZE_BASED_CLEANUP_MODE = AUTO,
        MAX_PLANS_PER_QUERY = 200,
        WAIT_STATS_CAPTURE_MODE = 1,
        QUERY_CAPTURE_MODE = CUSTOM,
        QUERY_CAPTURE_POLICY =
        (
            STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS,
            EXECUTION_COUNT = 30,
            TOTAL_COMPILE_CPU_TIME_MS = 1000,
            TOTAL_EXECUTION_CPU_TIME_MS = 100
        )
    );

DBCC TRACEON (7745 , -1)

SELECT actual_state_desc, desired_state_desc, current_storage_size_mb,
    max_storage_size_mb, readonly_reason, interval_length_minutes,
    stale_query_threshold_days, size_based_cleanup_mode_desc,
    query_capture_mode_desc
FROM sys.database_query_store_options;


SELECT Txt.query_text_id, Txt.query_sql_text, Pln.plan_id, Qry.*, RtSt.*
FROM sys.query_store_plan AS Pln
INNER JOIN sys.query_store_query AS Qry
    ON Pln.query_id = Qry.query_id
INNER JOIN sys.query_store_query_text AS Txt
    ON Qry.query_text_id = Txt.query_text_id
INNER JOIN sys.query_store_runtime_stats RtSt
ON Pln.plan_id = RtSt.plan_id;

SELECT * from sys.query_store_plan;

-- Top 100 queries by execution time
SELECT TOP 100
    p.query_id query_id
    , q.object_id object_id
    , ISNULL(OBJECT_NAME(q.object_id),'') object_name
    , qt.query_sql_text query_sql_text
    , ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))*0.001,2) total_duration
    , SUM(rs.count_executions) count_executions
    , COUNT(distinct p.plan_id) num_plans 
FROM sys.query_store_runtime_stats rs      
JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id      
JOIN sys.query_store_query q ON q.query_id = p.query_id      
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id  
--WHERE NOT (rs.first_execution_time > @interval_end_time OR rs.last_execution_time < @interval_start_time)  
GROUP BY p.query_id, qt.query_sql_text, q.object_id  
HAVING COUNT(distinct p.plan_id) >= 1  
ORDER BY total_duration DESC

-- Find non-parameterized queries 
SELECT count(Pl.plan_id) AS plan_count, Qry.query_hash, Txt.query_text_id, Txt.query_sql_text
FROM sys.query_store_plan AS Pl
INNER JOIN sys.query_store_query AS Qry
    ON Pl.query_id = Qry.query_id
INNER JOIN sys.query_store_query_text AS Txt
    ON Qry.query_text_id = Txt.query_text_id
GROUP BY Qry.query_hash, Txt.query_text_id, Txt.query_sql_text
ORDER BY plan_count desc;


