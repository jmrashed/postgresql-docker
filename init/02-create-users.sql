-- ============================================================================
-- Step 2: Create Users/Roles
-- ============================================================================
-- This script creates 3 dedicated users for each database
-- Uses idempotent approach to handle re-execution
-- Executed second in alphabetical order

\set ON_ERROR_STOP on

-- ============================================================================
-- User 1 for Database 1
-- ============================================================================
-- Create user with encrypted password
-- Using DO block for idempotence (PostgreSQL 10+)
DO $$
BEGIN
  CREATE ROLE :DB1_USER WITH 
    LOGIN 
    ENCRYPTED PASSWORD :'DB1_PASSWORD' 
    NOSUPERUSER 
    NOCREATEDB 
    NOCREATEROLE;
  RAISE NOTICE 'User created: %', :'DB1_USER';
EXCEPTION 
  WHEN duplicate_object THEN
    RAISE NOTICE 'User already exists: %, updating password', :'DB1_USER';
    -- Update password if user exists
    EXECUTE 'ALTER ROLE ' || quote_ident(:'DB1_USER') || ' WITH ENCRYPTED PASSWORD ' || quote_literal(:'DB1_PASSWORD');
END $$;

-- ============================================================================
-- User 2 for Database 2
-- ============================================================================
DO $$
BEGIN
  CREATE ROLE :DB2_USER WITH 
    LOGIN 
    ENCRYPTED PASSWORD :'DB2_PASSWORD' 
    NOSUPERUSER 
    NOCREATEDB 
    NOCREATEROLE;
  RAISE NOTICE 'User created: %', :'DB2_USER';
EXCEPTION 
  WHEN duplicate_object THEN
    RAISE NOTICE 'User already exists: %, updating password', :'DB2_USER';
    EXECUTE 'ALTER ROLE ' || quote_ident(:'DB2_USER') || ' WITH ENCRYPTED PASSWORD ' || quote_literal(:'DB2_PASSWORD');
END $$;

-- ============================================================================
-- User 3 for Database 3
-- ============================================================================
DO $$
BEGIN
  CREATE ROLE :DB3_USER WITH 
    LOGIN 
    ENCRYPTED PASSWORD :'DB3_PASSWORD' 
    NOSUPERUSER 
    NOCREATEDB 
    NOCREATEROLE;
  RAISE NOTICE 'User created: %', :'DB3_USER';
EXCEPTION 
  WHEN duplicate_object THEN
    RAISE NOTICE 'User already exists: %, updating password', :'DB3_USER';
    EXECUTE 'ALTER ROLE ' || quote_ident(:'DB3_USER') || ' WITH ENCRYPTED PASSWORD ' || quote_literal(:'DB3_PASSWORD');
END $$;

-- ============================================================================
-- Output confirmation
-- ============================================================================
\echo ''
\echo 'Step 2 Complete: Users created'
\echo '  - ' :DB1_USER
\echo '  - ' :DB2_USER
\echo '  - ' :DB3_USER
\echo ''
