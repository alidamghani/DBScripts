# SQL Server Diagnostic Scripts & First Responder Kit

[<img src="https://www.svgrepo.com/show/303229/microsoft-sql-server-logo.svg" align="right" width="120">](https://www.microsoft.com/sql-server/)

## Overview

A comprehensive SQL Server diagnostic toolkit combining **14 custom performance and monitoring scripts** with the industry-standard **Brent Ozar First Responder Kit** (13 procedures).

This collection provides SQL Server DBAs and engineers with production-ready tools for:
- Performance troubleshooting and optimization
- Index analysis and recommendations
- Query performance identification
- Space and capacity monitoring
- Backup validation and history
- Deadlock analysis
- Health checks and diagnostics

**Contents:**
- 🔧 **14 Custom Diagnostic Scripts** - Purpose-built queries for common troubleshooting scenarios
- 🎯 **Brent Ozar First Responder Kit** - Industry-standard diagnostic procedures (13 stored procedures)
- 📊 **Query Store Analysis** - Query performance tracking and optimization
- 💾 **Backup & Recovery** - Backup history and validation scripts
- 📈 **Performance Monitoring** - Wait statistics, I/O analysis, resource consumption

---

## Table of Contents

- [Brent Ozar First Responder Kit](#brent-ozar-first-responder-kit)
  - [Installation](#installation)
  - [Included Procedures](#included-procedures)
  - [Quick Usage Examples](#quick-usage-examples)
- [Custom Diagnostic Scripts](#custom-diagnostic-scripts)
- [Quick Start Guide](#quick-start-guide)
- [Common Use Cases](#common-use-cases)
- [Prerequisites](#prerequisites)
- [Usage Examples](#usage-examples)
- [Automated Monitoring](#automated-monitoring)
- [Additional Resources](#additional-resources)
- [License & Attribution](#license--attribution)

---

## Brent Ozar First Responder Kit

### About

The **First Responder Kit** is a collection of stored procedures **directly from Brent Ozar Unlimited**, trusted by thousands of SQL Server professionals worldwide. These scripts answer critical questions about your SQL Server environment and provide actionable recommendations.

**Official Source:** https://www.BrentOzar.com/first-aid/  
**Training:** https://www.brentozar.com/product/how-i-use-the-first-responder-kit/  
**Support:** https://www.brentozar.com/support

> **Attribution:** The scripts in the `Blitz/` directory are directly from Brent Ozar Unlimited and are subject to their license terms. They are not covered by this repository's GPL-3.0 license.

---

### Installation

#### Quick Install (All Procedures)

```sql
-- Install all Blitz procedures at once
USE master;
GO

-- Run the install script
:r Blitz/Install-All-Scripts.sql
GO

-- Verify installation
SELECT name, type_desc, create_date
FROM sys.procedures
WHERE name LIKE 'sp_Blitz%'
ORDER BY name;
```

#### Individual Script Installation

If you prefer to install procedures individually:

```sql
-- Install sp_Blitz only
USE master;
GO
:r Blitz/sp_Blitz.sql
GO
```

#### Uninstallation

```sql
-- Remove all Blitz procedures
USE master;
GO
:r Blitz/Uninstall.sql
GO
```

---

### Included Procedures

| Procedure | Purpose | Key Question Answered |
|-----------|---------|----------------------|
| **sp_Blitz** | Health check | "Is my SQL Server in good shape?" |
| **sp_BlitzFirst** | Real-time performance | "Why is my SQL Server slow **right now**?" |
| **sp_BlitzCache** | Query performance | "What are the most resource-intensive queries?" |
| **sp_BlitzIndex** | Index tuning | "How can I improve my indexes?" |
| **sp_BlitzLock** | Deadlock analysis | "What queries and tables are involved in deadlocks?" |
| **sp_BlitzBackups** | Backup validation | "Are my backups running successfully?" |
| **sp_BlitzWho** | Current activity | "What's running on my server right now?" |
| **sp_BlitzAnalysis** | Historical analysis | "What performance issues occurred over time?" |
| **sp_DatabaseRestore** | Restore automation | "Quickly restore databases from backup" |
| **sp_ineachdb** | Multi-database execution | "Run a command in every database" |

**Additional Files:**
- `SqlServerVersions.sql` - SQL Server version and build reference
- `Install-All-Scripts.sql` - One-command installation
- `Uninstall.sql` - Complete removal of all procedures

---

### Quick Usage Examples

#### sp_Blitz - Comprehensive Health Check

```sql
-- Basic health check
EXEC sp_Blitz;

-- Focus on specific priority issues only
EXEC sp_Blitz @Priority = 1;  -- Critical issues only

-- Output results to a table for tracking
EXEC sp_Blitz 
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzResults';

-- Check specific database
EXEC sp_Blitz @CheckUserDatabaseObjects = 1;
```

**What It Checks:**
- Server configuration issues
- Database configuration problems
- Security concerns
- Performance issues
- Reliability risks
- Backup problems
- Index issues

---

#### sp_BlitzFirst - Real-Time Performance Analysis

```sql
-- Current performance snapshot
EXEC sp_BlitzFirst;

-- Performance since SQL Server startup
EXEC sp_BlitzFirst @SinceStartup = 1;

-- Wait 60 seconds and show deltas
EXEC sp_BlitzFirst @Seconds = 60;

-- Export results to table for trending
EXEC sp_BlitzFirst 
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzFirstResults';

-- Get file stats (I/O performance)
EXEC sp_BlitzFirst @ExpertMode = 1;
```

**What It Shows:**
- Current wait statistics
- CPU and memory pressure
- Blocking and deadlocks
- Query plan warnings
- Tempdb contention
- I/O bottlenecks

---

#### sp_BlitzCache - Query Performance Analysis

```sql
-- Top 10 queries by CPU
EXEC sp_BlitzCache @Top = 10, @SortOrder = 'CPU';

-- Top queries by reads (I/O intensive)
EXEC sp_BlitzCache @Top = 20, @SortOrder = 'reads';

-- Queries with plan warnings
EXEC sp_BlitzCache @Top = 10, @SortOrder = 'spills';

-- Queries for specific database
EXEC sp_BlitzCache 
    @DatabaseName = 'MyDatabase',
    @Top = 50,
    @SortOrder = 'duration';

-- Export results for reporting
EXEC sp_BlitzCache 
    @Top = 100,
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzCacheResults';
```

**Analysis Options:**
- CPU consumption
- Reads (logical and physical)
- Duration (elapsed time)
- Executions (frequency)
- Memory grants
- Spills to tempdb

---

#### sp_BlitzIndex - Index Tuning Recommendations

```sql
-- Analyze all databases
EXEC sp_BlitzIndex;

-- Focus on specific database
EXEC sp_BlitzIndex @DatabaseName = 'MyDatabase';

-- Get detailed recommendations (Mode 0)
EXEC sp_BlitzIndex 
    @DatabaseName = 'MyDatabase',
    @Mode = 0;  -- Detailed analysis

-- Find duplicate indexes (Mode 1)
EXEC sp_BlitzIndex 
    @DatabaseName = 'MyDatabase',
    @Mode = 1;

-- Get missing index recommendations (Mode 2)
EXEC sp_BlitzIndex 
    @DatabaseName = 'MyDatabase',
    @Mode = 2;

-- Analyze specific table
EXEC sp_BlitzIndex 
    @DatabaseName = 'MyDatabase',
    @SchemaName = 'dbo',
    @TableName = 'Orders';
```

**What It Finds:**
- Unused indexes (candidates for removal)
- Duplicate indexes
- Missing index recommendations
- Disabled indexes
- Heaps (tables without clustered indexes)
- Index fragmentation

---

#### sp_BlitzLock - Deadlock Analysis

```sql
-- Analyze recent deadlocks from system_health extended event
EXEC sp_BlitzLock;

-- Analyze deadlocks from specific time range
EXEC sp_BlitzLock 
    @StartDate = '2024-01-01',
    @EndDate = '2024-01-31';

-- Get detailed deadlock information
EXEC sp_BlitzLock @EventSessionPath = 'system_health';

-- Store results for trending
EXEC sp_BlitzLock
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzLockResults';
```

**Analysis Includes:**
- Deadlock victims and survivors
- Queries involved
- Objects involved (tables, indexes)
- Lock types
- Isolation levels
- Recommended solutions

---

#### sp_BlitzWho - Current Activity Monitoring

```sql
-- Show current activity
EXEC sp_BlitzWho;

-- Show only active sessions (not sleeping)
EXEC sp_BlitzWho @ShowSleepingSPIDs = 0;

-- Get execution plans for running queries
EXEC sp_BlitzWho @ExpertMode = 1;
```

---

#### sp_ineachdb - Execute in Multiple Databases

```sql
-- Check compatibility level in all databases
EXEC sp_ineachdb @command = 'SELECT DB_NAME() AS DatabaseName, compatibility_level FROM sys.databases WHERE database_id = DB_ID()';

-- Find all tables in all databases
EXEC sp_ineachdb @command = 'SELECT DB_NAME() AS DatabaseName, name FROM sys.tables';

-- Run query in specific databases only
EXEC sp_ineachdb 
    @command = 'UPDATE STATISTICS',
    @database_to_include = 'MyDB1,MyDB2,MyDB3';

-- Exclude system databases
EXEC sp_ineachdb 
    @command = 'DBCC CHECKDB',
    @exclude_databases = 'master,model,msdb,tempdb';
```

---

## Custom Diagnostic Scripts

In addition to the Blitz toolkit, this collection includes **14 custom diagnostic scripts** for common SQL Server troubleshooting scenarios.

### Script Reference

| Script | Description | Key Metrics | Use Case |
|--------|-------------|-------------|----------|
| **top_queries.sql** | Top 10 queries by CPU time | Avg CPU, query hash, statement text | Identify CPU-intensive queries |
| **backup_info.sql** | Backup history and details | Backup type, size, duration, LSN | Validate backup strategy |
| **missing_index.sql** | Missing index recommendations | Improvement measure, equality/inequality columns | Index optimization |
| **unused_index.sql** | Unused index identification | User seeks/scans/lookups, updates | Index cleanup |
| **average_fragmentation.sql** | Index fragmentation analysis | Fragmentation %, page count, index type | Maintenance planning |
| **QueryStore.sql** | Query Store analysis | Query performance, plan changes | Query performance tracking |
| **sql_diag.sql** | Comprehensive diagnostics | Server config, DB status, performance counters | General troubleshooting |
| **virtual_disk_io.sql** | Virtual disk I/O statistics | Reads/writes, latency, pending I/O | Storage performance |
| **wait_resources.sql** | Wait resource analysis | Wait types, waiting tasks, resources | Bottleneck identification |
| **transaction_log_operations.sql** | Transaction log monitoring | Log space used, VLF count, log backups | Log management |
| **used_space.sql** | Database space utilization | Data size, log size, free space | Capacity planning |
| **script_users.sql** | User and permission scripting | Logins, users, roles, permissions | Security audit |
| **mssql_partition.sql** | Partition information | Partition scheme, ranges, row counts | Partitioning strategy |
| **idle_session.sql** | Idle session identification | Session ID, login, idle time | Session management |
| **short_period_waitstats.sql** | Short-term wait statistics | Wait type, wait time, signal wait | Real-time bottleneck analysis |

---

### Script Details

#### top_queries.sql
**Purpose:** Identify the top 10 most CPU-intensive queries currently in the plan cache.

**Output:**
- Query hash
- Average CPU time per execution
- Sample statement text

**Use Case:** Performance troubleshooting when CPU is high.

```bash
sqlcmd -S hostname -U username -i top_queries.sql -o top_queries_output.txt
```

---

#### backup_info.sql
**Purpose:** Retrieve backup history including backup type, size, duration, and LSN information.

**Output:**
- Database name
- Physical device name
- Backup size
- Time taken
- Backup type (Full/Differential/Log)
- LSN range
- Server name
- Recovery model

**Use Case:** Validate backup completion, estimate restore time, track backup growth.

```sql
-- Optionally filter by database (uncomment WHERE clause)
-- WHERE s.database_name = 'MyDatabase'
```

---

#### missing_index.sql
**Purpose:** Display missing index recommendations from SQL Server DMVs.

**Output:**
- Database and table name
- Equality columns
- Inequality columns
- Included columns
- Improvement measure (cost benefit)
- User seeks/scans

**Use Case:** Index optimization based on query patterns.

**Important:** Evaluate recommendations carefully; not all missing indexes should be created.

---

#### unused_index.sql
**Purpose:** Identify indexes that are not being used by queries.

**Output:**
- Database and table name
- Index name and type
- User seeks/scans/lookups (should be 0 or very low)
- User updates (cost of maintaining unused index)

**Use Case:** Index cleanup to reduce storage and improve write performance.

**Caution:** Verify indexes are truly unused before dropping (check application schedules, batch jobs).

---

#### average_fragmentation.sql
**Purpose:** Analyze index fragmentation levels.

**Output:**
- Database and table name
- Index name
- Fragmentation percentage
- Page count
- Index type

**Use Case:** Maintenance planning (determine which indexes need rebuilding/reorganizing).

**Guidelines:**
- Fragmentation < 10%: No action needed
- Fragmentation 10-30%: Reorganize
- Fragmentation > 30%: Rebuild

---

#### QueryStore.sql
**Purpose:** Analyze Query Store data for query performance insights.

**Output:**
- Query performance metrics
- Plan changes and regressions
- Execution statistics

**Use Case:** Track query performance over time, identify regressions after plan changes.

**Prerequisites:** Query Store must be enabled on the database.

```sql
-- Enable Query Store
ALTER DATABASE MyDatabase SET QUERY_STORE = ON;
```

---

#### sql_diag.sql
**Purpose:** Comprehensive diagnostic information gathering.

**Output:**
- Server configuration
- Database status and properties
- Performance counters
- Error log entries
- Resource usage

**Use Case:** General troubleshooting, health checks, documentation.

---

#### virtual_disk_io.sql
**Purpose:** Analyze I/O performance at the virtual disk level.

**Output:**
- Database files
- Read/write statistics
- I/O latency
- Pending I/O operations

**Use Case:** Storage performance analysis, identify slow disks.

**Interpretation:**
- Read latency > 20ms: Potential issue
- Write latency > 10ms: Potential issue

---

#### wait_resources.sql
**Purpose:** Analyze current wait resources and blocking.

**Output:**
- Wait types
- Waiting tasks
- Wait duration
- Resources being waited on

**Use Case:** Real-time bottleneck identification.

---

#### transaction_log_operations.sql
**Purpose:** Monitor transaction log usage and operations.

**Output:**
- Log space used
- VLF count
- Log backup status
- Log growth events

**Use Case:** Log management, troubleshoot log growth issues.

---

#### used_space.sql
**Purpose:** Database and file space utilization.

**Output:**
- Database size (data + log)
- Free space
- File locations
- Growth settings

**Use Case:** Capacity planning, space monitoring.

---

#### script_users.sql
**Purpose:** Generate scripts for users, logins, roles, and permissions.

**Output:**
- CREATE LOGIN statements
- CREATE USER statements
- Role memberships
- Permissions (GRANT statements)

**Use Case:** Security audit, migrate users to another server.

---

#### mssql_partition.sql
**Purpose:** Retrieve partition information for partitioned tables.

**Output:**
- Partition scheme and function
- Partition ranges
- Row counts per partition
- Compression settings

**Use Case:** Partitioning strategy review, performance analysis.

---

#### idle_session.sql
**Purpose:** Identify idle or long-running sessions.

**Output:**
- Session ID (SPID)
- Login name
- Hostname
- Program name
- Last request start/end time
- Status

**Use Case:** Session management, identify sessions to kill.

---

#### short_period_waitstats.sql
**Purpose:** Capture wait statistics over a short period for real-time analysis.

**Output:**
- Wait type
- Wait time
- Signal wait time
- Wait count

**Use Case:** Real-time performance troubleshooting.

---

## Quick Start Guide

### Using Blitz Toolkit

1. **Install the procedures:**
```sql
USE master;
GO
:r Blitz/Install-All-Scripts.sql
GO
```

2. **Run a health check:**
```sql
EXEC sp_Blitz;
```

3. **Analyze current performance:**
```sql
EXEC sp_BlitzFirst @SinceStartup = 1;
```

4. **Find expensive queries:**
```sql
EXEC sp_BlitzCache @Top = 10, @SortOrder = 'CPU';
```

### Using Custom Scripts

**With sqlcmd:**
```bash
sqlcmd -S hostname -U username -P password -i top_queries.sql
sqlcmd -S hostname -U username -P password -i backup_info.sql -o backup_report.txt
```

**With SQL Server Management Studio (SSMS):**
1. Open the script file
2. Connect to your SQL Server instance
3. Execute (F5)

**With Azure Data Studio:**
1. Open the script file
2. Connect to your server
3. Run the script

---

## Common Use Cases

### Performance Troubleshooting

**Scenario:** "My SQL Server is slow right now!"

1. **Identify current bottlenecks:**
```sql
EXEC sp_BlitzFirst @Seconds = 30;  -- Wait 30 seconds, show deltas
```

2. **Find expensive queries:**
```sql
EXEC sp_BlitzCache @Top = 20, @SortOrder = 'CPU';
```

3. **Check for blocking:**
```sql
EXEC sp_BlitzWho;
```

4. **Analyze wait statistics:**
```sql
:r short_period_waitstats.sql
```

---

### Index Optimization

**Scenario:** "How can I improve my database performance with better indexes?"

1. **Get missing index recommendations:**
```sql
-- From Blitz
EXEC sp_BlitzIndex @DatabaseName = 'MyDatabase', @Mode = 2;

-- From custom script
:r missing_index.sql
```

2. **Find unused indexes to remove:**
```sql
-- From Blitz
EXEC sp_BlitzIndex @DatabaseName = 'MyDatabase', @Mode = 4;

-- From custom script
:r unused_index.sql
```

3. **Check for duplicate indexes:**
```sql
EXEC sp_BlitzIndex @DatabaseName = 'MyDatabase', @Mode = 1;
```

4. **Analyze fragmentation:**
```sql
:r average_fragmentation.sql
```

---

### Health Check & Audit

**Scenario:** "I just inherited this SQL Server. What shape is it in?"

1. **Run comprehensive health check:**
```sql
EXEC sp_Blitz;
```

2. **Check backup status:**
```sql
EXEC sp_BlitzBackups;
:r backup_info.sql
```

3. **Review configuration:**
```sql
EXEC sp_Blitz @CheckServerInfo = 1;
```

4. **Audit security:**
```sql
:r script_users.sql
```

---

### Capacity Planning

**Scenario:** "I need to plan for storage growth and backup windows."

1. **Check current space usage:**
```sql
:r used_space.sql
```

2. **Analyze backup history:**
```sql
:r backup_info.sql
-- Review backup sizes and durations over time
```

3. **Monitor transaction log:**
```sql
:r transaction_log_operations.sql
```

---

## Prerequisites

### SQL Server Versions

- **Minimum:** SQL Server 2012
- **Tested:** SQL Server 2012, 2014, 2016, 2017, 2019, 2022
- **Cloud:** AWS RDS SQL Server, Azure SQL Database (some limitations)

### Permissions

**Blitz Toolkit:**
- VIEW SERVER STATE
- VIEW DATABASE STATE
- VIEW ANY DEFINITION
- SELECT permissions on system views

**Custom Scripts:**
- Most scripts: VIEW SERVER STATE, VIEW DATABASE STATE
- Backup scripts: msdb read access
- Index scripts: Database-level VIEW DEFINITION

**Administrative Scripts:**
- Some Blitz recommendations require sysadmin
- Creating indexes requires ALTER permissions
- Killing sessions requires ALTER ANY CONNECTION

### Client Tools

- **sqlcmd** - Command-line utility (included with SQL Server)
- **SQL Server Management Studio (SSMS)** - Full-featured GUI
- **Azure Data Studio** - Modern, cross-platform tool

---

## Usage Examples

### Daily Health Check Script

Create a SQL Agent job or scheduled task:

```sql
USE master;
GO

-- Daily health check
EXEC sp_Blitz 
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzResults';

-- Performance baseline
EXEC sp_BlitzFirst 
    @SinceStartup = 1,
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzFirstResults';

-- Query performance tracking
EXEC sp_BlitzCache 
    @Top = 50,
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzCacheResults';
```

### Weekly Index Maintenance Check

```sql
-- Check fragmentation
:r average_fragmentation.sql

-- Get Blitz index recommendations
EXEC sp_BlitzIndex 
    @DatabaseName = 'MyDatabase',
    @Mode = 0,
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzIndexResults';

-- Review unused indexes before weekend maintenance
:r unused_index.sql
```

### Monthly Capacity Report

```bash
# Generate capacity reports
sqlcmd -S MyServer -E -i used_space.sql -o capacity_report.txt
sqlcmd -S MyServer -E -i backup_info.sql -o backup_report.txt
sqlcmd -S MyServer -E -i transaction_log_operations.sql -o log_report.txt
```

---

## Automated Monitoring

### Setting Up Automated Blitz Checks

1. **Create a DBA database to store results:**
```sql
CREATE DATABASE DBADatabase;
GO

USE DBADatabase;
GO

-- Tables will be auto-created by Blitz procedures
```

2. **Create SQL Agent jobs:**

**Job 1: Hourly Performance Check**
```sql
EXEC sp_BlitzFirst 
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzFirstResults';
```

**Job 2: Daily Health Check**
```sql
EXEC sp_Blitz 
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzResults';
```

**Job 3: Query Performance Tracking (Every 4 hours)**
```sql
EXEC sp_BlitzCache 
    @Top = 100,
    @OutputDatabaseName = 'DBADatabase',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzCacheResults';
```

3. **Query historical data:**
```sql
-- Review health check trends
SELECT CheckDate, Priority, FindingsGroup, Finding
FROM DBADatabase.dbo.BlitzResults
WHERE CheckDate >= DATEADD(day, -7, GETDATE())
ORDER BY CheckDate DESC, Priority;

-- Performance issues over time
SELECT CheckDate, Priority, Findings
FROM DBADatabase.dbo.BlitzFirstResults
WHERE CheckDate >= DATEADD(day, -1, GETDATE())
ORDER BY CheckDate DESC;
```

---

## Additional Resources

### Official Brent Ozar Resources

- **First Responder Kit Homepage:** https://www.BrentOzar.com/first-aid/
- **Complete Documentation:** https://www.brentozar.com/first-aid/
- **Training Course:** https://www.brentozar.com/product/how-i-use-the-first-responder-kit/
- **Blog & Articles:** https://www.brentozar.com/blog/
- **Support & Community:** https://www.brentozar.com/support

### Microsoft SQL Server Documentation

- **SQL Server Documentation:** https://docs.microsoft.com/en-us/sql/
- **Performance Monitoring:** https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitor-and-tune-for-performance
- **Query Store:** https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store
- **DMVs and DMFs:** https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/

### Community Resources

- **SQL Server Central:** https://www.sqlservercentral.com/
- **DBA Stack Exchange:** https://dba.stackexchange.com/questions/tagged/sql-server
- **Reddit r/sqlserver:** https://www.reddit.com/r/sqlserver/

---

## License & Attribution

### Brent Ozar First Responder Kit

The scripts in the `Blitz/` directory are **directly from Brent Ozar Unlimited**.

- **Copyright:** © Brent Ozar Unlimited
- **License:** Licensed separately under Brent Ozar Unlimited's terms
- **Official Source:** https://www.BrentOzar.com/first-aid/
- **Note:** These scripts are NOT covered by this repository's GPL-3.0 license

### Custom Diagnostic Scripts

The custom SQL scripts (outside the `Blitz/` directory) are part of this repository and are licensed under GPL-3.0.

---

**Need Help?**

- **Blitz Toolkit Support:** https://www.brentozar.com/support
- **Repository Issues:** https://github.com/alidamghani/DBScripts/issues
- **SQL Server Community:** https://dba.stackexchange.com/

---

[↩ Back to Main README](../README.md)
