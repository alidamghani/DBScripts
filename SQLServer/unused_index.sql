-- Indexes not used in past 3 months

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    CASE WHEN i.type_desc = 'CLUSTERED' THEN 'Clustered' ELSE 'Nonclustered' END AS IndexType,
    i.type_desc,
    last_used_seek = MAX(s.last_user_seek),
    last_used_scan = MAX(s.last_user_scan),
    last_used_lookup = MAX(s.last_user_lookup),
    last_write = MAX(s.last_user_update)
FROM 
    sys.indexes i
LEFT JOIN 
    sys.dm_db_index_usage_stats s ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE 
    OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
    AND (s.last_user_seek IS NULL OR DATEDIFF(MONTH, s.last_user_seek, GETDATE()) > 3)
    AND (s.last_user_lookup IS NULL OR DATEDIFF(MONTH, s.last_user_lookup, GETDATE()) > 3)
    AND (s.last_user_scan IS NULL OR DATEDIFF(MONTH, s.last_user_scan, GETDATE()) > 3)
GROUP BY 
    OBJECT_NAME(i.object_id), i.name, i.type_desc, i.index_id
ORDER BY 
    TableName, IndexType, IndexName;