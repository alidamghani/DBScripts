# Oracle Diagnostic Scripts & AWS RDS Integration

[<img src="https://www.oracle.com/a/ocom/img/sql.svg" align="right" width="120">](https://www.oracle.com/database/)

## Overview

A comprehensive Oracle diagnostic toolkit with **20+ specialized SQL scripts** and **AWS RDS integration utilities** for performance monitoring, troubleshooting, and capacity planning.

This collection provides Oracle DBAs and engineers with production-ready tools for:
- Expensive SQL identification and analysis
- Session and wait event monitoring
- Tablespace capacity planning and monitoring
- SQL execution plan analysis
- Patch inventory and configuration management
- Redo log sizing recommendations
- AWS RDS integration for automated instance discovery

**Contents:**
- 🔍 **20+ SQL Diagnostic Scripts** - Purpose-built queries for common Oracle troubleshooting scenarios
- 🛠️ **Shell Scripts & CLI Utilities** - AWS RDS integration and batch execution tools
- ☁️ **AWS RDS Optimized** - Native support for RDS Oracle instances
- 📊 **Performance Focus** - Expensive SQL, wait events, and resource consumption analysis
- 💾 **Space Management** - Permanent and temporary tablespace monitoring

---

## Table of Contents

- [SQL Diagnostic Scripts](#sql-diagnostic-scripts)
  - [Performance Analysis](#performance-analysis)
  - [Session Management](#session-management)
  - [Space Management](#space-management)
  - [Schema & Object Analysis](#schema--object-analysis)
  - [System Health](#system-health)
- [Shell Scripts & CLI Utilities](#shell-scripts--cli-utilities)
  - [AWS RDS Integration](#aws-rds-integration)
  - [Batch Execution](#batch-execution)
- [Quick Start Guide](#quick-start-guide)
- [Common Use Cases](#common-use-cases)
- [Prerequisites](#prerequisites)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Additional Resources](#additional-resources)
- [License](#license)

---

## SQL Diagnostic Scripts

### Performance Analysis

#### expensive-sql.sql
**Purpose:** Identify the 50 most expensive SQL statements based on buffer gets per execution.

**Output:**
- SQL ID
- SQL text
- Executions
- Buffer gets per execution
- CPU time
- Elapsed time
- Disk reads

**Use Case:** Performance troubleshooting - identify SQL statements consuming most database resources.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/expensive-sql.sql
```

**Customization:** The script includes commented-out "ORDER BY" clauses for different sorting options:
- Buffer gets/execution (default)
- Total buffer gets
- Elapsed time
- CPU time


---

#### explain-sql-whr-sql_id.sql
**Purpose:** Display execution plan for a specific SQL statement.

**Input:** Prompts for SQL_ID

**Output:**
- Full execution plan
- Cost estimates
- Cardinality estimates
- Access methods

**Use Case:** Understand query execution strategy, identify inefficient operations.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/explain-sql-whr-sql_id.sql
# Enter SQL_ID when prompted
```


---

#### sql-text-whr-sql_id.sql
**Purpose:** Retrieve full SQL text for a given SQL_ID.

**Input:** Prompts for SQL_ID

**Output:**
- Complete SQL statement text

**Use Case:** View full SQL text for statements identified in performance queries.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/sql-text-whr-sql_id.sql
# Enter SQL_ID when prompted
```


---

### Session Management

#### blocking-sessions.sql
**Purpose:** Count sessions currently waiting due to blocking.

**Output:**
- Number of blocked sessions
- Blocking session details
- Lock type
- Wait event

**Use Case:** Identify contention and blocking issues affecting application performance.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/blocking-sessions.sql
```


---

#### session-whr-sid.sql
**Purpose:** Display detailed session information for a specific session ID (SID).

**Input:** Prompts for SID

**Output:**
- Session status
- Username
- Program
- Machine
- SQL ID
- Wait event
- Logon time
- Resource usage

**Use Case:** Investigate specific session behavior or troubleshoot user issues.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/session-whr-sid.sql
# Enter SID when prompted
```


---

#### sessions-whr-username.sql
**Purpose:** Display all sessions for a specific username.

**Input:** Prompts for username

**Output:**
- SID and serial#
- Session status
- Program
- Machine
- SQL ID currently executing
- Wait event

**Use Case:** Monitor all sessions for a specific application user or schema.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/sessions-whr-username.sql
# Enter username when prompted
```


---

#### sessions-whr-sql_id.sql
**Purpose:** Find all sessions currently executing a specific SQL statement.

**Input:** Prompts for SQL_ID

**Output:**
- SID and serial#
- Username
- Session status
- Wait event
- Resource consumption

**Use Case:** Identify which users/sessions are running a problematic query.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/sessions-whr-sql_id.sql
# Enter SQL_ID when prompted
```


---

#### sessions-whr-wait_event.sql
**Purpose:** Display sessions waiting longest on a specific wait event.

**Input:** Prompts for wait event name

**Output:**
- SID and serial#
- Username
- Wait time
- SQL ID
- Blocking session (if applicable)

**Use Case:** Investigate specific wait events causing performance issues.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/sessions-whr-wait_event.sql
# Enter wait event name (e.g., 'db file sequential read')
```


---

#### session-wait-summary.sql
**Purpose:** Count the number of sessions waiting on each Oracle wait event.

**Output:**
- Wait event name
- Number of sessions waiting
- Total wait time

**Use Case:** Identify most common wait events affecting database performance.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/session-wait-summary.sql
```


---

#### session-sql-waits.sql
**Purpose:** Count sessions currently running SQL grouped by wait event.

**Output:**
- Wait event
- Number of active sessions
- SQL IDs involved

**Use Case:** Understand what wait events are impacting active SQL execution.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/session-sql-waits.sql
```


---

#### sessions-using-temp-space.sql
**Purpose:** Display sessions currently using temporary tablespace.

**Output:**
- Session ID
- Username
- SQL ID
- Temporary space used (MB)
- Tablespace name

**Use Case:** Identify sessions consuming temporary space, troubleshoot temp space exhaustion.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/sessions-using-temp-space.sql
```


---

#### longops-whr-sid.sql
**Purpose:** Query timing information from v$session_longops for a specific session.

**Input:** Prompts for SID

**Output:**
- Operation name
- Start time
- Elapsed time
- Time remaining
- Progress percentage

**Use Case:** Monitor long-running operations like index builds, full table scans, backups.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/longops-whr-sid.sql
# Enter SID when prompted
```


---

#### gen-kill-command-whr-sid.sql
**Purpose:** Generate ALTER SYSTEM KILL SESSION command for a specific SID.

**Input:** Prompts for SID

**Output:**
- `ALTER SYSTEM KILL SESSION` statement
- Session metadata for verification

**Use Case:** Generate kill command for problematic sessions.

**Important:** This script generates the command but does NOT execute it. Review before running.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/gen-kill-command-whr-sid.sql
# Enter SID when prompted
# Review output, then execute command manually if appropriate
```


---

### Space Management

#### perm-tablespace-space.sql
**Purpose:** Display space utilization for permanent tablespaces.

**Output:**
- Tablespace name
- Total space (MB)
- Free space (MB)
- Used space (MB)
- Percent free

**Use Case:** Capacity planning, identify tablespaces requiring expansion.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/perm-tablespace-space.sql
```


**Recommendation:** Alert when free space drops below 20%.

---

#### temp-tablespace-space.sql
**Purpose:** Display space utilization for temporary tablespaces.

**Output:**
- Temporary tablespace name
- Total space (MB)
- Free space (MB)
- Used space (MB)
- Percent free

**Use Case:** Monitor temporary space usage, plan for temp space requirements.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/temp-tablespace-space.sql
```


---

### Schema & Object Analysis

#### constraints-whr-table.sql
**Purpose:** Display all constraints for a specific table.

**Input:** Prompts for table name

**Output:**
- **Query 1:** Primary keys and unique constraints
- **Query 2:** Foreign key constraints
- **Query 3:** Indexes on foreign keys
- **Query 4:** Check constraints

**Use Case:** Schema documentation, constraint analysis, performance tuning.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/constraints-whr-table.sql
# Enter table name when prompted
```


---

#### indexes-whr-table.sql
**Purpose:** Display all indexes and indexed columns for a specific table.

**Output:**
- Index name
- Index type (B-Tree, bitmap, etc.)
- Uniqueness
- Column names
- Column positions

**Use Case:** Index analysis, performance tuning, schema documentation.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/indexes-whr-table.sql
# Enter table name when prompted
```


---

### System Health

#### oracle-12-patch-list.sql
**Purpose:** List Oracle patches installed on 12c databases (summary view).

**Output:**
- Patch ID
- Patch description
- Install date
- Status

**Use Case:** Patch inventory, compliance auditing, troubleshooting.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/oracle-12-patch-list.sql
```

**Supported Versions:** Oracle 12c (EE, SE, SE2)


---

#### oracle-12-patch-list-verbose.sql
**Purpose:** List Oracle patches with detailed information (verbose view).

**Output:**
- Patch ID
- Patch UID
- Patch description
- Install date
- Action
- Status
- Bundle series

**Use Case:** Detailed patch analysis, troubleshooting patch-related issues.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/oracle-12-patch-list-verbose.sql
```

**Supported Versions:** Oracle 12c (EE, SE, SE2)


---

#### recommend-redolog-size-count.sql
**Purpose:** Analyze redo log configuration and make sizing recommendations.

**Prerequisites:** Heavy workload running for at least 20 minutes

**Output:**
- Current redo log configuration (size, groups)
- Log switch frequency
- Recommended size and count
- Rationale for recommendations

**Use Case:** Redo log tuning, reduce checkpoint frequency, improve performance.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/recommend-redolog-size-count.sql
```


**Best Practice:** Redo logs should switch approximately every 15-20 minutes under peak load.

---

#### hello-world.sql
**Purpose:** Simple test query to verify connectivity.

**Output:**
- "Hello World!" message from dual

**Use Case:** Test database connections, verify script execution.

**Example:**
```bash
sqlplus username/password@tnsname @diag/sql/hello-world.sql
```


---

## Shell Scripts & CLI Utilities

### AWS RDS Integration

#### list-oracle-inst-ids.cli
**Purpose:** List all Oracle RDS instances in a region.

**Syntax:**
```bash
./diag/shell/list-oracle-inst-ids.cli [region]
```

**Output:**
- DB instance identifiers for all Oracle engines (SE, SE2, EE)

**Example:**
```bash
# List Oracle instances in us-east-1
./diag/shell/list-oracle-inst-ids.cli us-east-1

# List Oracle instances in default region
./diag/shell/list-oracle-inst-ids.cli
```

**Prerequisites:**
- AWS CLI 1.10.30+
- IAM permissions: `rds:DescribeDBInstances`


---

#### sqlplus.cli
**Purpose:** Connect to Oracle RDS instance using AWS CLI for automatic endpoint discovery.

**Syntax:**
```bash
./diag/shell/sqlplus.cli <db-instance-identifier> <oracle-username> [region]
```

**How It Works:**
1. Calls AWS CLI to extract hostname, port, and database name
2. Constructs TNS connect string
3. Connects using sqlplus
4. Prompts for password

**Example:**
```bash
# Connect to RDS instance
./diag/shell/sqlplus.cli my-oracle-instance admin us-east-1

# Connect using default region
./diag/shell/sqlplus.cli my-oracle-instance admin
```

**Prerequisites:**
- AWS CLI 1.10.30+
- Oracle SQL*Plus client installed


---

#### get-alert-log.cli
**Purpose:** Extract Oracle alert log from RDS instance using AWS CLI.

**Syntax:**
```bash
./diag/shell/get-alert-log.cli <db-instance-identifier> [region]
```

**Output:**
- Alert log contents downloaded and displayed

**Use Case:** Troubleshoot Oracle errors, review database events.

**Example:**
```bash
# Download alert log
./diag/shell/get-alert-log.cli my-oracle-instance us-east-1 > alert.log

# View recent errors
./diag/shell/get-alert-log.cli my-oracle-instance us-east-1 | grep -i "ORA-"
```

**Prerequisites:**
- AWS CLI 1.10.30+
- IAM permissions: `rds:DescribeDBLogFiles`, `rds:DownloadDBLogFilePortion`


---

### Batch Execution

#### oracle-sql-driver.cli
**Purpose:** Run a SQL script across multiple Oracle RDS instances.

**Syntax:**
```bash
./diag/shell/oracle-sql-driver.cli <instance-list-file> <oracle-dba-user> <sql-script> [region]
```

**How It Works:**
1. Reads list of DB instance identifiers from file (one per line)
2. Prompts for password once
3. Iterates through instances, constructing TNS connect strings via AWS CLI
4. Executes SQL script on each instance
5. Outputs results

**Example:**
```bash
# Create instance list
./diag/shell/list-oracle-inst-ids.cli us-east-1 > instances.txt

# Run expensive-sql.sql across all instances
./diag/shell/oracle-sql-driver.cli instances.txt admin diag/sql/expensive-sql.sql us-east-1
```

**Prerequisites:**
- AWS CLI 1.10.30+
- SQL*Plus installed
- Same DBA username and password on all instances


---

#### oracle-sql-driver.sh
**Purpose:** Run a SQL script across multiple Oracle instances using TNS connect strings.

**Syntax:**
```bash
./diag/shell/oracle-sql-driver.sh <tns-connect-list-file> <oracle-dba-user> <sql-script>
```

**How It Works:**
1. Reads TNS connect strings from file (one per line)
2. Prompts for password once
3. Iterates through connections
4. Executes SQL script on each database
5. Outputs results

**Example:**
```bash
# Create TNS connect list (see tns-connect-list.sample)
cat > connections.txt <<EOF
//db1.example.com:1521/orcl
//db2.example.com:1521/orcl
mydb_alias
EOF

# Run script across all databases
./diag/shell/oracle-sql-driver.sh connections.txt admin diag/sql/blocking-sessions.sql
```

**TNS Format:**
- Full connect string: `//hostname:port/service_name`
- TNS alias from tnsnames.ora: `alias_name`

**See:** `tns-connect-list.sample` for examples


---

## Quick Start Guide

### 1. Navigate to Oracle Directory

```bash
cd Oracle/
```

### 2. Run a Diagnostic Script

**Local Oracle Instance:**
```bash
sqlplus username/password@localhost:1521/orcl @diag/sql/expensive-sql.sql
```

**Remote Oracle Instance:**
```bash
sqlplus username/password@//dbhost.example.com:1521/proddb @diag/sql/blocking-sessions.sql
```

**Using TNS Alias:**
```bash
sqlplus username/password@prod_db @diag/sql/perm-tablespace-space.sql
```

**AWS RDS Oracle:**
```bash
./diag/shell/sqlplus.cli my-oracle-rds admin us-east-1
# Then run: @diag/sql/expensive-sql.sql
```

### 3. Use AWS RDS Integration

**List all Oracle RDS instances:**
```bash
./diag/shell/list-oracle-inst-ids.cli us-east-1
```

**Connect to RDS instance:**
```bash
./diag/shell/sqlplus.cli my-db-instance admin us-east-1
```

**Run diagnostic across RDS fleet:**
```bash
./diag/shell/list-oracle-inst-ids.cli us-east-1 > instances.txt
./diag/shell/oracle-sql-driver.cli instances.txt admin diag/sql/expensive-sql.sql us-east-1
```

---

## Common Use Cases

### Use Case 1: Performance Troubleshooting

**Scenario:** "My Oracle database is slow - what SQL is consuming resources?"

```bash
# 1. Identify expensive SQL
sqlplus username/password@tnsname @diag/sql/expensive-sql.sql > expensive.txt

# 2. Get full SQL text for top offender
sqlplus username/password@tnsname @diag/sql/sql-text-whr-sql_id.sql
# Enter SQL_ID

# 3. Analyze execution plan
sqlplus username/password@tnsname @diag/sql/explain-sql-whr-sql_id.sql
# Enter SQL_ID

# 4. Find which sessions are running it
sqlplus username/password@tnsname @diag/sql/sessions-whr-sql_id.sql
# Enter SQL_ID
```

---

### Use Case 2: Session & Lock Analysis

**Scenario:** "Users are reporting the application is hanging."

```bash
# 1. Check for blocking sessions
sqlplus username/password@tnsname @diag/sql/blocking-sessions.sql

# 2. Identify most common wait events
sqlplus username/password@tnsname @diag/sql/session-wait-summary.sql

# 3. Investigate specific wait event
sqlplus username/password@tnsname @diag/sql/sessions-whr-wait_event.sql
# Enter wait event name (e.g., 'enq: TX - row lock contention')

# 4. Generate kill command for blocking session (if needed)
sqlplus username/password@tnsname @diag/sql/gen-kill-command-whr-sid.sql
# Enter SID
# Review and execute manually if appropriate
```

---

### Use Case 3: Capacity Planning

**Scenario:** "I need to plan for storage growth and monitor space usage."

```bash
# 1. Check permanent tablespace space
sqlplus username/password@tnsname @diag/sql/perm-tablespace-space.sql > tablespace_report.txt

# 2. Check temporary tablespace space
sqlplus username/password@tnsname @diag/sql/temp-tablespace-space.sql

# 3. Identify sessions using temp space
sqlplus username/password@tnsname @diag/sql/sessions-using-temp-space.sql

# 4. Review and plan expansion
cat tablespace_report.txt
```

---

### Use Case 4: Redo Log Tuning

**Scenario:** "Checkpoint performance is impacting database."

```bash
# 1. Ensure database has been under load for 20+ minutes
# 2. Get redo log recommendations
sqlplus username/password@tnsname @diag/sql/recommend-redolog-size-count.sql

# 3. Review recommendations
# 4. Implement changes if appropriate (requires maintenance window)
```

---

### Use Case 5: Schema Documentation

**Scenario:** "I need to document table constraints and indexes."

```bash
# 1. Get all constraints for a table
sqlplus username/password@tnsname @diag/sql/constraints-whr-table.sql > constraints.txt
# Enter table name

# 2. Get all indexes for a table
sqlplus username/password@tnsname @diag/sql/indexes-whr-table.sql > indexes.txt
# Enter table name

# 3. Review and document
cat constraints.txt indexes.txt
```

---

### Use Case 6: RDS Fleet Monitoring

**Scenario:** "I need to monitor expensive SQL across all Oracle RDS instances."

```bash
# 1. List all Oracle RDS instances
./diag/shell/list-oracle-inst-ids.cli us-east-1 > prod-instances.txt

# 2. Run expensive SQL analysis on all
./diag/shell/oracle-sql-driver.cli prod-instances.txt admin diag/sql/expensive-sql.sql us-east-1 > fleet-analysis.txt

# 3. Review results
less fleet-analysis.txt

# 4. Or monitor tablespace usage across fleet
./diag/shell/oracle-sql-driver.cli prod-instances.txt admin diag/sql/perm-tablespace-space.sql us-east-1 > fleet-space.txt
```

---

## Prerequisites

### Database Versions

- **Oracle SE:** 12.1+
- **Oracle SE2:** 12.1+
- **Oracle EE:** 12.1+
- **Oracle RDS:** 12c, 19c, 21c
- **Note:** Some scripts (patch inventory) require 12c specifically

### Client Tools

- **Oracle SQL*Plus:** 12c+ or compatible
- **Oracle Instant Client:** 12c+ (alternative to full client)
- **AWS CLI:** Version 1.10.30+ (for RDS integration scripts)
- **Bash:** Version 4.0+ (for shell scripts)

### Permissions

**Read-Only Scripts:**
Most diagnostic scripts require:
- `SELECT` privilege on system views (DBA_* or ALL_* views)
- `SELECT` on v$session, v$sql, v$sqlarea, v$sqltext, v$session_longops
- `SELECT` on dba_tablespaces, dba_free_space, dba_temp_free_space
- `SELECT` on dba_constraints, dba_indexes, dba_ind_columns

**Administrative Scripts:**
- Kill command generation: `ALTER SYSTEM` privilege (to execute, not generate)
- Patch inventory: Access to dba_registry_sqlpatch

**Typical Roles:**
- Read-only monitoring: `SELECT_CATALOG_ROLE`
- Administrative tasks: `DBA` role

### AWS Requirements

**For RDS Integration Scripts:**
- AWS CLI installed and configured (`aws configure`)
- IAM permissions:
  - `rds:DescribeDBInstances`
  - `rds:DescribeDBLogFiles` (for alert log)
  - `rds:DownloadDBLogFilePortion` (for alert log)
- Network access to RDS instances (security groups, NACLs)

---

## Usage Examples

### Running Scripts Locally

```bash
# Using password on command line (not recommended for production)
sqlplus username/password@tnsname @diag/sql/expensive-sql.sql

# Prompted for password (more secure)
sqlplus username@tnsname @diag/sql/blocking-sessions.sql

# Using wallet (most secure)
sqlplus /@tns_alias @diag/sql/perm-tablespace-space.sql

# Output to file
sqlplus -S username/password@tnsname @diag/sql/expensive-sql.sql > report.txt

# Redirect input and output
sqlplus username/password@tnsname < diag/sql/hello-world.sql > output.txt
```

### AWS RDS Integration

```bash
# Interactive connection to RDS
./diag/shell/sqlplus.cli my-db-instance admin us-east-1

# Run script on RDS instance
./diag/shell/sqlplus.cli my-db-instance admin us-east-1 <<EOF
@diag/sql/expensive-sql.sql
exit
EOF

# Get alert log from RDS
./diag/shell/get-alert-log.cli my-db-instance us-east-1 | tail -100

# Search alert log for errors
./diag/shell/get-alert-log.cli my-db-instance us-east-1 | grep -i "ORA-" | tail -20
```

### Automated Monitoring

**Cron Job Example:**
```bash
# Add to crontab (crontab -e)
# Run expensive SQL analysis every hour
0 * * * * cd /scripts/Oracle && sqlplus -S admin/password@proddb @diag/sql/expensive-sql.sql > /reports/expensive-$(date +\%Y\%m\%d-\%H).txt 2>&1

# Daily tablespace monitoring
0 8 * * * cd /scripts/Oracle && sqlplus -S admin/password@proddb @diag/sql/perm-tablespace-space.sql > /reports/tablespace-$(date +\%Y\%m\%d).txt 2>&1

# RDS fleet monitoring every 4 hours
0 */4 * * * cd /scripts/Oracle/diag/shell && ./oracle-sql-driver.cli /config/prod-instances.txt admin expensive-sql.sql us-east-1 > /reports/fleet-$(date +\%Y\%m\%d-\%H).txt 2>&1
```

---

## Configuration

### TNS Names Configuration

**File:** `$ORACLE_HOME/network/admin/tnsnames.ora` or `$TNS_ADMIN/tnsnames.ora`

**Example:**
```
PRODDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = db.example.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )

# AWS RDS Oracle
RDS_ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = mydb.abc123.us-east-1.rds.amazonaws.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = ORCL)
    )
  )
```

**Usage:**
```bash
sqlplus username@PRODDB
sqlplus username@RDS_ORCL
```

---

### Oracle Wallet (Secure Credentials)

**Create wallet:**
```bash
mkstore -wrl /home/oracle/wallet -create

# Add credentials
mkstore -wrl /home/oracle/wallet -createCredential PRODDB username password
```

**Configure sqlnet.ora:**
```
WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = /home/oracle/wallet)
    )
  )

SQLNET.WALLET_OVERRIDE = TRUE
```

**Usage:**
```bash
sqlplus /@PRODDB  # No password needed!
```

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
aws rds describe-db-instances --query "DBInstances[?Engine=='oracle-se2'].[DBInstanceIdentifier,Engine]" --output table
```

---

## Additional Resources

### Official Oracle Documentation

- **Oracle Database Documentation:** https://docs.oracle.com/en/database/
- **Performance Tuning Guide:** https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/
- **SQL Tuning Guide:** https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/
- **Reference Manual:** https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/

### AWS RDS Oracle Documentation

- **Oracle on Amazon RDS:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Oracle.html
- **Common DBA Tasks:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.Oracle.CommonDBATasks.html
- **Best Practices:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html

### Performance & Tuning Resources

- **Oracle Wait Events:** https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/descriptions-of-wait-events.html
- **SQL Tuning Advisor:** https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/sql-tuning-advisor.html
- **Oracle Ask TOM:** https://asktom.oracle.com/

### Community Resources

- **Oracle Community:** https://community.oracle.com/
- **Oracle Technology Network:** https://www.oracle.com/technical-resources/
- **DBA Stack Exchange:** https://dba.stackexchange.com/questions/tagged/oracle

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
- **Oracle Support:** https://support.oracle.com/
- **Repository Issues:** https://github.com/alidamghani/DBScripts/issues

---

[↩ Back to Main README](../README.md)
