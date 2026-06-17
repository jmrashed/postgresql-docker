#!/bin/bash
# ============================================================================
# PostgreSQL Initialization Script Wrapper
# ============================================================================
# This script substitutes environment variables into the SQL file
# and executes it with proper error handling
# 
# PostgreSQL's docker-entrypoint.sh automatically executes this script
# because it's executable and located in /docker-entrypoint-initdb.d/

set -e  # Exit on error
set -u  # Exit on undefined variable

# ============================================================================
# Verify required environment variables
# ============================================================================
required_vars=(
    "DB1_NAME" "DB1_USER" "DB1_PASSWORD"
    "DB2_NAME" "DB2_USER" "DB2_PASSWORD"
    "DB3_NAME" "DB3_USER" "DB3_PASSWORD"
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

echo "=========================================="
echo "PostgreSQL Database Initialization"
echo "=========================================="
echo ""
echo "Database 1: $DB1_NAME (User: $DB1_USER)"
echo "Database 2: $DB2_NAME (User: $DB2_USER)"
echo "Database 3: $DB3_NAME (User: $DB3_USER)"
echo ""

# ============================================================================
# Execute SQL script with environment variables
# ============================================================================
# Use psql with variable substitution
# The -v flag defines variables that can be used in the SQL script as :VARIABLE_NAME

psql -v DB1_NAME="$DB1_NAME" \
     -v DB1_USER="$DB1_USER" \
     -v DB1_PASSWORD="$DB1_PASSWORD" \
     -v DB2_NAME="$DB2_NAME" \
     -v DB2_USER="$DB2_USER" \
     -v DB2_PASSWORD="$DB2_PASSWORD" \
     -v DB3_NAME="$DB3_NAME" \
     -v DB3_USER="$DB3_USER" \
     -v DB3_PASSWORD="$DB3_PASSWORD" \
     << 'EOF'

-- Include the SQL initialization script content
\i '/docker-entrypoint-initdb.d/01-init-databases.sql'

EOF

echo ""
echo "=========================================="
echo "Initialization completed successfully!"
echo "=========================================="
