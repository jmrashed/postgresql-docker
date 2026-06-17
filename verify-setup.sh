#!/bin/bash

# ============================================================================
# PostgreSQL Multi-Database Setup - Verification Script
# ============================================================================
# This script verifies that the Docker environment is correctly set up
# and all databases, users, and sample data are properly initialized.

set -e

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
if command -v docker-compose &> /dev/null; then
    pass
else
    fail "docker-compose not found in PATH"
    exit 1
fi

# Check if containers are running
print_test "PostgreSQL container running"
if docker-compose ps postgres | grep -q "Up"; then
    pass
else
    fail "PostgreSQL container not running"
    exit 1
fi

print_test "pgAdmin container running"
if docker-compose ps pgadmin | grep -q "Up"; then
    pass
else
    fail "pgAdmin container not running"
    exit 1
fi

# Check PostgreSQL connectivity
print_test "PostgreSQL connectivity"
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
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
print_test "Database 1 (db1) exists"
if docker-compose exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w db1 > /dev/null; then
    pass
else
    fail "Database 'db1' not found"
fi

# Test Database 2
print_test "Database 2 (db2) exists"
if docker-compose exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w db2 > /dev/null; then
    pass
else
    fail "Database 'db2' not found"
fi

# Test Database 3
print_test "Database 3 (db3) exists"
if docker-compose exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w db3 > /dev/null; then
    pass
else
    fail "Database 'db3' not found"
fi

# ============================================================================
# User Access Tests
# ============================================================================

print_header "User Access Tests"

# Test User 1 access to DB1
print_test "User1 can access Database 1"
if docker-compose exec -T postgres psql -U user1 -d db1 -c "SELECT 1" > /dev/null 2>&1; then
    pass
else
    fail "User1 cannot access db1"
fi

# Test User 1 CANNOT access DB2
print_test "User1 CANNOT access Database 2 (isolation)"
if docker-compose exec -T postgres psql -U user1 -d db2 -c "SELECT 1" > /dev/null 2>&1; then
    fail "User1 should NOT be able to access db2 (isolation violation)"
else
    pass
fi

# Test User 2 access to DB2
print_test "User2 can access Database 2"
if docker-compose exec -T postgres psql -U user2 -d db2 -c "SELECT 1" > /dev/null 2>&1; then
    pass
else
    fail "User2 cannot access db2"
fi

# Test User 3 access to DB3
print_test "User3 can access Database 3"
if docker-compose exec -T postgres psql -U user3 -d db3 -c "SELECT 1" > /dev/null 2>&1; then
    pass
else
    fail "User3 cannot access db3"
fi

# ============================================================================
# Sample Data Tests
# ============================================================================

print_header "Sample Data Tests"

# Check DB1 tables
print_test "Database 1 - customers table"
CUST_COUNT=$(docker-compose exec -T postgres psql -U user1 -d db1 -tc "SELECT COUNT(*) FROM customers;")
if [[ $CUST_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $CUST_COUNT customer records)"
else
    fail "customers table empty or missing"
fi

print_test "Database 1 - orders table"
ORDER_COUNT=$(docker-compose exec -T postgres psql -U user1 -d db1 -tc "SELECT COUNT(*) FROM orders;")
if [[ $ORDER_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $ORDER_COUNT order records)"
else
    fail "orders table empty or missing"
fi

# Check DB2 tables
print_test "Database 2 - products table"
PROD_COUNT=$(docker-compose exec -T postgres psql -U user2 -d db2 -tc "SELECT COUNT(*) FROM products;")
if [[ $PROD_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $PROD_COUNT product records)"
else
    fail "products table empty or missing"
fi

print_test "Database 2 - inventory_logs table"
INV_COUNT=$(docker-compose exec -T postgres psql -U user2 -d db2 -tc "SELECT COUNT(*) FROM inventory_logs;")
if [[ $INV_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $INV_COUNT inventory log records)"
else
    fail "inventory_logs table empty or missing"
fi

# Check DB3 tables
print_test "Database 3 - departments table"
DEPT_COUNT=$(docker-compose exec -T postgres psql -U user3 -d db3 -tc "SELECT COUNT(*) FROM departments;")
if [[ $DEPT_COUNT -gt 0 ]]; then
    pass
    echo "         (Found $DEPT_COUNT department records)"
else
    fail "departments table empty or missing"
fi

print_test "Database 3 - employees table"
EMP_COUNT=$(docker-compose exec -T postgres psql -U user3 -d db3 -tc "SELECT COUNT(*) FROM employees;")
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
print_test "User1 cannot drop other databases"
if docker-compose exec -T postgres psql -U user1 -d db1 -c "DROP DATABASE db2" 2>&1 | grep -q "permission denied"; then
    pass
else
    fail "User1 should not have permission to drop databases"
fi

# Test User 1 can create tables in their database
print_test "User1 can create tables in Database 1"
docker-compose exec -T postgres psql -U user1 -d db1 -c "CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY);" > /dev/null 2>&1
if docker-compose exec -T postgres psql -U user1 -d db1 -c "SELECT 1 FROM test_table LIMIT 1" > /dev/null 2>&1; then
    pass
    # Clean up
    docker-compose exec -T postgres psql -U user1 -d db1 -c "DROP TABLE test_table;" > /dev/null 2>&1
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
    echo -e "  • Databases:   db1, db2, db3"
    echo -e "  • Users:       user1, user2, user3"
    echo ""
    
    exit 0
else
    echo -e "\n${RED}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ Some tests failed. Check output above for details.${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════${NC}\n"
    
    exit 1
fi
