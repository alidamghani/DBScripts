-- Top 10 realtime queries ordered by CPU time

SELECT TOP 10
    query_stats.query_hash AS Query_Hash,
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS Avg_CPU_Time,
    MIN(query_stats.statement_text) AS Sample_Statement_Text
FROM (
    SELECT QS.*,
        SUBSTRING(ST.text, (QS.statement_start_offset / 2) + 1, (
                (
                    CASE statement_end_offset
                        WHEN - 1
                            THEN DATALENGTH(ST.text)
                        ELSE QS.statement_end_offset
                        END - QS.statement_start_offset
                    ) / 2
                ) + 1) AS statement_text
    FROM sys.dm_exec_query_stats AS QS
    CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST
    ) AS query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC;


-- find the plan for query text
SELECT * -- UseCounts, Cacheobjtype, Objtype, TEXT, query_plan
FROM sys.dm_exec_cached_plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
where text like '% id_object, versioned%'

