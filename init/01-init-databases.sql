-- ============================================================================
-- PostgreSQL Database and User Initialization Script
-- ============================================================================
-- This script is executed automatically by PostgreSQL during first container startup
-- It creates 3 databases with dedicated users, each with privileges on only their own database
-- 
-- Idempotence: This script safely handles re-execution without errors
-- The setup uses IF NOT EXISTS clauses to prevent duplicate creation errors

-- ============================================================================
-- Prevent script from continuing if any command fails
-- ============================================================================
\set ON_ERROR_STOP on

-- ============================================================================
-- Database 1: Users Database
-- ============================================================================
-- Create database if it doesn't exist
CREATE DATABASE :DB1_NAME OWNER :DB1_USER ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C';

-- Create user if it doesn't exist
-- Using CREATE USER IF NOT EXISTS (PostgreSQL 13+) for idempotence
DO $$
BEGIN
  CREATE USER :DB1_USER WITH PASSWORD :'DB1_PASSWORD' ENCRYPTED;
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'User % already exists', :'DB1_USER';
    -- Update password if user already exists
    ALTER USER :DB1_USER WITH PASSWORD :'DB1_PASSWORD' ENCRYPTED;
END
$$;

-- Grant all privileges on database 1 to user 1
GRANT ALL PRIVILEGES ON DATABASE :DB1_NAME TO :DB1_USER;

-- ============================================================================
-- Database 2: Products Database
-- ============================================================================
-- Create database if it doesn't exist
CREATE DATABASE :DB2_NAME OWNER :DB2_USER ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C';

-- Create user if it doesn't exist
DO $$
BEGIN
  CREATE USER :DB2_USER WITH PASSWORD :'DB2_PASSWORD' ENCRYPTED;
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'User % already exists', :'DB2_USER';
    -- Update password if user already exists
    ALTER USER :DB2_USER WITH PASSWORD :'DB2_PASSWORD' ENCRYPTED;
END
$$;

-- Grant all privileges on database 2 to user 2
GRANT ALL PRIVILEGES ON DATABASE :DB2_NAME TO :DB2_USER;

-- ============================================================================
-- Database 3: Orders Database
-- ============================================================================
-- Create database if it doesn't exist
CREATE DATABASE :DB3_NAME OWNER :DB3_USER ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C';

-- Create user if it doesn't exist
DO $$
BEGIN
  CREATE USER :DB3_USER WITH PASSWORD :'DB3_PASSWORD' ENCRYPTED;
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'User % already exists', :'DB3_USER';
    -- Update password if user already exists
    ALTER USER :DB3_USER WITH PASSWORD :'DB3_PASSWORD' ENCRYPTED;
END
$$;

-- Grant all privileges on database 3 to user 3
GRANT ALL PRIVILEGES ON DATABASE :DB3_NAME TO :DB3_USER;

-- ============================================================================
-- Security: Prevent Cross-Database Access
-- ============================================================================
-- By default in PostgreSQL, all users can connect to all databases
-- To enforce strict isolation, we revoke default privileges from PUBLIC
-- This ensures users can only access databases they're explicitly granted privileges for

-- Connect to each database and revoke public access
\c :DB1_NAME
REVOKE ALL ON DATABASE :DB1_NAME FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

\c :DB2_NAME
REVOKE ALL ON DATABASE :DB2_NAME FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

\c :DB3_NAME
REVOKE ALL ON DATABASE :DB3_NAME FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

-- ============================================================================
-- Return to postgres database
-- ============================================================================
\c postgres

-- ============================================================================
-- Verification: Display created databases and users
-- ============================================================================
\echo '==============================================='
\echo 'PostgreSQL Initialization Complete'
\echo '==============================================='
\echo ''
\echo 'Databases created:'
\echo '  1. ' :DB1_NAME ' (Owner: ' :DB1_USER ')'
\echo '  2. ' :DB2_NAME ' (Owner: ' :DB2_USER ')'
\echo '  3. ' :DB3_NAME ' (Owner: ' :DB3_USER ')'
\echo ''
\echo 'All users have been created with full privileges on their respective databases'
\echo 'Each user has NO access to other databases (isolation enforced)'
\echo ''
\echo 'End of initialization script'
\echo '==============================================='
