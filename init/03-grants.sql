-- ============================================================================
-- Step 3: Grant Database Permissions
-- ============================================================================
-- This script assigns privileges to users
-- Each user has FULL access only to their own database
-- Executed third in alphabetical order

\set ON_ERROR_STOP on

-- ============================================================================
-- Grant privileges on Database 1 to User 1
-- ============================================================================
GRANT ALL PRIVILEGES ON DATABASE :DB1_NAME TO :DB1_USER;
GRANT CONNECT ON DATABASE :DB1_NAME TO :DB1_USER;

-- ============================================================================
-- Grant privileges on Database 2 to User 2
-- ============================================================================
GRANT ALL PRIVILEGES ON DATABASE :DB2_NAME TO :DB2_USER;
GRANT CONNECT ON DATABASE :DB2_NAME TO :DB2_USER;

-- ============================================================================
-- Grant privileges on Database 3 to User 3
-- ============================================================================
GRANT ALL PRIVILEGES ON DATABASE :DB3_NAME TO :DB3_USER;
GRANT CONNECT ON DATABASE :DB3_NAME TO :DB3_USER;

-- ============================================================================
-- Security: Revoke default PUBLIC access
-- ============================================================================
-- Prevent users from connecting to databases they shouldn't access
-- This enforces isolation between the three databases

-- Revoke PUBLIC access from all databases
REVOKE ALL PRIVILEGES ON DATABASE :DB1_NAME FROM PUBLIC;
REVOKE ALL PRIVILEGES ON DATABASE :DB2_NAME FROM PUBLIC;
REVOKE ALL PRIVILEGES ON DATABASE :DB3_NAME FROM PUBLIC;

-- Remove PUBLIC connect access (STRICT ISOLATION)
REVOKE CONNECT ON DATABASE :DB1_NAME FROM PUBLIC;
REVOKE CONNECT ON DATABASE :DB2_NAME FROM PUBLIC;
REVOKE CONNECT ON DATABASE :DB3_NAME FROM PUBLIC;

-- ============================================================================
-- Output confirmation
-- ============================================================================
\echo ''
\echo 'Step 3 Complete: Database permissions granted'
\echo '  - User ' :DB1_USER ' -> Database ' :DB1_NAME
\echo '  - User ' :DB2_USER ' -> Database ' :DB2_NAME
\echo '  - User ' :DB3_USER ' -> Database ' :DB3_NAME
\echo 'PUBLIC access REVOKED - databases are isolated'
\echo ''
