#!/bin/bash

# ============================================================================
# pgAdmin Password File Generator
# ============================================================================
# This script is executed by pgAdmin4 to set up password files
# for automated connections to PostgreSQL databases

# pgAdmin reads passwords from a pgpass-style file
# Format: hostname:port:database:username:password

set -e

# Create pgpass file for password authentication
cat > /tmp/pgpassfile << EOF
postgres:5432:db1:user1:${DB1_PASSWORD:-pass1}
postgres:5432:db2:user2:${DB2_PASSWORD:-pass2}
postgres:5432:db3:user3:${DB3_PASSWORD:-pass3}
postgres:5432:postgres:postgres:${POSTGRES_SUPERUSER_PASSWORD:-postgres}
EOF

# Set correct permissions (pgAdmin/psql requires 600)
chmod 600 /tmp/pgpassfile

echo "✓ pgAdmin password file created"
