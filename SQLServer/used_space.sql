-- Determining the Amount of Space Used  / free
SELECT 
	 [Source] = 'database_files'
	,[DB_max_size_MB] = SUM(max_size) * 8 / 1027.0
	,[DB_current_size_MB] = SUM(size) * 8 / 1027.0
	,[FileCount] = COUNT(FILE_ID)
FROM sys.database_files
WHERE type = 0 --ROWS

SELECT 
	 [Source] = 'dm_db_file_space_usage'
	,[free_space_MB] = SUM(U.unallocated_extent_page_count) * 8 / 1024.0
	,[used_space_MB] = SUM(U.internal_object_reserved_page_count + U.user_object_reserved_page_count + U.version_store_reserved_page_count) * 8 / 1024.0
    ,[internal_object_space_MB] = SUM(U.internal_object_reserved_page_count) * 8 / 1024.0
    ,[user_object_space_MB] = SUM(U.user_object_reserved_page_count) * 8 / 1024.0
    ,[version_store_space_MB] = SUM(U.version_store_reserved_page_count) * 8 / 1024.0
FROM tempdb.sys.dm_db_file_space_usage U

-- Obtaining the space consumed currently in each session
SELECT 
	 [Source] = 'dm_db_session_space_usage'
	,[session_id] = Su.session_id
	,[login_name] = MAX(S.login_name)
	,[database_id] = MAX(S.database_id)
	,[database_name] = MAX(D.name)
	,[elastic_pool_name] = MAX(DSO.elastic_pool_name)
	,[internal_objects_alloc_page_count_MB] = SUM(internal_objects_alloc_page_count) * 8 / 1024.0
	,[user_objects_alloc_page_count_MB] = SUM(user_objects_alloc_page_count) * 8 / 1024.0
FROM tempdb.sys.dm_db_session_space_usage SU
LEFT JOIN sys.dm_exec_sessions S
        ON SU.session_id = S.session_id
LEFT JOIN sys.database_service_objectives DSO
        ON S.database_id = DSO.database_id
LEFT JOIN sys.databases D
	ON S.database_id = D.database_id
WHERE internal_objects_alloc_page_count + user_objects_alloc_page_count > 0
GROUP BY Su.session_id
ORDER BY [user_objects_alloc_page_count_MB] desc, Su.session_id;


-- Obtaining the space consumed in all currently running tasks in each session
SELECT 
	 [Source] = 'dm_db_task_space_usage'
	,[session_id] = SU.session_id
	,[login_name] = MAX(S.login_name)
	,[database_id] = MAX(S.database_id)
	,[database_name] = MAX(D.name)
	,[elastic_pool_name] = MAX(DSO.elastic_pool_name)
	,[internal_objects_alloc_page_count_MB] = SUM(SU.internal_objects_alloc_page_count) * 8 / 1024.0
	,[user_objects_alloc_page_count_MB] = SUM(SU.user_objects_alloc_page_count) * 8 / 1024.0
FROM tempdb.sys.dm_db_task_space_usage SU
LEFT JOIN sys.dm_exec_sessions S
        ON SU.session_id = S.session_id
LEFT JOIN sys.database_service_objectives DSO
        ON S.database_id = DSO.database_id
LEFT JOIN sys.databases D
	ON S.database_id = D.database_id
WHERE internal_objects_alloc_page_count + user_objects_alloc_page_count > 0
GROUP BY SU.session_id
ORDER BY [user_objects_alloc_page_count_MB] desc, session_id;

-- Obtaining the size of tables and their indexes

with cte as (  
  SELECT  
  t.name as TableName,  
  SUM (s.used_page_count) as used_pages_count,  
  SUM (CASE  
              WHEN (i.index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)  
              ELSE lob_used_page_count + row_overflow_used_page_count  
          END) as pages  
  FROM sys.dm_db_partition_stats  AS s   
  JOIN sys.tables AS t ON s.object_id = t.object_id  
  JOIN sys.indexes AS i ON i.[object_id] = t.[object_id] AND s.index_id = i.index_id  
  GROUP BY t.name  
  )  
  ,cte2 as(select  
      cte.TableName,   
      (cte.pages * 8.) as TableSizeInKB,   
      ((CASE WHEN cte.used_pages_count > cte.pages   
                  THEN cte.used_pages_count - cte.pages  
                  ELSE 0   
            END) * 8.) as IndexSizeInKB  
  from cte  
 )  
 select TableName,TableSizeInKB,IndexSizeInKB,  
 case when (TableSizeInKB+IndexSizeInKB)>1024*1024   
 then cast((TableSizeInKB+IndexSizeInKB)/1024*1024 as varchar)+'GB'  
 when (TableSizeInKB+IndexSizeInKB)>1024   
 then cast((TableSizeInKB+IndexSizeInKB)/1024 as varchar)+'MB'  
 else cast((TableSizeInKB+IndexSizeInKB) as varchar)+'KB' end [TableSizeIn+IndexSizeIn]  
 from cte2  
 order by 2 desc
 
-- 
select db_name(database_id), df.file_id,  name, type_desc, total_page_count, allocated_extent_page_count, differential_base_time, modified_extent_page_count
from sys.dm_db_file_space_usage dfsu inner join sys.database_files df
on dfsu.file_id = df.file_id;