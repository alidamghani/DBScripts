# MySQL Diagnostic Scripts & AWS RDS Tools

[<img src="https://www.mysql.com/common/logos/logo-mysql-170x115.png" align="right" width="120">](https://www.mysql.com/)

## Overview

A collection of **11 handy SQL scripts** and **AWS RDS tools** to help you troubleshoot and optimize MySQL databases.

These scripts are useful for:
- Finding sessions that are blocking each other
- Spotting redundant indexes wasting space
- Checking which tables are missing primary keys
- Monitoring disk space usage
- Working with AWS RDS MySQL instances (with special RDS kill commands)
- Quickly connecting to RDS databases

**What's included:**
- 🔍 **11 SQL Scripts** - Common troubleshooting queries for MySQL
- 🛠️ **Shell Scripts** - AWS RDS integration and connection tools
- ☁️ **AWS RDS Support** - Scripts that work with RDS procedures (rds_kill, rds_kill_query)
- 📊 **InnoDB Focus** - Scripts specifically for InnoDB engine
- 🔑 **Schema Checks** - Find missing primary keys

---

## Table of Contents

- [SQL Diagnostic Scripts](#sql-diagnostic-scripts)
  - [Session Management](#session-management)
  - [Index Analysis](#index-analysis)
  - [Schema Validation](#schema-validation)
  - [Space & Capacity](#space--capacity)
- [Shell Scripts & CLI Utilities](#shell-scripts--cli-utilities)
  - [AWS RDS Integration](#aws-rds-integration)
  - [Connection Utilities](#connection-utilities)
- [Quick Start Guide](#quick-start-guide)
- [Common Use Cases](#common-use-cases)
- [Prerequisites](#prerequisites)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Additional Resources](#additional-resources)
- [License](#license)

---

## SQL Diagnostic Scripts

### Session Management

#### blocking-sessions.sql
**Purpose:** Find sessions that are blocking other sessions.

**Output:**
- Blocking session ID
- Blocked session ID
- User and host info
- Current SQL statement
- How long it's been waiting

**Use Case:** When your app slows down, use this to see if sessions are blocking each other.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/blocking-sessions.sql
```


---

#### gen-kill-queries-command.sql
**Purpose:** Generate kill commands that work on AWS RDS.

**Output:**
- `CALL mysql.rds_kill_query(process_id)` statements
- Info about the processes

**Use Case:** On AWS RDS, you can't use regular KILL commands. This generates the RDS-specific commands instead.

**Important:** This just generates the commands - it doesn't run them. Review the output first!

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/gen-kill-queries-command.sql
# Review output, then execute desired commands manually
```


---

#### gen-kill-sessions-command.sql
**Purpose:** Generate kill commands for entire sessions on AWS RDS.

**Output:**
- `CALL mysql.rds_kill(process_id)` statements
- Session details

**Use Case:** When you need to kill hung sessions on AWS RDS.

**Important:** This kills the entire connection, not just the current query.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/gen-kill-sessions-command.sql
# Review output, then execute desired commands manually
```


---

### Index Analysis

#### idx-btree-whr-not-unque-redundancy.sql
**Purpose:** Find redundant indexes that are wasting space.

**Output:**
- Database and table name
- Redundant index name
- Column it indexes
- The composite index that already covers it

**Use Case:** Clean up redundant indexes to speed up writes and save disk space.

**Example:**
```sql
-- If you have these indexes:
-- INDEX idx_user_id (user_id)
-- INDEX idx_user_id_created (user_id, created_at)
-- The first index is redundant!

mysql -h hostname -u username -p < diag/sql/idx-btree-whr-not-unque-redundancy.sql
```


**Recommendation:** Review output carefully. Some "redundant" indexes may be kept for specific query patterns.

---

### Schema Validation

#### table-whr-pk.sql
**Purpose:** List all tables that have a primary key defined.

**Output:**
- Database name
- Table name
- Primary key constraint name

**Use Case:** Schema audit, verify primary key existence across databases.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/table-whr-pk.sql
```


---

#### table-whr-pk-columns.sql
**Purpose:** List all columns participating in primary key definitions.

**Output:**
- Database and table name
- Column name
- Ordinal position in primary key
- Data type

**Use Case:** Primary key analysis, composite key review.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/table-whr-pk-columns.sql
```


---

#### table-whr-pk-missing.sql
**Purpose:** Identify tables without a primary key.

**Output:**
- Database name
- Table name
- Engine
- Row count estimate

**Use Case:** Schema validation - find tables requiring primary key definition (important for replication and Query Performance Insights).

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/table-whr-pk-missing.sql
```


**Best Practice:** All InnoDB tables should have a primary key. Tables without one use a hidden 6-byte row ID, which can impact performance.

---

#### tables-whr-autoincrement.sql
**Purpose:** List all tables with auto-increment columns.

**Output:**
- Database and table name
- Column name
- Current auto-increment value
- Maximum possible value (based on data type)
- Percentage used

**Use Case:** Monitor auto-increment column saturation, plan for type changes before exhaustion.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/tables-whr-autoincrement.sql
```


**Warning:** Auto-increment values approaching maximum can cause INSERT failures.

---

#### tables-whr-no-autoincrement.sql
**Purpose:** List tables with integer columns that could benefit from auto-increment.

**Output:**
- Database and table name
- Integer column name
- Data type

**Use Case:** Schema review, identify potential candidates for auto-increment conversion.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/tables-whr-no-autoincrement.sql
```


---

### Space & Capacity

#### space-allocation.sql
**Purpose:** Report total space allocation across databases and tables.

**Output:**
- Database name
- Data size
- Index size
- Total size
- Free space

**Use Case:** Capacity planning, identify largest databases and tables.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/space-allocation.sql
```


**Note:** Does not include binary logs or other log files.

---

#### innodb-table-whr-tablespace.sql
**Purpose:** Show InnoDB tablespace allocation (system vs file-per-table).

**Output:**
- Database and table name
- Tablespace name
- Tablespace type (System or File-per-table)
- Space allocation

**Use Case:** Understand InnoDB storage layout, verify file-per-table configuration.

**Example:**
```bash
mysql -h hostname -u username -p < diag/sql/innodb-table-whr-tablespace.sql
```


**Best Practice:** File-per-table mode (`innodb_file_per_table=ON`) is recommended for most workloads.

---

## Shell Scripts & CLI Utilities

### AWS RDS Integration

#### list-mysql-inst-ids.cli
**Purpose:** List all MySQL RDS instances in a region.

**Syntax:**
```bash
./diag/shell/list-mysql-inst-ids.cli [region]
```

**Output:**
- DB instance identifiers for all MySQL engines (MySQL, MariaDB, Aurora MySQL)

**Example:**
```bash
# List MySQL instances in us-east-1
./diag/shell/list-mysql-inst-ids.cli us-east-1

# List MySQL instances in default region
./diag/shell/list-mysql-inst-ids.cli
```

**Prerequisites:**
- AWS CLI 1.10.30+
- IAM permissions: `rds:DescribeDBInstances`


---

#### mysql.cli
**Purpose:** Connect to MySQL RDS instance using AWS CLI for automatic endpoint discovery.

**Syntax:**
```bash
./diag/shell/mysql.cli <db-instance-identifier> <mysql-username> [region]
```

**How It Works:**
1. Calls AWS CLI to extract hostname, port, and database name
2. Constructs connection string
3. Connects using mysql client
4. Assumes password is stored in `~/.my.cnf`

**Example:**
```bash
# Connect to RDS instance
./diag/shell/mysql.cli my-mysql-instance admin us-east-1

# Connect using default region
./diag/shell/mysql.cli my-mysql-instance admin
```

**Prerequisites:**
- AWS CLI 1.10.30+
- `mysql` client installed
- Password configured in `~/.my.cnf` (see [Configuration](#configuration))


---

### Connection Utilities

#### RDSDatabaseConnection.java
**Purpose:** Java utility for connecting to MySQL via JDBC and running diagnostic queries.

**Syntax:**
```bash
java RDSDatabaseConnection <hostname> <port> <username> <password> <database>
```

**What It Does:**
- Establishes JDBC connection to MySQL
- Executes several diagnostic SQL statements
- Outputs results

**Example:**
```bash
# Compile
javac RDSDatabaseConnection.java

# Run
java RDSDatabaseConnection mydb.abc123.us-east-1.rds.amazonaws.com 3306 admin mypassword mydb
```

**Prerequisites:**
- Java 1.8+
- MySQL JDBC driver (Connector/J)


---

## Quick Start Guide

### 1. Clone or Navigate to MySQL Directory

```bash
cd Mysql/
```

### 2. Run a Diagnostic Script

**Local MySQL Instance:**
```bash
mysql -h localhost -u root -p < diag/sql/blocking-sessions.sql
```

**Remote MySQL Instance:**
```bash
mysql -h myserver.example.com -u admin -p < diag/sql/space-allocation.sql
```

**AWS RDS MySQL (with credentials file):**
```bash
mysql -h mydb.abc123.us-east-1.rds.amazonaws.com -u admin < diag/sql/table-whr-pk-missing.sql
# Password from ~/.my.cnf
```

### 3. Use AWS RDS Integration

**List all MySQL RDS instances:**
```bash
./diag/shell/list-mysql-inst-ids.cli us-east-1
```

**Connect to RDS instance:**
```bash
./diag/shell/mysql.cli my-db-instance admin us-east-1
```

**Run diagnostic script on RDS instance:**
```bash
./diag/shell/mysql.cli my-db-instance admin us-east-1 < diag/sql/blocking-sessions.sql
```

---

## Common Use Cases

### Use Case 1: Performance Troubleshooting

**Scenario:** "My application is slow - are there blocking sessions?"

```bash
# 1. Check for blocking sessions
mysql -h hostname -u username -p < diag/sql/blocking-sessions.sql

# 2. If blocking found, generate kill commands (RDS)
mysql -h hostname -u username -p < diag/sql/gen-kill-queries-command.sql

# 3. Review output and execute kill commands manually
mysql -h hostname -u username -p -e "CALL mysql.rds_kill_query(123);"
```

---

### Use Case 2: Index Optimization

**Scenario:** "I want to optimize my indexes and reduce storage."

```bash
# 1. Find redundant indexes
mysql -h hostname -u username -p < diag/sql/idx-btree-whr-not-unque-redundancy.sql

# 2. Review output carefully
# 3. Drop redundant indexes
mysql -h hostname -u username -p -e "DROP INDEX idx_redundant ON mydb.mytable;"

# 4. Verify space savings
mysql -h hostname -u username -p < diag/sql/space-allocation.sql
```

---

### Use Case 3: Schema Validation & Audit

**Scenario:** "I need to ensure all tables have primary keys for replication."

```bash
# 1. Find tables without primary keys
mysql -h hostname -u username -p < diag/sql/table-whr-pk-missing.sql

# 2. Review tables that need primary keys

# 3. Verify tables with primary keys
mysql -h hostname -u username -p < diag/sql/table-whr-pk.sql

# 4. Review primary key columns
mysql -h hostname -u username -p < diag/sql/table-whr-pk-columns.sql
```

---

### Use Case 4: Capacity Planning

**Scenario:** "I need to plan for storage growth and monitor space usage."

```bash
# 1. Check overall space allocation
mysql -h hostname -u username -p < diag/sql/space-allocation.sql

# 2. Check InnoDB tablespace allocation
mysql -h hostname -u username -p < diag/sql/innodb-table-whr-tablespace.sql

# 3. Monitor auto-increment saturation
mysql -h hostname -u username -p < diag/sql/tables-whr-autoincrement.sql
```

---

### Use Case 5: AWS RDS Fleet Management

**Scenario:** "I need to run a diagnostic script across all MySQL RDS instances."

```bash
# 1. List all MySQL RDS instances
./diag/shell/list-mysql-inst-ids.cli us-east-1 > instance-list.txt

# 2. Loop through instances and run diagnostic
while read instance; do
    echo "Checking $instance..."
    ./diag/shell/mysql.cli $instance admin us-east-1 < diag/sql/blocking-sessions.sql > output_${instance}.txt
done < instance-list.txt

# 3. Review outputs
ls -lh output_*.txt
```

---

## Prerequisites

### Database Versions

- **MySQL:** 5.6, 5.7, 8.0
- **MariaDB:** 10.0+
- **Aurora MySQL:** 5.6+, 5.7+, 8.0+

### Client Tools

- **mysql client:** Version 5.6+ or compatible
- **AWS CLI:** Version 1.10.30+ (for RDS integration scripts)
- **Java:** JDK/JRE 1.8+ (for JDBC utility)
- **Bash:** Version 4.0+ (for shell scripts)

### Permissions

**Read-Only Scripts:**
Most diagnostic scripts require:
- `SELECT` privilege on `INFORMATION_SCHEMA`
- `SELECT` privilege on `performance_schema` (optional, for some scripts)
- `PROCESS` privilege (to see other users' sessions)

**Administrative Scripts:**
- Kill command generation: `PROCESS` privilege
- Executing kill commands: `SUPER` or `CONNECTION_ADMIN` privilege (MySQL 8.0+)
- AWS RDS: Execute privilege on `mysql.rds_kill` and `mysql.rds_kill_query`

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
# Direct execution with password prompt
mysql -h hostname -u username -p < diag/sql/blocking-sessions.sql

# Using credentials file (recommended)
mysql --defaults-file=~/.my.cnf < diag/sql/space-allocation.sql

# Output to file
mysql -h hostname -u username -p < diag/sql/table-whr-pk-missing.sql > missing_pks.txt

# Run multiple scripts in sequence
for script in diag/sql/*.sql; do
    echo "Running $script..."
    mysql -h hostname -u username -p < $script > output_$(basename $script .sql).txt
done
```

### AWS RDS Integration

```bash
# Connect to RDS instance interactively
./diag/shell/mysql.cli my-db-instance admin us-east-1

# Run diagnostic script on RDS
./diag/shell/mysql.cli my-db-instance admin us-east-1 < diag/sql/blocking-sessions.sql

# Export results from RDS instance
./diag/shell/mysql.cli my-db-instance admin us-east-1 -e "
    SELECT * FROM information_schema.processlist WHERE command != 'Sleep';
" > active_sessions.txt
```

### Automated Monitoring

**Cron Job Example:**
```bash
# Add to crontab (crontab -e)
# Run blocking session check every 5 minutes
*/5 * * * * /path/to/mysql.cli my-db-instance admin us-east-1 < /path/to/blocking-sessions.sql >> /var/log/mysql-blocking.log 2>&1

# Daily space allocation report
0 2 * * * /path/to/mysql.cli my-db-instance admin us-east-1 < /path/to/space-allocation.sql > /reports/space-$(date +\%Y\%m\%d).txt
```

---

## Configuration

### Setting Up .my.cnf

Store credentials securely to avoid passwords on the command line:

**File:** `~/.my.cnf` (or `diag/shell/my.cnf` as template)

```ini
[client]
user=myusername
password=mypassword
host=mydb.abc123.us-east-1.rds.amazonaws.com
port=3306
database=mydatabase
```

**Set proper permissions:**
```bash
chmod 600 ~/.my.cnf
```

**Usage:**
```bash
# Connect without specifying credentials
mysql < diag/sql/blocking-sessions.sql

# Or explicitly reference the file
mysql --defaults-file=~/.my.cnf < diag/sql/blocking-sessions.sql
```

**Reference:** [MySQL Option Files Documentation](http://dev.mysql.com/doc/refman/5.7/en/option-files.html)

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
aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,Engine]" --output table
```

---

## Additional Resources

### Official MySQL Documentation

- **MySQL Reference Manual:** https://dev.mysql.com/doc/
- **InnoDB Storage Engine:** https://dev.mysql.com/doc/refman/8.0/en/innodb-storage-engine.html
- **Performance Schema:** https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html
- **INFORMATION_SCHEMA:** https://dev.mysql.com/doc/refman/8.0/en/information-schema.html

### AWS RDS MySQL Documentation

- **MySQL on Amazon RDS:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html
- **Aurora MySQL:** https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMySQL.html
- **Common DBA Tasks:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MySQL.CommonDBATasks.html
- **RDS MySQL Procedures:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MySQL.CommonDBATasks.html#Appendix.MySQL.CommonDBATasks.End

### Related Tools

- **Percona Toolkit:** https://www.percona.com/software/database-tools/percona-toolkit
- **MySQL Shell:** https://dev.mysql.com/doc/mysql-shell/8.0/en/
- **MySQLTuner:** https://github.com/major/MySQLTuner-perl
- **Orchestrator:** https://github.com/openark/orchestrator (for replication management)

### Community Resources

- **MySQL Community:** https://www.mysql.com/community/
- **Planet MySQL:** https://planet.mysql.com/
- **DBA Stack Exchange:** https://dba.stackexchange.com/questions/tagged/mysql

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
- **MySQL Forums:** https://forums.mysql.com/
- **Repository Issues:** https://github.com/alidamghani/DBScripts/issues

---

[↩ Back to Main README](../README.md)
