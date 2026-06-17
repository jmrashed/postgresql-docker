-- ============================================================================
-- Step 30: Database 3 Sample Data - HR (Employees & Departments)
-- ============================================================================
-- This script creates sample tables and inserts sample data
-- into the third database (db3)
-- Executed after user and permission setup

\set ON_ERROR_STOP on

-- ============================================================================
-- Table 1: Departments
-- ============================================================================
CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    budget DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_departments_name ON departments(name);

-- ============================================================================
-- Table 2: Employees
-- ============================================================================
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    joined_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, on_leave
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
CREATE INDEX IF NOT EXISTS idx_employees_department_id ON employees(department_id);
CREATE INDEX IF NOT EXISTS idx_employees_status ON employees(status);
CREATE INDEX IF NOT EXISTS idx_employees_joined_date ON employees(joined_date);

-- ============================================================================
-- Sample Data: Departments
-- ============================================================================
INSERT INTO departments (name, description, budget) VALUES
    ('Engineering', 'Software and infrastructure development', 500000.00),
    ('Sales', 'Customer acquisition and account management', 300000.00),
    ('Marketing', 'Brand and demand generation', 200000.00),
    ('Human Resources', 'HR and recruitment', 150000.00),
    ('Finance', 'Financial planning and accounting', 180000.00)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Sample Data: Employees
-- ============================================================================
INSERT INTO employees (name, email, role, salary, department_id, joined_date, status) VALUES
    ('Alice Johnson', 'alice.johnson@company.com', 'Senior Engineer', 120000.00, 1, '2020-01-15', 'active'),
    ('Bob Williams', 'bob.williams@company.com', 'Software Engineer', 95000.00, 1, '2021-03-20', 'active'),
    ('Charlie Brown', 'charlie.brown@company.com', 'DevOps Engineer', 110000.00, 1, '2019-06-10', 'active'),
    ('Diana Martinez', 'diana.martinez@company.com', 'Sales Manager', 105000.00, 2, '2020-09-01', 'active'),
    ('Edward Davis', 'edward.davis@company.com', 'Sales Representative', 75000.00, 2, '2022-01-10', 'active'),
    ('Fiona Lee', 'fiona.lee@company.com', 'Marketing Manager', 98000.00, 3, '2020-05-15', 'active'),
    ('George Garcia', 'george.garcia@company.com', 'Content Strategist', 72000.00, 3, '2021-11-01', 'active'),
    ('Helen Rodriguez', 'helen.rodriguez@company.com', 'HR Manager', 85000.00, 4, '2019-08-20', 'active'),
    ('Ian Taylor', 'ian.taylor@company.com', 'Recruiter', 65000.00, 4, '2022-04-15', 'active'),
    ('Julia Anderson', 'julia.anderson@company.com', 'CFO', 150000.00, 5, '2018-02-01', 'active'),
    ('Kevin Thompson', 'kevin.thompson@company.com', 'Accountant', 68000.00, 5, '2021-07-20', 'active'),
    ('Laura White', 'laura.white@company.com', 'Software Engineer', 90000.00, 1, '2022-09-15', 'active')
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- Grant table permissions to user3
-- ============================================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :DB3_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO :DB3_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO :DB3_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO :DB3_USER;

-- ============================================================================
-- Output confirmation
-- ============================================================================
\echo ''
\echo 'Step 30 Complete: Database 3 Sample Data Initialized'
\echo '  - Departments table: 5 rows'
\echo '  - Employees table: 12 rows'
\echo ''
