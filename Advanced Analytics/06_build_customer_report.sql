/*
====================================================================================
Customer Report
====================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviours

Highlights:
	1. Gather essential fields such as names, ages and transactional details
	2. Segments customers into categories (VIP, Regular, New) and age groups
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
====================================================================================
*/

/*
-------------------------------------------------------
(1) - Base Query: Retrieves core columns from tables
-------------------------------------------------------
*/
CREATE VIEW gold.report_customers AS -- Creating a view as a final step to give data for other teams
WITH base_query AS (
	SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) age,
	c.birthdate
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	WHERE order_date IS NOT NULL
)

/*
SELECT 
*
FROM base_query
*/

/*
-------------------------------------------------------
(2) - Aggregation
-------------------------------------------------------
*/
, customer_aggregation AS (
	SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)
/*
-------------------------------------------------------
(2) - Final Result
-------------------------------------------------------
*/
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and Above'
END age_group,
CASE
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compute Avergae Order Value (AVO)
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Compute average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation