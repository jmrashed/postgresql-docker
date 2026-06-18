#!/bin/bash

# ============================================================================
# PostgreSQL Database Initialization Script
# ============================================================================
# This script orchestrates the initialization of multiple databases with
# sample data. It's executed automatically by PostgreSQL during first startup.

set -e  # Exit on any error
set -u  # Exit on undefined variable

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
# Create databases first
# ============================================================================
echo "Step 1: Creating databases..."

psql -d postgres << EOF
CREATE DATABASE $DB1_NAME;
CREATE DATABASE $DB2_NAME;
CREATE DATABASE $DB3_NAME;
EOF

echo "Databases created"

# ============================================================================
# Create users with passwords
# ============================================================================
echo ""
echo "Step 2: Creating users..."

psql -d postgres << EOF
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB1_USER') THEN
    EXECUTE 'CREATE ROLE $DB1_USER WITH LOGIN ENCRYPTED PASSWORD ''$DB1_PASSWORD''';
  ELSE
    EXECUTE 'ALTER ROLE $DB1_USER WITH ENCRYPTED PASSWORD ''$DB1_PASSWORD''';
  END IF;
END \$\$;

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB2_USER') THEN
    EXECUTE 'CREATE ROLE $DB2_USER WITH LOGIN ENCRYPTED PASSWORD ''$DB2_PASSWORD''';
  ELSE
    EXECUTE 'ALTER ROLE $DB2_USER WITH ENCRYPTED PASSWORD ''$DB2_PASSWORD''';
  END IF;
END \$\$;

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB3_USER') THEN
    EXECUTE 'CREATE ROLE $DB3_USER WITH LOGIN ENCRYPTED PASSWORD ''$DB3_PASSWORD''';
  ELSE
    EXECUTE 'ALTER ROLE $DB3_USER WITH ENCRYPTED PASSWORD ''$DB3_PASSWORD''';
  END IF;
END \$\$;
EOF

echo "Users created"

# ============================================================================
# Grant permissions and set ownership
# ============================================================================
echo ""
echo "Step 3: Granting permissions..."

psql -d postgres << EOF
GRANT ALL PRIVILEGES ON DATABASE $DB1_NAME TO $DB1_USER;
GRANT CONNECT ON DATABASE $DB1_NAME TO $DB1_USER;
ALTER DATABASE $DB1_NAME OWNER TO $DB1_USER;

GRANT ALL PRIVILEGES ON DATABASE $DB2_NAME TO $DB2_USER;
GRANT CONNECT ON DATABASE $DB2_NAME TO $DB2_USER;
ALTER DATABASE $DB2_NAME OWNER TO $DB2_USER;

GRANT ALL PRIVILEGES ON DATABASE $DB3_NAME TO $DB3_USER;
GRANT CONNECT ON DATABASE $DB3_NAME TO $DB3_USER;
ALTER DATABASE $DB3_NAME OWNER TO $DB3_USER;

REVOKE ALL PRIVILEGES ON DATABASE $DB1_NAME FROM PUBLIC;
REVOKE CONNECT ON DATABASE $DB1_NAME FROM PUBLIC;
REVOKE ALL PRIVILEGES ON DATABASE $DB2_NAME FROM PUBLIC;
REVOKE CONNECT ON DATABASE $DB2_NAME FROM PUBLIC;
REVOKE ALL PRIVILEGES ON DATABASE $DB3_NAME FROM PUBLIC;
REVOKE CONNECT ON DATABASE $DB3_NAME FROM PUBLIC;
EOF

# Also grant and alter table ownership for existing tables
# (tables created by postgres need explicit ownership change)
psql -d "$DB1_NAME" << EOF
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB1_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB1_USER;
ALTER TABLE IF EXISTS customers OWNER TO $DB1_USER;
ALTER TABLE IF EXISTS orders OWNER TO $DB1_USER;
EOF

psql -d "$DB2_NAME" << EOF
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB2_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB2_USER;
ALTER TABLE IF EXISTS products OWNER TO $DB2_USER;
ALTER TABLE IF EXISTS inventory_logs OWNER TO $DB2_USER;
EOF

psql -d "$DB3_NAME" << EOF
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB3_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB3_USER;
ALTER TABLE IF EXISTS departments OWNER TO $DB3_USER;
ALTER TABLE IF EXISTS employees OWNER TO $DB3_USER;
EOF

echo "Permissions granted"

# ============================================================================
# Sample Data for Database 1
# ============================================================================
echo ""
echo "Step 10: Loading sample data into Database 1..."

psql -d "$DB1_NAME" << SQLEOF
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (name, email, phone) VALUES
    ('John Smith', 'john.smith@example.com', '+1-555-0001'),
    ('Sarah Johnson', 'sarah.johnson@example.com', '+1-555-0002'),
    ('Michael Chen', 'michael.chen@example.com', '+1-555-0003'),
    ('Emma Wilson', 'emma.wilson@example.com', '+1-555-0004'),
    ('Robert Brown', 'robert.brown@example.com', '+1-555-0005'),
    ('Lisa Anderson', 'lisa.anderson@example.com', '+1-555-0006')
ON CONFLICT (email) DO NOTHING;

INSERT INTO orders (customer_id, amount, status) VALUES
    (1, 149.99, 'completed'),
    (1, 299.50, 'completed'),
    (2, 75.00, 'processing'),
    (3, 599.99, 'completed'),
    (4, 199.99, 'pending'),
    (5, 450.00, 'completed'),
    (6, 99.99, 'completed'),
    (2, 249.75, 'completed'),
    (3, 125.50, 'processing'),
    (1, 399.99, 'pending')
ON CONFLICT DO NOTHING;
SQLEOF

psql -d "$DB1_NAME" -v ON_ERROR_STOP=on << EOF
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB1_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB1_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $DB1_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO $DB1_USER;
EOF

echo "Database 1 sample data loaded"

# ============================================================================
# Sample Data for Database 2
# ============================================================================
echo ""
echo "Step 20: Loading sample data into Database 2..."

psql -d "$DB2_NAME" << SQLEOF
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_logs (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    change_qty INTEGER NOT NULL,
    reason VARCHAR(100) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, description, price, stock, sku) VALUES
    ('Wireless Keyboard', 'Mechanical gaming keyboard', 129.99, 45, 'KBD-001'),
    ('USB-C Mouse', 'Ergonomic wireless mouse', 49.99, 120, 'MSE-001'),
    ('4K Monitor', '27-inch 4K UHD monitor', 599.99, 8, 'MON-001'),
    ('Laptop Stand', 'Adjustable aluminum stand', 39.99, 200, 'STA-001'),
    ('HDMI Cable', '6 feet HDMI 2.1', 19.99, 500, 'CAB-001'),
    ('USB Hub', '7-port USB 3.1 hub', 89.99, 35, 'HUB-001'),
    ('LED Desk Lamp', 'Smart LED desk lamp', 59.99, 65, 'LAM-001'),
    ('Webcam 1080p', 'Full HD webcam', 79.99, 28, 'CAM-001')
ON CONFLICT (sku) DO NOTHING;

INSERT INTO inventory_logs (product_id, change_qty, reason, notes) VALUES
    (1, 50, 'purchase', 'Initial stock'),
    (2, 150, 'purchase', 'Bulk order'),
    (1, -5, 'sale', 'Sold to customer'),
    (3, -2, 'sale', 'Sold to corporate'),
    (1, -3, 'damage', 'Damaged units')
ON CONFLICT DO NOTHING;
SQLEOF

psql -d "$DB2_NAME" -v ON_ERROR_STOP=on << EOF
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB2_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB2_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $DB2_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO $DB2_USER;
EOF

echo "Database 2 sample data loaded"

# ============================================================================
# Sample Data for Database 3
# ============================================================================
echo ""
echo "Step 30: Loading sample data into Database 3..."

psql -d "$DB3_NAME" << SQLEOF
CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    budget DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    joined_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO departments (name, description, budget) VALUES
    ('Engineering', 'Software development', 500000.00),
    ('Sales', 'Customer acquisition', 300000.00),
    ('Marketing', 'Brand generation', 200000.00),
    ('Human Resources', 'HR and recruitment', 150000.00),
    ('Finance', 'Financial planning', 180000.00)
ON CONFLICT (name) DO NOTHING;

INSERT INTO employees (name, email, role, salary, department_id, joined_date, status) VALUES
    ('Alice Johnson', 'alice.johnson@company.com', 'Senior Engineer', 120000.00, 1, '2020-01-15', 'active'),
    ('Bob Williams', 'bob.williams@company.com', 'Software Engineer', 95000.00, 1, '2021-03-20', 'active'),
    ('Diana Martinez', 'diana.martinez@company.com', 'Sales Manager', 105000.00, 2, '2020-09-01', 'active')
ON CONFLICT (email) DO NOTHING;
SQLEOF

psql -d "$DB3_NAME" -v ON_ERROR_STOP=on << EOF
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB3_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB3_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $DB3_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO $DB3_USER;
EOF

echo "Database 3 sample data loaded"

# ============================================================================
# Optional: Import custom SQL files
# ============================================================================
if [[ -d "/docker-entrypoint-initdb.d/custom" ]]; then
    echo ""
    echo "Importing custom SQL files..."
    for custom_sql in /docker-entrypoint-initdb.d/custom/*.sql; do
        if [[ -f "$custom_sql" ]]; then
            filename=$(basename "$custom_sql")
            if [[ "$filename" == *.md ]] || [[ "$filename" == PLACEHOLDER* ]]; then
                continue
            fi
            echo "  - Importing: $filename"
            for db in "$DB1_NAME" "$DB2_NAME" "$DB3_NAME"; do
                if psql -v ON_ERROR_STOP=on -d "$db" -f "$custom_sql" 2>/dev/null; then
                    echo "    ✓ Imported to $db"
                    break
                fi
            done
        fi
    done
fi

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
