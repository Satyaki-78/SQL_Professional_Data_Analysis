
-- Exploring date columns in 'fact_sales' table


-- Find the date of the 'first' and 'last' order
SELECT 
MIN(order_date) First_Order_Date,
MAX(order_date) Last_Order_Date 
FROM gold.fact_sales;

-- How many years of sales are available
SELECT 
MIN(order_date) First_Order_Date,
MAX(order_date) Last_Order_Date,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS Order_Range_Years
FROM gold.fact_sales;

-- Find the youngest and oldest customer
SELECT 
DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS Youngest_Customer_Age,
DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS Oldest_Customer_Age
FROM gold.dim_customers;
