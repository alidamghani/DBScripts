 # DBScripts
### Database Diagnostic & Performance Scripts

<p align="center">
  <a href="https://www.mysql.com/"><img src="https://www.mysql.com/common/logos/logo-mysql-170x115.png" width="80" alt="MySQL"></a>
  <a href="https://www.oracle.com/database/"><img src="https://www.oracle.com/a/ocom/img/sql.svg" width="80" alt="Oracle"></a>
  <a href="https://www.postgresql.org/"><img src="Postgres/img/pg_logo.svg" width="80" alt="PostgreSQL"></a>
  <a href="https://www.microsoft.com/sql-server/"><img src="https://www.svgrepo.com/show/303229/microsoft-sql-server-logo.svg" width="80" alt="SQL Server"></a>
</p>

<p align="center">
  <strong>A collection of practical diagnostic and performance tuning scripts for MySQL, Oracle, PostgreSQL, and SQL Server databases.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-GPL--3.0-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/SQL%20Scripts-98-brightgreen.svg" alt="SQL Scripts">
  <img src="https://img.shields.io/badge/Shell%20Scripts-11-orange.svg" alt="Shell Scripts">
  <img src="https://img.shields.io/badge/Platforms-4-red.svg" alt="Platforms">
</p>

---

## Table of Contents

- [Overview](#overview)
- [Supported Database Platforms](#supported-database-platforms)
  - [MySQL](#mysql)
  - [Oracle](#oracle)
  - [PostgreSQL](#postgresql)
  - [SQL Server](#sql-server)
- [Quick Start Guide](#quick-start-guide)
  - [Prerequisites](#prerequisites)
  - [Basic Usage](#basic-usage)
  - [AWS RDS Integration](#aws-rds-integration)
- [Repository Structure](#repository-structure)
- [Common Use Cases](#common-use-cases)
- [Featured Tools](#featured-tools)
- [Platform-Specific Documentation](#platform-specific-documentation)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Additional Resources](#additional-resources)

---

## Overview

**DBScripts** is a collection of useful diagnostic scripts for working with MySQL, Oracle, PostgreSQL, and SQL Server databases. Whether you're a DBA, developer, or just managing your own databases, these scripts can help you troubleshoot issues, optimize performance, and understand what's happening inside your database.

**What's Included:**
- **98 SQL diagnostic scripts** for performance analysis, troubleshooting, and monitoring
- **11 shell/CLI scripts** for AWS RDS integration and automation
- **4 database platforms**: MySQL, Oracle, PostgreSQL, SQL Server
- **Bonus tools** like Brent Ozar's First Responder Kit for SQL Server
- **AWS RDS support** with scripts optimized for cloud databases

**Common Uses:**
- Find and fix slow queries
- Identify blocking sessions and deadlocks
- Analyze and optimize indexes
- Monitor disk space and plan capacity
- Track replication lag
- Collect historical statistics
- Run quick health checks

**Who might find this useful:**
- DBAs managing databases
- Developers troubleshooting performance
- DevOps engineers monitoring systems
- Anyone running databases on AWS RDS
- Students learning database internals

---

## Supported Database Platforms

### MySQL

[<img src="https://www.mysql.com/common/logos/logo-mysql-170x115.png" align="right" width="100" alt="MySQL">](https://www.mysql.com/)

A collection of **11 handy SQL scripts** and **AWS RDS tools** to help you troubleshoot and optimize MySQL databases.

**Key Features:**
- Find sessions blocking each other
- Spot redundant indexes wasting space
- Check which tables are missing primary keys
- Monitor disk space usage
- Track auto-increment columns before they max out
- Generate kill commands for AWS RDS (since KILL doesn't work there)
- Quickly connect to RDS instances

**Script Categories:**
- **Session Analysis:** See what's blocking what, generate kill commands
- **Index Optimization:** Find redundant indexes you can drop
- **Schema Validation:** Spot tables without primary keys
- **Capacity Planning:** Check how much space you're using
- **RDS Integration:** Work with AWS RDS MySQL instances

**Quick Example:**
```bash
# Find blocking sessions
mysql -h hostname -u username -p < Mysql/diag/sql/blocking-sessions.sql

# Connect to AWS RDS MySQL instance
./Mysql/diag/shell/mysql.cli my-rds-instance dbuser us-east-1
```

**Documentation:** [Mysql/mysql.README](Mysql/mysql.README)


---

### Oracle

[<img src="https://www.oracle.com/a/ocom/img/sql.svg" align="right" width="100" alt="Oracle">](https://www.oracle.com/database/)

A collection of **20+ SQL scripts** to help you troubleshoot and tune Oracle databases.

**Key Features:**
- Find your most expensive queries
- See what sessions are doing and what they're waiting for
- Monitor tablespace usage
- Understand query execution plans
- Check installed patches (Oracle 12c)
- Get recommendations for redo log sizing
- Track long-running operations
- Review table constraints and indexes

**Script Categories:**
- **Performance Analysis:** Find expensive queries, see execution plans, analyze waits
- **Session Management:** Check what users are doing and why they're waiting
- **Space Management:** Monitor tablespace usage
- **Schema Analysis:** Look at constraints, indexes, and table structure
- **System Health:** Check patches, tune redo logs
- **RDS Integration:** Tools for AWS RDS Oracle

**Quick Example:**
```bash
# Find expensive SQL statements
sqlplus username/password@tnsname @Oracle/diag/sql/expensive-sql.sql

# Connect to AWS RDS Oracle instance
./Oracle/diag/shell/sqlplus.cli my-oracle-rds dbuser us-east-1
```

**Batch Execution:**
```bash
# Run a script across multiple Oracle instances
./Oracle/diag/shell/oracle-sql-driver.cli instance-list.txt dba_user script.sql us-east-1
```

**Documentation:** [Oracle/oracle.README](Oracle/oracle.README)


---

### PostgreSQL

[<img src="Postgres/img/pg_logo.svg" align="right" width="100" alt="PostgreSQL">](https://www.postgresql.org/)

A collection of **30+ SQL scripts** with special focus on bloat detection, replication monitoring, and historical statistics tracking.

**Key Features:**
- Detect table and index bloat (wasted space)
- Check for dead tuples and vacuum issues
- Analyze buffer cache hit ratios
- Monitor replication lag and conflicts
- Find sessions blocking each other
- Spot unused or duplicate indexes
- **Stats Snapshot System** - Track performance trends over time
- Monitor database size and transaction age

**Script Categories:**
- **Bloat Analysis:** Find bloated tables and indexes that need cleanup
- **Vacuum Monitoring:** Track dead tuples and vacuum progress
- **Buffer Cache:** See what's in memory and cache hit rates
- **Replication:** Monitor replication lag and conflicts
- **Performance:** Find blocking sessions and slow queries
- **Index Optimization:** Spot unused or duplicate indexes you can drop
- **Historical Tracking:** Stats snapshot system to track trends over time

**Featured Subsystems:**
- **Buffer Cache Analysis** (`Postgres/diag/sql/buffer_cache/`)
  - Cache histogram, utilization, object distribution
  - Relation percentage analysis
- **Stats Snapshot System** (`Postgres/diag/stats_snapshot/`)
  - Historical tracking of pg_stat_all_tables, pg_stat_all_indexes
  - Query statement history
  - I/O statistics tracking
  - Setup, reset, and view creation scripts

**Quick Example:**
```bash
# Find blocking sessions
psql -h hostname -U username -d database -f Postgres/diag/sql/list-sessions-blocking-others.sql

# Analyze table bloat
psql -h hostname -U username -d database -f Postgres/diag/sql/list-tables-bloated.sql

# Setup stats snapshot system for historical tracking
psql -h hostname -U username -d database -f Postgres/diag/stats_snapshot/setup.sql
```

**AWS RDS Integration:**
```bash
# List PostgreSQL RDS instances
./Postgres/diag/shell/list-postgres-inst-ids.cli us-east-1

# Connect to RDS instance
./Postgres/diag/shell/psql.cli my-postgres-rds dbuser us-east-1
```

**Documentation:** [Postgres/README.md](Postgres/README.md) (Comprehensive guide with additional resources)


---

### SQL Server

[<img src="https://www.svgrepo.com/show/303229/microsoft-sql-server-logo.svg" align="right" width="100" alt="SQL Server">](https://www.microsoft.com/sql-server/)

A collection of **14 custom diagnostic scripts** plus the complete **Brent Ozar First Responder Kit** (13 procedures) for SQL Server troubleshooting.

**Key Features:**

#### Brent Ozar First Responder Kit (Included)
Scripts **directly from Brent Ozar Unlimited** - trusted by SQL Server DBAs worldwide:
- **sp_Blitz** - Overall health check of your SQL Server
- **sp_BlitzFirst** - Real-time performance analysis ("Why is it slow right now?")
- **sp_BlitzCache** - Find your most expensive queries
- **sp_BlitzIndex** - Get index tuning recommendations
- **sp_BlitzLock** - Understand deadlocks and blocking
- **sp_BlitzBackups** - Check your backup history
- **sp_BlitzWho** - See what's running right now
- And more...

**Installation:** Run `SQLServer/Blitz/Install-All-Scripts.sql`  
**Official Documentation:** https://www.BrentOzar.com/first-aid/  
**Training:** https://www.brentozar.com/product/how-i-use-the-first-responder-kit/

#### Custom Diagnostic Scripts
14 handy scripts for common SQL Server troubleshooting:

| Script | Purpose |
|--------|---------|
| `top_queries.sql` | Top 10 queries by CPU time |
| `backup_info.sql` | Backup history and details |
| `missing_index.sql` | Missing index recommendations from DMVs |
| `unused_index.sql` | Unused index identification for cleanup |
| `average_fragmentation.sql` | Index fragmentation analysis |
| `QueryStore.sql` | Query Store analysis and statistics |
| `sql_diag.sql` | Comprehensive diagnostic information |
| `virtual_disk_io.sql` | Virtual disk I/O statistics |
| `wait_resources.sql` | Wait resource analysis |
| `transaction_log_operations.sql` | Transaction log monitoring |
| `used_space.sql` | Database space utilization |
| `script_users.sql` | User and permission scripting |
| `mssql_partition.sql` | Partition information and statistics |
| `idle_session.sql` | Idle session identification |
| `short_period_waitstats.sql` | Short-term wait statistics |

**Quick Example:**
```sql
-- Using Blitz toolkit (after installation)
EXEC sp_Blitz;                                    -- Health check
EXEC sp_BlitzFirst @SinceStartup = 1;            -- Performance since startup
EXEC sp_BlitzCache @Top = 10;                    -- Top 10 resource queries
EXEC sp_BlitzIndex @DatabaseName = 'MyDB';       -- Index recommendations

-- Using custom scripts
sqlcmd -S hostname -U username -i SQLServer/top_queries.sql
sqlcmd -S hostname -U username -i SQLServer/missing_index.sql
```

**Documentation:** [SQLServer/README.md](SQLServer/README.md) (Comprehensive guide)


---

## Quick Start Guide

### Prerequisites

**Database Client Tools:**
- **MySQL:** `mysql` client 5.6+ or compatible
- **Oracle:** `sqlplus` 12c+ or compatible
- **PostgreSQL:** `psql` 9.6+ or compatible
- **SQL Server:** `sqlcmd` or SQL Server Management Studio (SSMS)

**Optional Tools:**
- **AWS CLI** 1.10.30+ (for RDS integration scripts)
- **Java** 1.8+ (for MySQL JDBC connection utility)

**Permissions:**
Most scripts require read-only access to system and metadata tables. Some administrative scripts (kill commands, configuration changes) require elevated privileges.

---

### Basic Usage

#### SQL Scripts - Direct Execution

**MySQL:**
```bash
mysql -h hostname -u username -p < Mysql/diag/sql/blocking-sessions.sql
mysql -h hostname -u username -p < Mysql/diag/sql/space-allocation.sql
```

**Oracle:**
```bash
sqlplus username/password@tnsname @Oracle/diag/sql/expensive-sql.sql
sqlplus username/password@tnsname @Oracle/diag/sql/session-wait-summary.sql
```

**PostgreSQL:**
```bash
psql -h hostname -U username -d database -f Postgres/diag/sql/list-sessions-blocking-others.sql
psql -h hostname -U username -d database -f Postgres/diag/sql/list-tables-bloated.sql
```

**SQL Server:**
```bash
sqlcmd -S hostname -U username -i SQLServer/top_queries.sql
sqlcmd -S hostname -U username -i SQLServer/missing_index.sql

# Or use SSMS: Open script and execute
```

#### Configuration Files

**MySQL (.my.cnf):**
Store credentials to avoid passwords on command line:
```ini
[client]
user=myusername
password=mypassword
host=hostname
```
Reference: `Mysql/diag/shell/my.cnf`

**PostgreSQL (pgpass):**
Store connection credentials securely:
```
hostname:port:database:username:password
```
Reference: `Postgres/diag/shell/pgpass`

---

### AWS RDS Integration

The toolkit includes specialized shell scripts for AWS RDS integration.

#### MySQL RDS

```bash
# List all MySQL RDS instances in a region
./Mysql/diag/shell/list-mysql-inst-ids.cli us-east-1

# Connect to MySQL RDS instance (uses AWS CLI to extract connection info)
./Mysql/diag/shell/mysql.cli my-rds-instance-id myusername us-east-1

# Assumes password is stored in ~/.my.cnf
```

#### Oracle RDS

```bash
# List all Oracle RDS instances
./Oracle/diag/shell/list-oracle-inst-ids.cli us-east-1

# Connect to Oracle RDS instance
./Oracle/diag/shell/sqlplus.cli my-oracle-rds-id myusername us-east-1

# Run a script across multiple Oracle RDS instances
./Oracle/diag/shell/oracle-sql-driver.cli instance-list.txt dbauser script.sql us-east-1
```

#### PostgreSQL RDS

```bash
# List all PostgreSQL RDS instances
./Postgres/diag/shell/list-postgres-inst-ids.cli us-east-1

# Connect to PostgreSQL RDS instance
./Postgres/diag/shell/psql.cli my-postgres-rds-id myusername us-east-1

# Automated diagnostics collection
./Postgres/diag/shell/postgresql-diagnostics.sh hostname port database username
```

**AWS CLI Requirements:**
- AWS CLI installed and configured
- IAM permissions to describe RDS instances (`rds:DescribeDBInstances`)
- Appropriate database credentials

---

## Repository Structure

```
DBScripts/
│
├── README.md                          # This file - comprehensive overview
├── LICENSE                            # GPL-3.0 License
│
├── Mysql/                             # MySQL diagnostic toolkit
│   ├── mysql.README                   # Detailed MySQL documentation
│   └── diag/
│       ├── sql/                       # 11 SQL diagnostic scripts
│       │   ├── blocking-sessions.sql
│       │   ├── idx-btree-whr-not-unque-redundancy.sql
│       │   ├── space-allocation.sql
│       │   ├── table-whr-pk-missing.sql
│       │   └── ...
│       └── shell/                     # Shell automation & RDS integration
│           ├── list-mysql-inst-ids.cli
│           ├── mysql.cli
│           ├── my.cnf (sample)
│           └── RDSDatabaseConnection.java
│
├── Oracle/                            # Oracle diagnostic toolkit
│   ├── oracle.README                  # Detailed Oracle documentation
│   └── diag/
│       ├── sql/                       # 20+ SQL diagnostic scripts
│       │   ├── expensive-sql.sql
│       │   ├── blocking-sessions.sql
│       │   ├── session-wait-summary.sql
│       │   ├── perm-tablespace-space.sql
│       │   └── ...
│       └── shell/                     # Shell automation & RDS integration
│           ├── list-oracle-inst-ids.cli
│           ├── sqlplus.cli
│           ├── oracle-sql-driver.cli
│           └── ...
│
├── Postgres/                          # PostgreSQL diagnostic toolkit
│   ├── README.md                      # Comprehensive PostgreSQL guide
│   ├── postgres.README                # Additional documentation
│   ├── img/
│   │   └── pg_logo.svg               # PostgreSQL logo
│   └── diag/
│       ├── sql/                       # 30+ SQL diagnostic scripts
│       │   ├── list-sessions-blocking-others.sql
│       │   ├── list-tables-bloated.sql
│       │   ├── list-btree-bloat.sql
│       │   ├── list-unused-indexes.sql
│       │   ├── repl-slots.sql
│       │   └── buffer_cache/          # Buffer cache analysis subsystem
│       │       ├── buffer-cache-histogram.sql
│       │       ├── buffer-cache-utilization.sql
│       │       └── ...
│       ├── shell/                     # Shell automation & RDS integration
│       │   ├── list-postgres-inst-ids.cli
│       │   ├── psql.cli
│       │   ├── postgresql-diagnostics.sh
│       │   └── ...
│       └── stats_snapshot/            # Historical stats tracking system
│           ├── README.md
│           ├── setup.sql
│           ├── reset.sql
│           └── views/                 # Historical stat views
│               ├── vw_stat_all_tables_history.sql
│               ├── vw_stat_all_indexes_history.sql
│               └── ...
│
└── SQLServer/                         # SQL Server diagnostic toolkit
    ├── README.md                      # Comprehensive SQL Server guide
    ├── Blitz/                         # Brent Ozar First Responder Kit
    │   ├── _readme.txt
    │   ├── Install-All-Scripts.sql
    │   ├── Uninstall.sql
    │   ├── sp_Blitz.sql
    │   ├── sp_BlitzFirst.sql
    │   ├── sp_BlitzCache.sql
    │   ├── sp_BlitzIndex.sql
    │   ├── sp_BlitzLock.sql
    │   └── ...
    └── *.sql                          # 14 custom diagnostic scripts
        ├── top_queries.sql
        ├── backup_info.sql
        ├── missing_index.sql
        ├── unused_index.sql
        └── ...
```

---

## Common Use Cases

| Capability | MySQL | Oracle | PostgreSQL | SQL Server |
|------------|:-----:|:------:|:----------:|:----------:|
| **Blocking Sessions** | ✓ | ✓ | ✓ | ✓ (Blitz) |
| **Index Analysis** | ✓ | ✓ | ✓ | ✓ (Blitz) |
| **Query Performance** | ✓ | ✓ | ✓ | ✓ (Blitz) |
| **Space Monitoring** | ✓ | ✓ | ✓ | ✓ |
| **Bloat Detection** | - | - | ✓ | ✓ |
| **Replication Monitoring** | - | - | ✓ | - |
| **Historical Stats** | - | - | ✓ | - |
| **Deadlock Analysis** | - | - | - | ✓ (Blitz) |
| **Health Checks** | - | - | - | ✓ (Blitz) |
| **Wait Analysis** | - | ✓ | - | ✓ (Blitz) |
| **Tablespace Monitoring** | ✓ | ✓ | - | - |
| **Schema Validation** | ✓ | ✓ | - | - |
| **AWS RDS Integration** | ✓ | ✓ | ✓ | - |

---

## Featured Tools

### PostgreSQL Stats Snapshot System

A comprehensive historical tracking system for PostgreSQL statistics, enabling trend analysis and performance tracking over time.

**Location:** `Postgres/diag/stats_snapshot/`

**Capabilities:**
- Historical tracking of `pg_stat_all_tables` and `pg_stat_all_indexes`
- Query statement history from `pg_stat_statements`
- I/O statistics history (`pg_statio_*`)
- Replication slot tracking
- Automated snapshot collection via cron

**Quick Start:**
```bash
# Setup the stats tracking system
psql -h hostname -U username -d database -f Postgres/diag/stats_snapshot/setup.sql

# Create views for analysis
psql -h hostname -U username -d database -f Postgres/diag/stats_snapshot/views/vw_stat_all_tables_history.sql

# Query historical data
psql -h hostname -U username -d database -c "SELECT * FROM vw_stat_all_tables_history WHERE schemaname = 'public' ORDER BY snapshot_ts DESC LIMIT 100;"
```

**Documentation:** [Postgres/diag/stats_snapshot/README.md](Postgres/diag/stats_snapshot/README.md)

---

### SQL Server Blitz Toolkit

The industry-standard **First Responder Kit from Brent Ozar Unlimited** - trusted by thousands of SQL Server professionals worldwide.

**Location:** `SQLServer/Blitz/`

**What It Does:**
The Blitz toolkit answers critical questions about your SQL Server:
- "Is my SQL Server in good shape?" → **sp_Blitz**
- "Why is my SQL Server slow right now?" → **sp_BlitzFirst**
- "What are the most expensive queries?" → **sp_BlitzCache**
- "How can I improve my indexes?" → **sp_BlitzIndex**
- "What's causing deadlocks?" → **sp_BlitzLock**

**Installation:**
```sql
-- Install all procedures at once
USE master;
GO
:r SQLServer/Blitz/Install-All-Scripts.sql
GO
```

**Quick Usage:**
```sql
-- Comprehensive health check
EXEC sp_Blitz;

-- Real-time performance analysis
EXEC sp_BlitzFirst @SinceStartup = 1;

-- Top 10 most expensive queries
EXEC sp_BlitzCache @Top = 10, @SortOrder = 'CPU';

-- Index recommendations for a database
EXEC sp_BlitzIndex @DatabaseName = 'YourDatabase', @Mode = 0;
```

**Official Resources:**
- Documentation: https://www.BrentOzar.com/first-aid/
- Training: https://www.brentozar.com/product/how-i-use-the-first-responder-kit/
- Support: https://www.brentozar.com/support

**Attribution:** Scripts in the `Blitz/` directory are directly from Brent Ozar Unlimited and are subject to their license terms.

---

## Platform-Specific Documentation

Each database platform has comprehensive documentation with detailed script descriptions, usage examples, and version compatibility information:

- **[MySQL Documentation](Mysql/mysql.README)** - Complete MySQL script catalog with RDS integration guide
- **[Oracle Documentation](Oracle/oracle.README)** - Comprehensive Oracle script reference and batch execution examples
- **[PostgreSQL Documentation](Postgres/README.md)** - In-depth PostgreSQL guide with additional tools and resources
- **[SQL Server Documentation](SQLServer/README.md)** - Complete SQL Server guide including Blitz toolkit and custom scripts

---

## Requirements

### Database Versions

| Platform | Minimum Version | Tested Versions | Cloud Support |
|----------|----------------|-----------------|---------------|
| **MySQL** | 5.6 | 5.6, 5.7, 8.0 | AWS RDS, Aurora MySQL |
| **Oracle** | 12.1 | 12.1 SE2, 12.1 EE | AWS RDS Oracle |
| **PostgreSQL** | 9.6 | 9.6, 10, 11, 12, 13+ | AWS RDS, Aurora PostgreSQL |
| **SQL Server** | 2012 | 2012, 2014, 2016, 2017, 2019+ | AWS RDS, Azure SQL |

### Client Tools

- **MySQL:** MySQL Client 5.6+
- **Oracle:** Oracle SQL*Plus 12c+, Oracle Instant Client
- **PostgreSQL:** psql 9.6+
- **SQL Server:** sqlcmd, SQL Server Management Studio (SSMS), or Azure Data Studio

### Optional Dependencies

- **AWS CLI:** Version 1.10.30+ (for RDS integration scripts)
- **Java:** JDK/JRE 1.8+ (for MySQL JDBC utility)
- **Bash:** Version 4.0+ (for shell scripts)

### Permissions

**Read-Only Scripts:**
Most diagnostic and monitoring scripts require read access to:
- System tables and views
- Performance schema / DMVs / pg_stat views
- Metadata catalogs

**Administrative Scripts:**
Some scripts require elevated privileges:
- Kill session/query commands: `PROCESS` privilege (MySQL), `ALTER SYSTEM` (Oracle), `pg_terminate_backend` (PostgreSQL)
- Configuration changes: DBA or sysadmin roles
- Schema modifications: DDL privileges

---

## Contributing

Contributions are welcome! Here's how you can help:

### Adding New Scripts

1. **Create your script** following the existing naming conventions
2. **Test thoroughly** on target database versions
3. **Document the script** with:
   - Description of functionality
   - Input parameters (if any)
   - Output format
   - Tested versions
   - Required permissions
4. **Update the appropriate README** with script details
5. **Submit a pull request** with clear description

### Branch Strategy

- `main` - Stable, production-ready scripts
- `sqlserver` - SQL Server specific development
- Feature branches - For new scripts or enhancements

### Testing Guidelines

- Test on minimum supported version and latest version
- Verify on both on-premises and cloud (RDS/Aurora) environments where applicable
- Ensure scripts are non-destructive (read-only when possible)
- Document any required permissions or prerequisites

### Code Standards

- Use clear, descriptive SQL comments
- Follow platform-specific SQL style guidelines
- Include error handling where appropriate
- Avoid hardcoded values; use parameters or variables

---

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0).

See [LICENSE](LICENSE) file for full license text.

### Third-Party Components

**Brent Ozar First Responder Kit** (`SQLServer/Blitz/` directory):
- Copyright © Brent Ozar Unlimited
- Licensed separately under Brent Ozar Unlimited's license terms
- Official source: https://www.BrentOzar.com/first-aid/
- Not covered by this repository's GPL-3.0 license

---

## Acknowledgments

This toolkit builds upon and incorporates work from various sources:

- **Brent Ozar Unlimited** - For the comprehensive SQL Server First Responder Kit, the industry standard for SQL Server diagnostics and performance analysis
- **AWS Labs** - Original contributions and RDS-specific utilities
- **Database community contributors** - For ongoing improvements and additions

---

## Additional Resources

### Official Database Documentation

- **MySQL:** https://dev.mysql.com/doc/
- **Oracle:** https://docs.oracle.com/en/database/
- **PostgreSQL:** https://www.postgresql.org/docs/
- **SQL Server:** https://docs.microsoft.com/en-us/sql/

### AWS RDS Documentation

- [MySQL on Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html)
- [Oracle on Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Oracle.html)
- [PostgreSQL on Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [SQL Server on Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html)

### Related Tools & Utilities

**PostgreSQL:**
- [pgBadger](https://github.com/darold/pgbadger) - PostgreSQL log analyzer
- [pg-collector](https://github.com/awslabs/pg-collector) - PostgreSQL diagnostics collector
- [pg_partman](https://github.com/pgpartman/pg_partman) - Partition management
- [pg_cron](https://github.com/citusdata/pg_cron) - Job scheduler

**SQL Server:**
- [Brent Ozar Tools](https://www.BrentOzar.com/first-aid/) - Official First Responder Kit site
- [SQL Server Performance Tuning](https://www.brentozar.com/sql-server-performance-tuning/)

**Oracle:**
- [Oracle Performance Tuning Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/)

**MySQL:**
- [MySQL Performance Schema](https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html)
- [Percona Toolkit](https://www.percona.com/software/database-tools/percona-toolkit)

### Community & Support

- **Repository:** https://github.com/alidamghani/DBScripts/
- **Issues:** Report bugs or request features via GitHub Issues
- **Discussions:** Share experiences and best practices

---

**Made with ❤️ for database professionals worldwide**

*Star this repository if you find it useful!*