
-- Create filegroups

ALTER DATABASE Regwerx
ADD FILEGROUP FG_01
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_02
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_03
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_04
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_05
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_06
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_07
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_08
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_09
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_10
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_11
GO
ALTER DATABASE Regwerx
ADD FILEGROUP FG_12
GO

-- Add files to filegroups

ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_01],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_01.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_01
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_02],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_02.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_02
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_03],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_03.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_03
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_04],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_04.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_04
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_05],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_05.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_05
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_06],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_06.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_06
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_07],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_07.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_07
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_08],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_08.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_08
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_09],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_09.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_09
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_10],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_10.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_10
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_11],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_11.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_11
GO
ALTER DATABASE Regwerx
ADD FILE
(
  NAME = [File_12],
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\File_12.ndf',
    SIZE = 8 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 64 MB
) TO FILEGROUP FG_12
GO


-- Create partition function

CREATE PARTITION FUNCTION PartitionByMonth ( datetime )  
AS RANGE RIGHT
FOR VALUES (N'2025-01-01T00:00:00.000', N'2025-02-01T00:00:00.000', N'2025-03-01T00:00:00.000', 
            N'2025-04-01T00:00:00.000', N'2025-05-01T00:00:00.000', N'2025-06-01T00:00:00.000', 
            N'2025-07-01T00:00:00.000', N'2025-08-01T00:00:00.000', N'2025-09-01T00:00:00.000', 
            N'2025-10-01T00:00:00.000', N'2025-11-01T00:00:00.000', N'2025-12-01T00:00:00.000'); 


-- Create partition scheme 

CREATE PARTITION SCHEME PS_MonthlyPartition
AS PARTITION PartitionByMonth 
TO
(
	'FG_01', 'FG_02', 'FG_03',
	'FG_04', 'FG_05', 'FG_06',
	'FG_07', 'FG_08', 'FG_09',
	'FG_10', 'FG_11', 'FG_12',
	'Primary'
);

-- Create table

CREATE TABLE audit_trail
(
  [audid] BIGINT IDENTITY(1,1) NOT NULL,
  [event_date] [datetime],
  [user_id] BIGINT,
  [event_code] VARCHAR(3),
  [event_text] VARCHAR(1000)
) ON PS_MonthlyPartition ([event_date]);
GO
CREATE CLUSTERED INDEX CI_audit_trail_AUDID ON audit_trail(audid)
GO
CREATE NONCLUSTERED INDEX IX_audit_trail_user_id ON audit_trail(user_id)
GO
GO


---- Generate the new partitions


SELECT o.name as table_name, 
  pf.name as PartitionFunction, 
  ps.name as PartitionScheme, 
  MAX(rv.value) AS LastPartitionRange
--  CASE WHEN MAX(rv.value) <= DATEADD(MONTH, 2, GETDATE()) THEN 1 else 0 END AS isRequiredMaintenance
INTO #temp
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
INNER JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id AND p.partition_number = rv.boundary_id
GROUP BY o.name, pf.name, ps.name

DECLARE @filegroup NVARCHAR(MAX) = ''
DECLARE @file NVARCHAR(MAX) = ''
DECLARE @PScheme NVARCHAR(MAX) = ''
DECLARE @PFunction NVARCHAR(MAX) = ''

SELECT
--table_name, 
--  PartitionFunction, 
--  PartitionScheme, 
--  LastPartitionRange, 
 @PScheme = @PScheme + 
 'alter partition scheme '+PartitionScheme+' next used '''+'FG_'+format(DATEADD(MONTH, 2, convert(datetime,LastPartitionRange)),'MM')+''';',
 @PFunction = @PFunction + 
'alter partition function '+PartitionFunction +'() split range ('''+cast(DATEADD(MONTH, 1, convert(datetime,LastPartitionRange)) as varchar)+''');' 
--INTO #generateScript
FROM #temp
--WHERE isRequiredMaintenance = 1


EXEC (@PScheme)
EXEC (@PFunction)

drop table #temp