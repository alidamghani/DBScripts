# PostgreSQL Diagnostic Scripts & AWS RDS Integration

[<img src="img/pg_logo.svg" align="right" width="120">](https://www.postgresql.org/)

## Overview

A PostgreSQL diagnostic toolkit with **24 specialized SQL scripts**, **historical statistics tracking**, and **AWS RDS integration utilities** for performance monitoring, troubleshooting, and capacity planning.

This collection provides PostgreSQL DBAs and engineers with practical tools for:
- Bloat detection and vacuum monitoring
- Replication monitoring and troubleshooting
- Buffer cache analysis and optimization
- Session and lock management
- Index optimization (unused, duplicated, low HOT updates)
- Historical statistics tracking via Stats Snapshot System
- AWS RDS integration for automated instance discovery

**Contents:**
- 🔍 **24 SQL Diagnostic Scripts** - Purpose-built queries for common PostgreSQL troubleshooting scenarios
- 📊 **Stats Snapshot System** - Historical tracking of pg_stat tables for trend analysis
- 🛠️ **Shell Scripts & CLI Utilities** - AWS RDS integration and automation tools
- ☁️ **AWS RDS Optimized** - Native support for RDS PostgreSQL and Aurora PostgreSQL
- 💾 **Buffer Cache Analysis** - Specialized scripts for shared buffers optimization
- 🔁 **Replication Monitoring** - replication health and lag tracking

---

## Table of Contents

- [SQL Diagnostic Scripts](#sql-diagnostic-scripts)
  - [Bloat & Vacuum Monitoring](#bloat--vacuum-monitoring)
  - [Session & Lock Management](#session--lock-management)
  - [Index Optimization](#index-optimization)
  - [Replication Monitoring](#replication-monitoring)
  - [Buffer Cache Analysis](#buffer-cache-analysis)
  - [Schema & Database Management](#schema--database-management)
- [Stats Snapshot System](#stats-snapshot-system)
- [Shell Scripts & CLI Utilities](#shell-scripts--cli-utilities)
- [Quick Start Guide](#quick-start-guide)
- [Common Use Cases](#common-use-cases)
- [Prerequisites](#prerequisites)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Additional Resources](#additional-resources)
- [License](#license)

---

## SQL Diagnostic Scripts

### Bloat & Vacuum Monitoring

#### list-tables-bloated.sql
**Purpose:** Identify tables with significant bloat (wasted space).

**Output:**
- Schema and table name
- Actual size vs expected size
- Bloat percentage
- Wasted space (MB)

**Use Case:** Identify tables requiring VACUUM FULL or pg_repack to reclaim space.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-tables-bloated.sql
```

**Interpretation:**
- Bloat < 20%: Normal
- Bloat 20-40%: Consider vacuum
- Bloat > 40%: Action required


---

#### list-btree-bloat.sql
**Purpose:** Identify B-tree indexes with significant bloat.

**Output:**
- Schema, table, and index name
- Index size
- Estimated bloat (MB)
- Bloat percentage

**Use Case:** Identify indexes requiring REINDEX to improve performance and reclaim space.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-btree-bloat.sql
```

**Recommendation:** REINDEX bloated indexes during maintenance windows.


---

#### list-tables-with-dead-tuples.sql
**Purpose:** List tables with dead tuples requiring vacuum.

**Output:**
- Schema and table name
- Live tuples
- Dead tuples
- Dead tuple percentage
- Last autovacuum time

**Use Case:** Identify tables with excessive dead tuples, troubleshoot autovacuum issues.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-tables-with-dead-tuples.sql
```

**Warning:** High dead tuple percentage indicates autovacuum not keeping up or insufficient vacuum configuration.


---

#### list-tables-age.sql
**Purpose:** Display table ages (transaction wraparound monitoring).

**Output:**
- Schema and table name
- Age (in transactions)
- Freeze age
- Last vacuum
- Last autovacuum

**Use Case:** Monitor transaction wraparound risk, ensure vacuum freeze operations are occurring.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-tables-age.sql
```

**Critical:** Age approaching 2 billion requires immediate attention to prevent wraparound shutdown.


---

#### list-vacuum-freeze-hold-back-potential-reasons.sql
**Purpose:** Identify reasons why vacuum freeze may be held back.

**Output:**
- Potential blockers (long-running transactions, replication slots, prepared transactions)
- Transaction IDs
- Duration

**Use Case:** Troubleshoot vacuum freeze issues preventing age reduction.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-vacuum-freeze-hold-back-potential-reasons.sql
```


---

#### top30-tables-with-low-hotupdates.sql
**Purpose:** Identify tables with low HOT (Heap-Only Tuple) update ratio.

**Output:**
- Schema and table name
- Total updates
- HOT updates
- HOT update percentage

**Use Case:** Identify tables that would benefit from increased fillfactor or additional indexes.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/top30-tables-with-low-hotupdates.sql
```

**Recommendation:** Low HOT update ratio (< 80%) may indicate need to adjust fillfactor or remove unnecessary indexes.


---

### Session & Lock Management

#### list-sessions.sql
**Purpose:** Display all active sessions from pg_stat_activity.

**Output:**
- PID
- Username
- Database
- Application name
- Client address
- State
- Current query
- Query start time

**Use Case:** Monitor active connections, identify long-running queries.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-sessions.sql
```


---

#### list-sessions-blocking-others.sql
**Purpose:** Identify sessions that are blocking other sessions.

**Output:**
- Blocking PID
- Blocked PID
- Blocking query
- Blocked query
- Lock type
- Wait duration

**Use Case:** Troubleshoot application slowdowns caused by blocking sessions.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-sessions-blocking-others.sql
```

**Action:** Review blocking queries, consider terminating if appropriate.


---

#### list-lock-dependency-info.sql
**Purpose:** Display detailed lock dependency information.

**Output:**
- Lock type
- Relation
- PID
- Granted status
- Query text

**Use Case:** Deep-dive lock analysis for complex blocking scenarios.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-lock-dependency-info.sql
```


---

### Index Optimization

#### list-unused-indexes.sql
**Purpose:** Identify indexes that are not being used by queries.

**Output:**
- Schema and table name
- Index name
- Index size
- Index scans (should be 0 or very low)

**Use Case:** Index cleanup to reduce storage and improve write performance.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-unused-indexes.sql
```

**Caution:** Verify indexes are truly unused before dropping (check application schedules, batch jobs).


---

#### list-duplicated-indexes.sql
**Purpose:** Identify duplicate or redundant indexes.

**Output:**
- Schema and table name
- Index names (duplicates)
- Index definitions
- Size

**Use Case:** Remove duplicate indexes to save storage and improve write performance.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-duplicated-indexes.sql
```


---

### Replication Monitoring

#### repl-slots.sql
**Purpose:** Monitor replication slot status and lag.

**Output:**
- Slot name
- Slot type (physical/logical)
- Active status
- WAL lag
- Database

**Use Case:** Monitor replication health, identify lagging replicas.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/repl-slots.sql
```

**Warning:** Inactive replication slots can cause WAL accumulation and disk space issues.


---

#### repl-session.sql
**Purpose:** Display active replication sessions from pg_stat_replication.

**Output:**
- Application name
- Client address
- State
- Sync state
- Sent/write/flush/replay LSN
- Lag (bytes and time)

**Use Case:** Monitor replication lag and streaming status.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/repl-session.sql
```


---

#### repl-wal-receiver.sql
**Purpose:** Display WAL receiver status on replica.

**Output:**
- Status
- Receive start LSN
- Received LSN
- Last receive time
- Sender host

**Use Case:** Monitor WAL receiver health on standby servers.

**Example:**
```bash
# Run on standby/replica
psql -h replica-hostname -U username -d database -f diag/sql/repl-wal-receiver.sql
```


---

#### repl-database-conflicts.sql
**Purpose:** Display replication conflicts on standby databases.

**Output:**
- Database name
- Conflict types (deadlock, snapshot, lock, etc.)
- Conflict counts

**Use Case:** Troubleshoot replication conflicts on hot standby servers.

**Example:**
```bash
# Run on standby/replica
psql -h replica-hostname -U username -d database -f diag/sql/repl-database-conflicts.sql
```


---

#### repl-xmin-from-activity.sql
**Purpose:** Identify sessions holding back xmin (preventing vacuum).

**Output:**
- PID
- Username
- State
- xmin horizon
- Query

**Use Case:** Find sessions preventing vacuum from cleaning up old row versions.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/repl-xmin-from-activity.sql
```


---

### Buffer Cache Analysis

#### Buffer Cache Scripts
**Location:** `diag/sql/buffer_cache/`

A specialized subsystem for analyzing PostgreSQL shared buffers usage and performance.

##### buffer-cache-histogram.sql
**Purpose:** Display histogram of buffer cache usage by object.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/buffer_cache/buffer-cache-histogram.sql
```

##### buffer-cache-utilization.sql
**Purpose:** Show overall buffer cache utilization.

**Output:**
- Total buffers
- Used buffers
- Dirty buffers
- Utilization percentage

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/buffer_cache/buffer-cache-utilization.sql
```

##### buffer-cache-object-utillization.sql
**Purpose:** Display buffer cache usage per database object.

**Output:**
- Database and relation name
- Buffers used
- Percentage of cache

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/buffer_cache/buffer-cache-object-utillization.sql
```

##### buffer-cache-relations-percentage.sql
**Purpose:** Show percentage of each relation in buffer cache.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/buffer_cache/buffer-cache-relations-percentage.sql
```

##### buffer-cache-size.sql
**Purpose:** Display configured buffer cache size.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/buffer_cache/buffer-cache-size.sql
```

**See:** [Buffer Cache README](diag/sql/buffer_cache/README.md) for detailed documentation


---

### Schema & Database Management

#### list-roles.sql
**Purpose:** List all roles (users and groups).

**Output:**
- Role name
- Superuser status
- Create DB privilege
- Create role privilege
- Connection limit
- Valid until

**Use Case:** Security audit, user management.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-roles.sql
```


---

#### list-databases-size.sql
**Purpose:** Display size of all databases.

**Output:**
- Database name
- Size (human-readable)
- Size (bytes)

**Use Case:** Capacity planning, identify largest databases.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-databases-size.sql
```


---

#### list-functions.sql
**Purpose:** List all user-defined functions.

**Output:**
- Schema and function name
- Return type
- Language
- Source code

**Use Case:** Schema documentation, function inventory.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-functions.sql
```


---

#### list-all-settings.sql
**Purpose:** Display all PostgreSQL configuration settings.

**Output:**
- Setting name
- Current value
- Unit
- Category
- Context (restart required, reload, etc.)

**Use Case:** Configuration audit, troubleshooting.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-all-settings.sql
```


---

#### grants-whr-table.sql
**Purpose:** Display all grants (permissions) for a specific table.

**Output:**
- Grantee
- Privilege type
- Grantor
- Grantable status

**Use Case:** Security audit, permission review.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/grants-whr-table.sql
# Script will prompt for table name
```


---

#### list-top10-lowest-buffer-hit-ratio-per-query.sql
**Purpose:** Identify queries with lowest buffer hit ratio (most disk I/O).

**Output:**
- Query text
- Calls
- Buffer hit ratio
- Shared blocks read/hit

**Use Case:** Identify I/O intensive queries requiring optimization.

**Prerequisites:** `pg_stat_statements` extension enabled

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/list-top10-lowest-buffer-hit-ratio-per-query.sql
```


---

#### stat-archiver.sql
**Purpose:** Display WAL archiving status.

**Output:**
- Archived count
- Last archived WAL
- Last archive time
- Failed count
- Last failed WAL

**Use Case:** Monitor WAL archiving health, troubleshoot backup issues.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/stat-archiver.sql
```


---

#### pg_diag.sql
**Purpose:** diagnostic query gathering multiple metrics.

**Output:**
- Various diagnostic information in one query

**Use Case:** Quick health check, general troubleshooting.

**Example:**
```bash
psql -h hostname -U username -d database -f diag/sql/pg_diag.sql
```


---

## Stats Snapshot System

**Location:** `diag/stats_snapshot/`

A historical tracking system for PostgreSQL statistics, enabling trend analysis and performance tracking over time.

### Overview

The Stats Snapshot System periodically captures data from:
- `pg_stat_all_tables` - Table-level statistics (sequential scans, index scans, tuples, vacuum, etc.)
- `pg_stat_all_indexes` - Index usage statistics
- `pg_stat_statements` - Query performance statistics
- `pg_statio_all_tables` - Table I/O statistics
- `pg_statio_all_indexes` - Index I/O statistics
- `replication_slots` - Replication slot status

### Quick Start

**1. Setup the tracking system:**
```bash
psql -h hostname -U username -d database -f diag/stats_snapshot/setup.sql
```

This creates:
- Snapshot tables for historical data
- Helper functions
- Required extensions (pg_stat_statements)

**2. Schedule periodic snapshots (cron):**
```bash
# Add to crontab
# Take snapshot every 15 minutes
*/15 * * * * psql -h hostname -U username -d database -c "SELECT pg_stat_all_tables_history_track();" > /dev/null 2>&1
```

**3. Create views for analysis:**
```bash
psql -h hostname -U username -d database -f diag/stats_snapshot/views/vw_stat_all_tables_history.sql
psql -h hostname -U username -d database -f diag/stats_snapshot/views/vw_stat_all_indexes_history.sql
psql -h hostname -U username -d database -f diag/stats_snapshot/views/vw_stat_statement_history.sql
```

**4. Query historical data:**
```sql
-- View table statistics over time
SELECT * FROM vw_stat_all_tables_history
WHERE schemaname = 'public'
  AND relname = 'users'
ORDER BY snapshot_ts DESC
LIMIT 100;

-- Analyze index usage trends
SELECT * FROM vw_stat_all_indexes_history
WHERE schemaname = 'public'
  AND relname = 'orders'
ORDER BY snapshot_ts DESC;
```

### Features

- **Trend Analysis:** Track metrics over time to identify patterns
- **Capacity Planning:** Historical growth data for storage planning
- **Performance Baseline:** Establish performance baselines
- **Query History:** Track query performance changes over time
- **Automated Collection:** Cron-based snapshot capture

### Reset Data

```bash
# Clear all historical data
psql -h hostname -U username -d database -f diag/stats_snapshot/reset.sql
```

**Detailed Documentation:** [Stats Snapshot README](diag/stats_snapshot/README.md)

---

## Shell Scripts & CLI Utilities

### AWS RDS Integration

#### list-postgres-inst-ids.cli
**Purpose:** List all PostgreSQL RDS instances in a region.

**Syntax:**
```bash
./diag/shell/list-postgres-inst-ids.cli [region]
```

**Output:**
- DB instance identifiers for all PostgreSQL engines (RDS PostgreSQL, Aurora PostgreSQL)

**Example:**
```bash
# List PostgreSQL instances in us-east-1
./diag/shell/list-postgres-inst-ids.cli us-east-1

# List PostgreSQL instances in default region
./diag/shell/list-postgres-inst-ids.cli
```

**Prerequisites:**
- AWS CLI 1.10.30+
- IAM permissions: `rds:DescribeDBInstances`, `rds:DescribeDBClusters`

---

#### psql.cli
**Purpose:** Connect to PostgreSQL RDS instance using AWS CLI for automatic endpoint discovery.

**Syntax:**
```bash
./diag/shell/psql.cli <db-instance-identifier> <postgres-username> [region]
```

**How It Works:**
1. Calls AWS CLI to extract hostname, port, and database name
2. Constructs connection string
3. Connects using psql client
4. Assumes password is stored in `~/.pgpass`

**Example:**
```bash
# Connect to RDS instance
./diag/shell/psql.cli my-postgres-instance postgres us-east-1

# Connect using default region
./diag/shell/psql.cli my-postgres-instance postgres
```

**Prerequisites:**
- AWS CLI 1.10.30+
- `psql` client installed
- Password configured in `~/.pgpass` (see [Configuration](#configuration))

---

#### postgresql-diagnostics.sh
**Purpose:** diagnostic data collection script.

**Syntax:**
```bash
./diag/shell/postgresql-diagnostics.sh <hostname> <port> <database> <username>
```

**What It Collects:**
- Database configuration
- Performance statistics
- Table and index information
- Replication status
- Session information

**Output:** Multiple files with diagnostic data

**Example:**
```bash
./diag/shell/postgresql-diagnostics.sh mydb.abc123.us-east-1.rds.amazonaws.com 5432 postgres postgres
```

---

#### collect-replication-views-to-csv.sh
**Purpose:** Export replication monitoring views to CSV files.

**Syntax:**
```bash
./diag/shell/collect-replication-views-to-csv.sh <hostname> <port> <database> <username>
```

**Output:** CSV files for:
- Replication slots
- Replication sessions
- WAL receiver status
- Database conflicts

**Example:**
```bash
./diag/shell/collect-replication-views-to-csv.sh replica.example.com 5432 postgres postgres
```

---

### Configuration Files

#### pgpass
**Sample file:** `diag/shell/pgpass`

Store credentials securely to avoid passwords on command line.

**Format:**
```
hostname:port:database:username:password
```

**Setup:**
```bash
cp diag/shell/pgpass ~/.pgpass
chmod 600 ~/.pgpass
# Edit and add your credentials
```

#### sample.cron
**Sample file:** `diag/shell/sample.cron`

Example cron jobs for automated monitoring.

---

## Quick Start Guide

### 1. Navigate to PostgreSQL Directory

```bash
cd Postgres/
```

### 2. Run a Diagnostic Script

**Local PostgreSQL Instance:**
```bash
psql -h localhost -U postgres -d mydb -f diag/sql/list-tables-bloated.sql
```

**Remote PostgreSQL Instance:**
```bash
psql -h myserver.example.com -U postgres -d mydb -f diag/sql/list-sessions-blocking-others.sql
```

**AWS RDS PostgreSQL (with .pgpass):**
```bash
psql -h mydb.abc123.us-east-1.rds.amazonaws.com -U postgres -d mydb -f diag/sql/repl-slots.sql
```

### 3. Setup Stats Snapshot System

```bash
# Install
psql -h hostname -U postgres -d mydb -f diag/stats_snapshot/setup.sql

# Schedule snapshots
crontab -e
# Add:
*/15 * * * * psql -h hostname -U postgres -d mydb -c "SELECT pg_stat_all_tables_history_track();" >> /var/log/pg-snapshot.log 2>&1
```

### 4. Use AWS RDS Integration

**List all PostgreSQL RDS instances:**
```bash
./diag/shell/list-postgres-inst-ids.cli us-east-1
```

**Connect to RDS instance:**
```bash
./diag/shell/psql.cli my-db-instance postgres us-east-1
```

**Run diagnostic script on RDS:**
```bash
./diag/shell/psql.cli my-db-instance postgres us-east-1 -f diag/sql/list-tables-bloated.sql
```

---

## Common Use Cases

### Use Case 1: Bloat Analysis & Remediation

**Scenario:** "My database is using too much disk space."

```bash
# 1. Check table bloat
psql -h hostname -U postgres -d mydb -f diag/sql/list-tables-bloated.sql > bloat-report.txt

# 2. Check index bloat
psql -h hostname -U postgres -d mydb -f diag/sql/list-btree-bloat.sql >> bloat-report.txt

# 3. Review dead tuples
psql -h hostname -U postgres -d mydb -f diag/sql/list-tables-with-dead-tuples.sql >> bloat-report.txt

# 4. Take action: VACUUM FULL or pg_repack on bloated tables
# For RDS: Use pg_repack extension
psql -h hostname -U postgres -d mydb -c "SELECT pg_repack.repack_table('public', 'bloated_table');"
```

---

### Use Case 2: Performance Troubleshooting

**Scenario:** "The application is slow - what's wrong?"

```bash
# 1. Check for blocking sessions
psql -h hostname -U postgres -d mydb -f diag/sql/list-sessions-blocking-others.sql

# 2. Review active sessions
psql -h hostname -U postgres -d mydb -f diag/sql/list-sessions.sql

# 3. Find I/O intensive queries
psql -h hostname -U postgres -d mydb -f diag/sql/list-top10-lowest-buffer-hit-ratio-per-query.sql

# 4. Analyze buffer cache
psql -h hostname -U postgres -d mydb -f diag/sql/buffer_cache/buffer-cache-utilization.sql
```

---

### Use Case 3: Index Optimization

**Scenario:** "I want to optimize my indexes to improve performance."

```bash
# 1. Find unused indexes
psql -h hostname -U postgres -d mydb -f diag/sql/list-unused-indexes.sql > unused-indexes.txt

# 2. Find duplicate indexes
psql -h hostname -U postgres -d mydb -f diag/sql/list-duplicated-indexes.sql > duplicate-indexes.txt

# 3. Check index bloat
psql -h hostname -U postgres -d mydb -f diag/sql/list-btree-bloat.sql > index-bloat.txt

# 4. Identify low HOT update tables
psql -h hostname -U postgres -d mydb -f diag/sql/top30-tables-with-low-hotupdates.sql

# 5. Review and take action (drop unused, reindex bloated)
```

---

### Use Case 4: Replication Monitoring

**Scenario:** "Is my replication healthy?"

```bash
# On primary:
psql -h primary -U postgres -d mydb -f diag/sql/repl-session.sql
psql -h primary -U postgres -d mydb -f diag/sql/repl-slots.sql

# On standby:
psql -h standby -U postgres -d mydb -f diag/sql/repl-wal-receiver.sql
psql -h standby -U postgres -d mydb -f diag/sql/repl-database-conflicts.sql

# Check for xmin hold-backs
psql -h primary -U postgres -d mydb -f diag/sql/repl-xmin-from-activity.sql
```

---

### Use Case 5: Capacity Planning & Historical Analysis

**Scenario:** "I need to plan for growth and understand trends."

```bash
# 1. Setup stats snapshot system (if not already done)
psql -h hostname -U postgres -d mydb -f diag/stats_snapshot/setup.sql

# 2. Create analysis views
psql -h hostname -U postgres -d mydb -f diag/stats_snapshot/views/vw_stat_all_tables_history.sql

# 3. Query historical table growth
psql -h hostname -U postgres -d mydb -c "
SELECT
    snapshot_ts::date,
    schemaname,
    relname,
    n_live_tup,
    n_dead_tup,
    seq_scan,
    idx_scan
FROM vw_stat_all_tables_history
WHERE schemaname = 'public'
ORDER BY snapshot_ts DESC, n_live_tup DESC
LIMIT 100;
"

# 4. Analyze database size trends
psql -h hostname -U postgres -d mydb -f diag/sql/list-databases-size.sql
```

---

## Prerequisites

### Database Versions

- **PostgreSQL:** 9.6, 10, 11, 12, 13, 14, 15, 16+
- **AWS RDS PostgreSQL:** 9.6+, 10+, 11+, 12+, 13+, 14+, 15+, 16+
- **Aurora PostgreSQL:** Compatible versions

### Client Tools

- **psql:** Version 9.6+ or compatible
- **AWS CLI:** Version 1.10.30+ (for RDS integration scripts)
- **Bash:** Version 4.0+ (for shell scripts)

### Required Extensions

**For some scripts:**
- `pg_stat_statements` - Query performance tracking
- `pg_buffercache` - Buffer cache analysis
- `pg_repack` - Online table/index reorganization (for bloat remediation)

**Enable extensions:**
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_buffercache;
CREATE EXTENSION IF NOT EXISTS pg_repack;  -- If available
```

### Permissions

**Read-Only Scripts:**
Most diagnostic scripts require:
- `pg_monitor` role (PostgreSQL 10+) or
- `SELECT` on system views (pg_stat_*, pg_statio_*, pg_class, etc.)
- `EXECUTE` on `pg_stat_statements` functions

**Administrative Scripts:**
- Stats snapshot setup: `CREATE TABLE`, `CREATE FUNCTION` privileges
- Kill sessions: `pg_signal_backend` role or superuser

**Typical Setup:**
```sql
-- Grant monitoring privileges
GRANT pg_monitor TO monitoring_user;

-- Or for PostgreSQL < 10
GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO monitoring_user;
```

### AWS Requirements

**For RDS Integration Scripts:**
- AWS CLI installed and configured (`aws configure`)
- IAM permissions:
  - `rds:DescribeDBInstances`
  - `rds:DescribeDBClusters` (for Aurora)
- Network access to RDS instances (security groups, NACLs)

---

## Usage Examples

### Running Scripts Locally

```bash
# Direct execution
psql -h hostname -U username -d database -f diag/sql/list-tables-bloated.sql

# Using connection string
psql postgresql://username@hostname:5432/database -f diag/sql/list-sessions.sql

# Using .pgpass (no password prompt)
psql -h hostname -U username -d database -f diag/sql/repl-slots.sql

# Output to file
psql -h hostname -U username -d database -f diag/sql/list-unused-indexes.sql > report.txt

# Run multiple scripts
for script in diag/sql/*.sql; do
    echo "Running $script..."
    psql -h hostname -U username -d database -f $script > output_$(basename $script .sql).txt
done
```

### AWS RDS Integration

```bash
# Interactive connection to RDS
./diag/shell/psql.cli my-db-instance postgres us-east-1

# Run diagnostic script on RDS
./diag/shell/psql.cli my-db-instance postgres us-east-1 -f diag/sql/list-tables-bloated.sql

# Collect diagnostics
./diag/shell/postgresql-diagnostics.sh mydb.abc123.us-east-1.rds.amazonaws.com 5432 postgres postgres

# Export replication data to CSV
./diag/shell/collect-replication-views-to-csv.sh primary.abc123.us-east-1.rds.amazonaws.com 5432 postgres postgres
```

### Automated Monitoring

**Cron Job Examples:**
```bash
# Add to crontab (crontab -e)

# Stats snapshot every 15 minutes
*/15 * * * * psql -h hostname -U postgres -d mydb -c "SELECT pg_stat_all_tables_history_track();" >> /var/log/pg-snapshot.log 2>&1

# Daily bloat report
0 6 * * * psql -h hostname -U postgres -d mydb -f /path/to/diag/sql/list-tables-bloated.sql > /reports/bloat-$(date +\%Y\%m\%d).txt 2>&1

# Hourly blocking session check
0 * * * * psql -h hostname -U postgres -d mydb -f /path/to/diag/sql/list-sessions-blocking-others.sql | grep -A 5 "blocking" > /alerts/blocking-$(date +\%Y\%m\%d-\%H).txt 2>&1

# Replication monitoring every 5 minutes
*/5 * * * * psql -h primary -U postgres -d mydb -f /path/to/diag/sql/repl-session.sql > /monitoring/repl-status.txt 2>&1
```

---

## Configuration

### Setting Up .pgpass

Store credentials securely to avoid passwords on the command line:

**File:** `~/.pgpass`

**Format:**
```
hostname:port:database:username:password
# Examples:
localhost:5432:mydb:postgres:mypassword
mydb.abc123.us-east-1.rds.amazonaws.com:5432:*:postgres:rdspassword
*:*:*:monitoring_user:monitorpass
```

**Set proper permissions:**
```bash
chmod 600 ~/.pgpass
```

**Usage:**
```bash
# Connect without password prompt
psql -h hostname -U username -d database

# Or with explicit file
export PGPASSFILE=/path/to/.pgpass
psql -h hostname -U username -d database
```

**Reference:** [PostgreSQL Password File Documentation](https://www.postgresql.org/docs/current/libpq-pgpass.html)

---

### AWS CLI Configuration

**Configure AWS CLI:**
```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)
```

**Verify configuration:**
```bash
aws rds describe-db-instances --query "DBInstances[?Engine=='postgres'].[DBInstanceIdentifier,Engine]" --output table
```

---

## Additional Resources

### Official PostgreSQL Documentation

- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **Performance Tips:** https://wiki.postgresql.org/wiki/Performance_Optimization
- **Monitoring:** https://www.postgresql.org/docs/current/monitoring-stats.html
- **Replication:** https://www.postgresql.org/docs/current/high-availability.html

### PostgreSQL Happiness Hints

- **Performance Best Practices:** https://ardentperf.com/happiness-hints/

### AWS RDS PostgreSQL Documentation

- **PostgreSQL on Amazon RDS:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
- **Common DBA Tasks:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html
- **Aurora PostgreSQL:** https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraPostgreSQL.html

### Related Tools

- **pgBadger:** https://github.com/darold/pgbadger (PostgreSQL log analyzer)
- **pg-collector:** https://github.com/awslabs/pg-collector (Diagnostics collector)
- **AWS PostgreSQL JDBC:** https://github.com/awslabs/aws-postgresql-jdbc/
- **Stats Analyzer:** https://github.com/samimseih/statsanalyzer/
- **ora2pg:** https://github.com/darold/ora2pg (Oracle to PostgreSQL migration)
- **pg_partman:** https://github.com/pgpartman/pg_partman (Partition management)
- **pg_cron:** https://github.com/citusdata/pg_cron (Job scheduler)

### Connection Poolers

- **pgBouncer:** http://www.pgbouncer.org/
- **RDS Proxy:** https://aws.amazon.com/rds/proxy/

### Community Resources

- **PostgreSQL Wiki:** https://wiki.postgresql.org/
- **Mailing Lists:** https://www.postgresql.org/list/
- **DBA Stack Exchange:** https://dba.stackexchange.com/questions/tagged/postgresql

---

## License

Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use these files except in compliance with the License. A copy of the License is located at:

http://aws.amazon.com/apache2.0/

or in the "license" file accompanying this file.

This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

---

**Need Help?**

- **AWS Support:** https://console.aws.amazon.com/support/
- **PostgreSQL Community:** https://www.postgresql.org/support/
- **Repository Issues:** https://github.com/alidamghani/DBScripts/issues

---

[↩ Back to Main README](../README.md)
