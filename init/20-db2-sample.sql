-- ============================================================================
-- Step 20: Database 2 Sample Data - Inventory (Products & Inventory Logs)
-- ============================================================================
-- This script creates sample tables and inserts sample data
-- into the second database (db2)
-- Executed after user and permission setup

\set ON_ERROR_STOP on

-- ============================================================================
-- Table 1: Products
-- ============================================================================
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

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);

-- ============================================================================
-- Table 2: Inventory Logs
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_logs (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    change_qty INTEGER NOT NULL, -- positive for stock in, negative for stock out
    reason VARCHAR(100) NOT NULL, -- 'purchase', 'sale', 'adjustment', 'damage'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_created_at ON inventory_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_reason ON inventory_logs(reason);

-- ============================================================================
-- Sample Data: Products
-- ============================================================================
INSERT INTO products (name, description, price, stock, sku) VALUES
    ('Wireless Keyboard', 'Mechanical gaming keyboard with RGB lighting', 129.99, 45, 'KBD-001'),
    ('USB-C Mouse', 'Ergonomic wireless mouse with precision tracking', 49.99, 120, 'MSE-001'),
    ('4K Monitor', '27-inch 4K UHD monitor for professionals', 599.99, 8, 'MON-001'),
    ('Laptop Stand', 'Adjustable aluminum laptop stand', 39.99, 200, 'STA-001'),
    ('HDMI Cable', 'High-speed HDMI 2.1 cable, 6 feet', 19.99, 500, 'CAB-001'),
    ('USB Hub', '7-port USB 3.1 hub with power delivery', 89.99, 35, 'HUB-001'),
    ('LED Desk Lamp', 'Smart LED desk lamp with USB charging', 59.99, 65, 'LAM-001'),
    ('Webcam 1080p', 'Full HD webcam with auto-focus', 79.99, 28, 'CAM-001')
ON CONFLICT (sku) DO NOTHING;

-- ============================================================================
-- Sample Data: Inventory Logs
-- ============================================================================
INSERT INTO inventory_logs (product_id, change_qty, reason, notes) VALUES
    (1, 50, 'purchase', 'Initial stock purchase from supplier'),
    (2, 150, 'purchase', 'Bulk order from distributor'),
    (3, 10, 'purchase', 'Premium item restock'),
    (4, 250, 'purchase', 'Office supplies bulk order'),
    (5, 500, 'purchase', 'Cables bulk purchase'),
    (1, -5, 'sale', 'Sold to customer order #123'),
    (2, -30, 'sale', 'Sold in retail batch'),
    (3, -2, 'sale', 'Sold to corporate client'),
    (4, -50, 'sale', 'Office furniture order'),
    (1, -3, 'damage', 'Units damaged in shipping'),
    (6, 40, 'purchase', 'New product initial stock'),
    (7, 70, 'purchase', 'Desk lamp restock'),
    (8, 30, 'purchase', 'Webcam initial stock'),
    (2, -20, 'sale', 'Online store sales'),
    (5, -100, 'sale', 'Bulk cable order to retailer')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Grant table permissions to user2
-- ============================================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :DB2_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO :DB2_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO :DB2_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO :DB2_USER;

-- ============================================================================
-- Output confirmation
-- ============================================================================
\echo ''
\echo 'Step 20 Complete: Database 2 Sample Data Initialized'
\echo '  - Products table: 8 rows'
\echo '  - Inventory logs table: 15 rows'
\echo ''
