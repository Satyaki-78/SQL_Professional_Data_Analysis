use datawarehouseanalytics;

SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;
/*
There are no record where the price column is different than sales_amount column
so that means price and sales_amount columns are identical and therefore one of them is useless
*/
SELECT * FROM gold.fact_sales WHERE DIFFERENCE(sales_amount, price) = 0;


-- Find the Total Sales

SELECT SUM(sales_amount) AS Total_Sales FROM gold.fact_sales;


-- Find how many items are sold

SELECT SUM(quantity) AS Total_Items_Sold FROM gold.fact_sales;


-- Find the average selling price

SELECT AVG(price) AS Avg_Selling_Price FROM gold.fact_sales;


-- Find the Total number of Orders

SELECT COUNT(DISTINCT order_number) AS Total_Orders FROM gold.fact_sales;

SELECT order_number, COUNT(product_key) AS Product_Count_Per_Order
FROM gold.fact_sales 
GROUP BY order_number 
ORDER BY 1,2;


-- Find the Total number of Products

SELECT COUNT(DISTINCT product_name) AS Total_Products
FROM gold.dim_products;


-- Find the Total number of Customers

SELECT COUNT(DISTINCT customer_number) AS Total_Customers
FROM gold.dim_customers;


-- Find the Total number of Customers that has placed an order

SELECT COUNT(DISTINCT customer_key) AS Total_Customers_Who_Ordered
FROM gold.fact_sales;


-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' as Measure_Name, SUM(sales_amount) AS Measure_Value FROM gold.fact_sales
UNION ALL
SELECT 'Total Order Quantity' as Measure_Name, SUM(quantity) AS Measure_Value FROM gold.fact_sales
UNION ALL
SELECT 'Average Order Price' as Measure_Name, AVG(price) AS Measure_Value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' as Measure_Name, COUNT(DISTINCT order_number) AS Measure_Value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' as Measure_Name, COUNT(DISTINCT product_name) AS Measure_Value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' as Measure_Name, COUNT(DISTINCT customer_number) AS Measure_Value FROM gold.dim_customers
UNION ALL
SELECT 'Total Ordering Customers' as Measure_Name, COUNT(DISTINCT customer_key) AS Measure_Value FROM gold.fact_sales;;