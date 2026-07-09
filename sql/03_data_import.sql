-- =====================================================
-- DATA IMPORT PROCESS
-- =====================================================

-- Imported CSV datasets into corresponding tables
-- using MySQL Workbench Table Data Import Wizard

-- Files Imported:
-- customers.csv
-- products.csv
-- orders.csv
-- order_items.csv
-- delivery_performance.csv

-- Import Method:
-- Right Click Table
-- → Table Data Import Wizard
-- → Select CSV File
-- → Use Existing Table
-- → Import Data

-- Data Validation Queries

SELECT COUNT(*) FROM customers;

SELECT COUNT(*) FROM products;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM order_items;

SELECT COUNT(*) FROM delivery_performance;
