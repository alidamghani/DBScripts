SELECT  s.database_name
    ,m.physical_device_name
    ,CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize
    ,CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken
    ,s.backup_start_date
    ,CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn
    ,CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn
    ,CASE s.[type]
        WHEN 'D'
            THEN 'Full'
        WHEN 'I'
            THEN 'Differential'
        WHEN 'L'
            THEN 'Transaction Log'
        END AS BackupType
    ,s.server_name
    ,s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
-- WHERE s.database_name = 'msdb' and 
--	  s.type = 'D'
ORDER BY database_name, backup_start_date DESC
    ,backup_finish_date


-- For Azure
SELECT backup_file_id, 
    backup_start_date,
    backup_finish_date,
    CASE backup_type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction log'
        END AS BackupType,
    CASE in_retention
        WHEN 1 THEN 'In retention'
        WHEN 0 THEN 'Out of retention'
        END AS IsBackupAvailable
FROM sys.dm_database_backups
ORDER BY backup_start_date DESC;