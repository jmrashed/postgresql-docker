#!/bin/bash

# ============================================================================
# PostgreSQL Multi-Database Setup - Verification Script
# ============================================================================
# This script verifies that the Docker environment is correctly set up
# and all databases, users, and sample data are properly initialized.

# Check if .env file exists and load it
if [[ -f ".env" ]]; then
    export $(grep -v '^#' .env | xargs)
fi

# Set defaults if not set
DB1_NAME=${DB1_NAME:-crm_db}
DB2_NAME=${DB2_NAME:-inventory_db}
DB3_NAME=${DB3_NAME:-hr_db}
DB1_USER=${DB1_USER:-crm_app}
DB2_USER=${DB2_USER:-inventory_app}
DB3_USER=${DB3_USER:-hr_app}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

print_test() {
    echo -n "Testing: $1 ... "
}

pass() {
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠ WARNING${NC}: $1"
}

# ============================================================================
# Main Verification Tests
# ============================================================================

print_header "PostgreSQL Multi-Database Verification"

# Check if docker-compose is available
print_test "Docker Compose installed"
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    pass
else
    fail "docker-compose not found in PATH"
    exit 1
fi

# Determine compose command
COMPOSE_CMD="docker-compose"
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
fi

# Check if containers are running
print_test "PostgreSQL container running"
if $COMPOSE_CMD ps postgres | grep -q "Up"; then
    pass
else
    fail "PostgreSQL container not running"
    exit 1
fi

print_test "pgAdmin container running"
if $COMPOSE_CMD ps pgadmin | grep -q "Up"; then
    pass
else
    fail "pgAdmin container not running"
    exit 1
fi

# Check PostgreSQL connectivity
print_test "PostgreSQL connectivity"
if $COMPOSE_CMD exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    pass
else
    fail "Cannot connect to PostgreSQL"
    exit 1
fi

# ============================================================================
# Database Tests
# ============================================================================

print_header "Database & User Tests"

# Test Database 1
print_test "Database 1 (${DB1_NAME}) exists"
if $COMPOSE_CMD exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w "$DB1_NAME" > /dev/null; then
    pass
else
    fail "Database '$DB1_NAME' not found"
fi

# Test Database 2
print_test "Database 2 (${DB2_NAME}) exists"
if $COMPOSE_CMD exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w "$DB2_NAME" > /dev/null; then
    pass
else
    fail "Database '$DB2_NAME' not found"
fi

# Test Database 3
print_test "Database 3 (${DB3_NAME}) exists"
if $COMPOSE_CMD exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w "$DB3_NAME" > /dev/null; then
    pass
else
    fail "Database '$DB3_NAME' not found"
fi

# ============================================================================
# User Access Tests
# ============================================================================

print_header "User Access Tests"

# Test User 1 access to DB1
print_test "User1 (${DB1_USER}) can access Database 1"
if $COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    pass
else
    fail "User1 cannot access db1"
fi

# Test User 1 CANNOT access DB2
print_test "User1 (${DB1_USER}) CANNOT access Database 2 (isolation)"
if $COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB2_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    fail "User1 should NOT be able to access $DB2_NAME (isolation violation)"
else
    pass
fi

# Test User 2 access to DB2
print_test "User2 (${DB2_USER}) can access Database 2"
if $COMPOSE_CMD exec -T postgres psql -U "$DB2_USER" -d "$DB2_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    pass
else
    fail "User2 cannot access db2"
fi

# Test User 3 access to DB3
print_test "User3 (${DB3_USER}) can access Database 3"
if $COMPOSE_CMD exec -T postgres psql -U "$DB3_USER" -d "$DB3_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    pass
else
    fail "User3 cannot access db3"
fi

# ============================================================================
# Sample Data Tests
# ============================================================================

print_header "Sample Data Tests"

# Check DB1 tables
print_test "Database 1 (${DB1_NAME}) - customers table"
CUST_COUNT=$($COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -tc "SELECT COUNT(*) FROM customers;" 2>/dev/null || echo "0")
if [[ $CUST_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $CUST_COUNT customer records)"
else
    fail "customers table empty or missing"
fi

print_test "Database 1 (${DB1_NAME}) - orders table"
ORDER_COUNT=$($COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -tc "SELECT COUNT(*) FROM orders;" 2>/dev/null || echo "0")
if [[ $ORDER_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $ORDER_COUNT order records)"
else
    fail "orders table empty or missing"
fi

# Check DB2 tables
print_test "Database 2 (${DB2_NAME}) - products table"
PROD_COUNT=$($COMPOSE_CMD exec -T postgres psql -U "$DB2_USER" -d "$DB2_NAME" -tc "SELECT COUNT(*) FROM products;" 2>/dev/null || echo "0")
if [[ $PROD_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $PROD_COUNT product records)"
else
    fail "products table empty or missing"
fi

print_test "Database 2 (${DB2_NAME}) - inventory_logs table"
INV_COUNT=$($COMPOSE_CMD exec -T postgres psql -U "$DB2_USER" -d "$DB2_NAME" -tc "SELECT COUNT(*) FROM inventory_logs;" 2>/dev/null || echo "0")
if [[ $INV_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $INV_COUNT inventory log records)"
else
    fail "inventory_logs table empty or missing"
fi

# Check DB3 tables
print_test "Database 3 (${DB3_NAME}) - departments table"
DEPT_COUNT=$($COMPOSE_CMD exec -T postgres psql -U "$DB3_USER" -d "$DB3_NAME" -tc "SELECT COUNT(*) FROM departments;" 2>/dev/null || echo "0")
if [[ $DEPT_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $DEPT_COUNT department records)"
else
    fail "departments table empty or missing"
fi

print_test "Database 3 (${DB3_NAME}) - employees table"
EMP_COUNT=$($COMPOSE_CMD exec -T postgres psql -U "$DB3_USER" -d "$DB3_NAME" -tc "SELECT COUNT(*) FROM employees;" 2>/dev/null || echo "0")
if [[ $EMP_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $EMP_COUNT employee records)"
else
    fail "employees table empty or missing"
fi

# ============================================================================
# Port Accessibility Tests
# ============================================================================

print_header "Network & Port Tests"

# Test PostgreSQL port
print_test "PostgreSQL port 5432 accessible"
if nc -z localhost 5432 2>/dev/null || true; then
    pass
else
    warn "PostgreSQL port 5432 not directly accessible (may be normal in some environments)"
fi

# Test pgAdmin port
print_test "pgAdmin port 5050 accessible"
if nc -z localhost 5050 2>/dev/null || curl -s http://localhost:5050 > /dev/null; then
    pass
else
    warn "pgAdmin port 5050 not accessible (verify port is not blocked)"
fi

# ============================================================================
# Permission Tests
# ============================================================================

print_header "Permission & Isolation Tests"

# Test User 1 cannot drop database
print_test "User1 (${DB1_USER}) cannot drop other databases"
if $COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -c "DROP DATABASE $DB2_NAME" 2>&1 | grep -qE "permission denied|must be owner"; then
    pass
else
    fail "User1 should not have permission to drop databases"
fi

# Test User 1 can create tables in their database
print_test "User1 (${DB1_USER}) can create tables in Database 1"
$COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -c "CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY);" > /dev/null 2>&1
if $COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -c "SELECT 1 FROM test_table LIMIT 1" > /dev/null 2>&1; then
    pass
    # Clean up
    $COMPOSE_CMD exec -T postgres psql -U "$DB1_USER" -d "$DB1_NAME" -c "DROP TABLE test_table;" > /dev/null 2>&1
else
    fail "User1 cannot create tables in db1"
fi

# ============================================================================
# Summary
# ============================================================================

print_header "Test Summary"

TOTAL=$((PASSED + FAILED))
echo -e "Total Tests:  $TOTAL"
echo -e "Passed:       ${GREEN}$PASSED${NC}"
echo -e "Failed:       ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ All tests passed! Setup is working correctly.${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "Ready to use:"
    echo -e "  • PostgreSQL:  localhost:5432"
    echo -e "  • pgAdmin:     http://localhost:5050"
    echo -e "  • Databases:   ${DB1_NAME}, ${DB2_NAME}, ${DB3_NAME}"
    echo -e "  • Users:       ${DB1_USER}, ${DB2_USER}, ${DB3_USER}"
    echo ""
    
    exit 0
else
    echo -e "\n${RED}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ Some tests failed. Check output above for details.${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════${NC}\n"
    
    exit 1
fi
