-- ============================================================================
-- Step 1: Create Databases
-- ============================================================================
-- This script creates 3 isolated databases for different application modules
-- Executed first in alphabetical order during PostgreSQL initialization

-- Prevent script from continuing on errors
\set ON_ERROR_STOP on

-- ============================================================================
-- Database 1: CRM Database (customers + orders)
-- ============================================================================
CREATE DATABASE :DB1_NAME 
  WITH 
    OWNER :DB1_USER
    ENCODING 'UTF8'
    LC_COLLATE 'C'
    LC_CTYPE 'C';

-- ============================================================================
-- Database 2: Inventory Database (products + inventory logs)
-- ============================================================================
CREATE DATABASE :DB2_NAME 
  WITH 
    OWNER :DB2_USER
    ENCODING 'UTF8'
    LC_COLLATE 'C'
    LC_CTYPE 'C';

-- ============================================================================
-- Database 3: HR Database (employees + departments)
-- ============================================================================
CREATE DATABASE :DB3_NAME 
  WITH 
    OWNER :DB3_USER
    ENCODING 'UTF8'
    LC_COLLATE 'C'
    LC_CTYPE 'C';

-- ============================================================================
-- Output confirmation
-- ============================================================================
\echo ''
\echo 'Step 1 Complete: Databases created'
\echo '  - ' :DB1_NAME
\echo '  - ' :DB2_NAME
\echo '  - ' :DB3_NAME
\echo ''
