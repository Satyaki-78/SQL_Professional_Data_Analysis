
use DataWarehouseAnalytics;

-- Explore All Objects in the Database
SELECT * FROM  INFORMATION_SCHEMA.TABLES;

-- Explore All Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

-- Explore all columns in a specific Table in a Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';