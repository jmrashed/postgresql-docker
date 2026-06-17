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
postgres:5432:crm_db:crm_app:${DB1_PASSWORD:-C9kR2nM7pL5vQ8jB3hX4sT0cW6dE1fG}
postgres:5432:inventory_db:inventory_app:${DB2_PASSWORD:-I4mP9qL2nO6vR3jB5hT8sW0cX7dE1fK}
postgres:5432:hr_db:hr_app:${DB3_PASSWORD:-H6rL1nE3pM9vK4jB7sT5cW0dX2fG8jQ}
postgres:5432:postgres:postgres:${POSTGRES_SUPERUSER_PASSWORD:-K7mP2nL9rQ4vX8jB5hT0sW3cE6dF1gI}
EOF

# Set correct permissions (pgAdmin/psql requires 600)
chmod 600 /tmp/pgpassfile

echo "✓ pgAdmin password file created"
