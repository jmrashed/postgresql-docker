#!/bin/bash

# ============================================================================
# PostgreSQL Database Initialization Script
# ============================================================================
# This script orchestrates the initialization of multiple databases with
# sample data. It's executed automatically by PostgreSQL during first startup.
#
# Execution order:
# 1. 01-create-db.sql (in postgres database)
# 2. 02-create-users.sql (in postgres database)
# 3. 03-grants.sql (in postgres database)
# 4. 10-db1-sample.sql (in DB1_NAME database)
# 5. 20-db2-sample.sql (in DB2_NAME database)
# 6. 30-db3-sample.sql (in DB3_NAME database)

set -e  # Exit on any error
set -u  # Exit on undefined variable

# ============================================================================
# Verify required environment variables
# ============================================================================
required_vars=(
    "DB1_NAME" "DB1_USER" "DB1_PASSWORD"
    "DB2_NAME" "DB2_USER" "DB2_PASSWORD"
    "DB3_NAME" "DB3_USER" "DB3_PASSWORD"
    "POSTGRES_USER"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        missing_vars+=("$var")
    fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo "ERROR: Missing required environment variables:"
    printf '  - %s\n' "${missing_vars[@]}"
    exit 1
fi

echo ""
echo "=========================================="
echo "PostgreSQL Multi-Database Initialization"
echo "=========================================="
echo ""
echo "Databases to create:"
echo "  1. $DB1_NAME (user: $DB1_USER)"
echo "  2. $DB2_NAME (user: $DB2_USER)"
echo "  3. $DB3_NAME (user: $DB3_USER)"
echo ""

# ============================================================================
# Execute initialization scripts in correct order and databases
# ============================================================================

# Function to run SQL with environment variable substitution
run_sql_in_db() {
    local db_name=$1
    local sql_file=$2
    
    echo "Executing: $(basename $sql_file) in database '$db_name'"
    
    psql \
        -v DB1_NAME="$DB1_NAME" \
        -v DB1_USER="$DB1_USER" \
        -v DB1_PASSWORD="$DB1_PASSWORD" \
        -v DB2_NAME="$DB2_NAME" \
        -v DB2_USER="$DB2_USER" \
        -v DB2_PASSWORD="$DB2_PASSWORD" \
        -v DB3_NAME="$DB3_NAME" \
        -v DB3_USER="$DB3_USER" \
        -v DB3_PASSWORD="$DB3_PASSWORD" \
        -d "$db_name" \
        -f "$sql_file"
}

# ============================================================================
# Step 1-3: Database, User, and Permission Setup (in postgres database)
# ============================================================================
echo "Step 1: Creating databases..."
run_sql_in_db "postgres" "/docker-entrypoint-initdb.d/01-create-db.sql"

echo ""
echo "Step 2: Creating users..."
run_sql_in_db "postgres" "/docker-entrypoint-initdb.d/02-create-users.sql"

echo ""
echo "Step 3: Granting permissions..."
run_sql_in_db "postgres" "/docker-entrypoint-initdb.d/03-grants.sql"

# ============================================================================
# Step 10-30: Sample Data (in respective databases)
# ============================================================================
echo ""
echo "Step 10: Loading sample data into Database 1..."
run_sql_in_db "$DB1_NAME" "/docker-entrypoint-initdb.d/10-db1-sample.sql"

echo ""
echo "Step 20: Loading sample data into Database 2..."
run_sql_in_db "$DB2_NAME" "/docker-entrypoint-initdb.d/20-db2-sample.sql"

echo ""
echo "Step 30: Loading sample data into Database 3..."
run_sql_in_db "$DB3_NAME" "/docker-entrypoint-initdb.d/30-db3-sample.sql"

# ============================================================================
# Completion message
# ============================================================================
echo ""
echo "=========================================="
echo "✓ All initialization steps completed!"
echo "=========================================="
echo ""
echo "Databases ready:"
echo "  • $DB1_NAME -> user: $DB1_USER (CRM: Customers & Orders)"
echo "  • $DB2_NAME -> user: $DB2_USER (Inventory: Products & Logs)"
echo "  • $DB3_NAME -> user: $DB3_USER (HR: Employees & Departments)"
echo ""
echo "pgAdmin4 is available at: http://localhost:5050"
echo ""
