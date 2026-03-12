-- Shows read/write operation per file per database

select db_name(database_id), file_id
,io_stall_read_ms
,num_of_reads
,cast(io_stall_read_ms/(1.0+num_of_reads) as numeric(10,1)) as 'avg_read_stall_ms'
,io_stall_write_ms
,num_of_writes
,cast(io_stall_write_ms/(1.0+num_of_writes) as numeric(10,1)) as 'avg_write_stall_ms'
,io_stall_read_ms + io_stall_write_ms as io_stalls
,num_of_reads + num_of_writes as total_io
,cast((io_stall_read_ms+io_stall_write_ms)/(1.0+num_of_reads + num_of_writes) as numeric(10,1)) as 'avg_io_stall_ms'
from sys.dm_io_virtual_file_stats(null,null)
-- from sys.dm_io_virtual_file_stats(DB_ID(),NULL)  /* Current database */
order by num_of_writes desc


-- File IO metrics in Azure SQL DB
-- for SQL Server or Azure managed instances, use sys.master_files instead


SELECT   LEFT(mf.physical_name,100),   
         ReadLatency = CASE WHEN num_of_reads = 0 THEN 0 ELSE (io_stall_read_ms / num_of_reads) END, 
         WriteLatency = CASE WHEN num_of_writes = 0 THEN 0 ELSE (io_stall_write_ms / num_of_writes) END, 
         AvgLatency =  CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
                        ELSE (io_stall / (num_of_reads + num_of_writes)) END,
         LatencyAssessment = CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 'No data' ELSE 
               CASE WHEN (io_stall / (num_of_reads + num_of_writes)) < 2 THEN 'Excellent' 
                    WHEN (io_stall / (num_of_reads + num_of_writes)) BETWEEN 2 AND 5 THEN 'Very good' 
                    WHEN (io_stall / (num_of_reads + num_of_writes)) BETWEEN 6 AND 15 THEN 'Good' 
                    WHEN (io_stall / (num_of_reads + num_of_writes)) BETWEEN 16 AND 100 THEN 'Poor' 
                    WHEN (io_stall / (num_of_reads + num_of_writes)) BETWEEN 100 AND 500 THEN  'Bad' 
                    ELSE 'Deplorable' END  END, 
         [Avg KBs/Transfer] =  CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
                    ELSE ((([num_of_bytes_read] + [num_of_bytes_written]) / (num_of_reads + num_of_writes)) / 1024) END, 
         LEFT (mf.physical_name, 2) AS Volume, 
         LEFT(DB_NAME (vfs.database_id),32) AS [Database Name]
       FROM sys.dm_io_virtual_file_stats (NULL,NULL) AS vfs  
       JOIN sys.database_files AS mf ON vfs.file_id = mf.file_id 
--       JOIN sys.master_files AS mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id 
       ORDER BY AvgLatency DESC

