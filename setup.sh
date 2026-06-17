#!/bin/bash

# ============================================================================
# PostgreSQL Multi-Database Setup - One Command Installation
# ============================================================================
# This script provides a hassle-free one-command setup for:
# - PostgreSQL 16 with Docker
# - 3 databases with isolated users
# - pgAdmin4 web UI
# - Custom SQL import support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${GREEN}[$2]${NC} $1"
}

# ============================================================================
# Generate Random Password
# ============================================================================
generate_password() {
    openssl rand -base64 24 | tr -d '/+=' | head -c 32
}

# ============================================================================
# Check Prerequisites
# ============================================================================
print_header "PostgreSQL Multi-Database Setup"

print_step "Checking prerequisites..." "1/5"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose &> /dev/null; then
    echo -e "${RED}ERROR: Docker Compose is not installed. Please install Docker Compose.${NC}"
    exit 1
fi

# Check if ports are available
if nc -z localhost 5432 2>/dev/null; then
    echo -e "${YELLOW}WARNING: Port 5432 is already in use. PostgreSQL may conflict.${NC}"
fi

if nc -z localhost 5050 2>/dev/null; then
    echo -e "${YELLOW}WARNING: Port 5050 is already in use. pgAdmin may conflict.${NC}"
fi

# ============================================================================
# Custom SQL Import
# ============================================================================
print_step "Checking for custom SQL files..." "2/5"

CUSTOM_SQL_DIR="./custom-sql"
IMPORT_DIR="./init/custom"

if [[ -d "$CUSTOM_SQL_DIR" ]]; then
    echo "Found custom SQL directory: $CUSTOM_SQL_DIR"
    mkdir -p "$IMPORT_DIR"
    
    # Count actual SQL files (excluding placeholder)
    sql_count=$(find "$CUSTOM_SQL_DIR" -name "*.sql" -type f ! -name "*.md" | wc -l)
    if [[ $sql_count -gt 0 ]]; then
        echo "Importing $sql_count SQL file(s)..."
        for sql_file in "$CUSTOM_SQL_DIR"/*.sql; do
            if [[ -f "$sql_file" ]]; then
                filename=$(basename "$sql_file")
                cp "$sql_file" "$IMPORT_DIR/${filename}"
                echo "  - Imported: $filename"
            fi
        done
        echo -e "${GREEN}✓ Custom SQL files imported to $IMPORT_DIR${NC}"
    else
        echo "No SQL files found in custom-sql directory (looking for *.sql)"
    fi
else
    echo "No custom-sql directory found. Skipping custom SQL import."
    echo "To import your SQL, create a 'custom-sql' folder with .sql files and re-run."
fi

# ============================================================================
# Generate Environment File
# ============================================================================
print_step "Generating environment configuration..." "3/5"

if [[ -f ".env" ]]; then
    echo -e "${YELLOW}WARNING: .env file already exists. Backing up to .env.backup${NC}"
    cp .env .env.backup
fi

# Generate random passwords
PG_SUPER_PASS=$(generate_password)
DB1_PASS=$(generate_password)
DB2_PASS=$(generate_password)
DB3_PASS=$(generate_password)
PGADMIN_PASS=$(generate_password)

cat > .env << EOF
# PostgreSQL Superuser (used for initialization only)
POSTGRES_SUPERUSER=postgres
POSTGRES_SUPERUSER_PASSWORD=${PG_SUPER_PASS}

# Database 1 Configuration
DB1_NAME=crm_db
DB1_USER=crm_app
DB1_PASSWORD=${DB1_PASS}

# Database 2 Configuration
DB2_NAME=inventory_db
DB2_USER=inventory_app
DB2_PASSWORD=${DB2_PASS}

# Database 3 Configuration
DB3_NAME=hr_db
DB3_USER=hr_app
DB3_PASSWORD=${DB3_PASS}

# pgAdmin4 Configuration
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=${PGADMIN_PASS}

# Timezone Configuration
TZ=UTC
EOF

chmod 600 .env
echo -e "${GREEN}✓ Generated .env with secure random passwords${NC}"

# ============================================================================
# Start Services
# ============================================================================
print_step "Starting Docker services..." "4/5"

# Use docker compose or docker-compose
COMPOSE_CMD="docker-compose"
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
fi

$COMPOSE_CMD up -d

echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if $COMPOSE_CMD exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
        break
    fi
    sleep 2
    echo -n "."
done

# ============================================================================
# Display Connection Info
# ============================================================================
print_step "Displaying connection information..." "5/5"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 Connection Information:${NC}"
echo ""
echo "PostgreSQL Server: localhost:5432"
echo ""
echo "Database Credentials:"
echo "  Superuser: postgres / ${PG_SUPER_PASS}"
echo "  Database 1 (CRM):    crm_app / ${DB1_PASS}   (crm_db)"
echo "  Database 2 (Inventory): inventory_app / ${DB2_PASS}   (inventory_db)"
echo "  Database 3 (HR):     hr_app / ${DB3_PASS}   (hr_db)"
echo ""
echo "pgAdmin Web UI:"
echo "  URL: http://localhost:5050"
echo "  Email: admin@example.com"
echo "  Password: ${PGADMIN_PASS}"
echo ""
echo -e "${YELLOW}📝 Quick Commands:${NC}"
echo "  View logs:     $COMPOSE_CMD logs -f"
echo "  Stop services: $COMPOSE_CMD stop"
echo "  Remove all:    $COMPOSE_CMD down -v"
echo ""
echo "Credentials saved to .env (chmod 600)"
echo ""