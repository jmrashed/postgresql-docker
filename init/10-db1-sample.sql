-- ============================================================================
-- Step 10: Database 1 Sample Data - CRM (Customers & Orders)
-- ============================================================================
-- This script creates sample tables and inserts sample data
-- into the first database (db1)
-- Executed after user and permission setup

-- This script should be run IN the database, not against postgres
-- PostgreSQL will execute this in the :DB1_NAME database context

\set ON_ERROR_STOP on

-- ============================================================================
-- Table 1: Customers
-- ============================================================================
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);

-- ============================================================================
-- Table 2: Orders
-- ============================================================================
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- ============================================================================
-- Sample Data: Customers
-- ============================================================================
INSERT INTO customers (name, email, phone) VALUES
    ('John Smith', 'john.smith@example.com', '+1-555-0001'),
    ('Sarah Johnson', 'sarah.johnson@example.com', '+1-555-0002'),
    ('Michael Chen', 'michael.chen@example.com', '+1-555-0003'),
    ('Emma Wilson', 'emma.wilson@example.com', '+1-555-0004'),
    ('Robert Brown', 'robert.brown@example.com', '+1-555-0005'),
    ('Lisa Anderson', 'lisa.anderson@example.com', '+1-555-0006')
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- Sample Data: Orders
-- ============================================================================
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

-- ============================================================================
-- Grant table permissions to user1
-- ============================================================================
-- Grant SELECT, INSERT, UPDATE, DELETE privileges on all tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :DB1_USER;
-- Grant permissions on sequences for auto-increment
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO :DB1_USER;
-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO :DB1_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO :DB1_USER;

-- ============================================================================
-- Output confirmation
-- ============================================================================
\echo ''
\echo 'Step 10 Complete: Database 1 Sample Data Initialized'
\echo '  - Customers table: 6 rows'
\echo '  - Orders table: 10 rows'
\echo ''
