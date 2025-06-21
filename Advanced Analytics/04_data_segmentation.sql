/* 
Segment products into cost ranges 
and count how many products fall into each segment
*/

SELECT 
MAX(cost) AS max_cost,
MIN(cost) AS min_cost
FROM gold.dim_products;

WITH product_segments AS (
	SELECT 
		product_key,
		product_name,
		cost,
	CASE
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END cost_range
	FROM gold.dim_products
)

SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- My Question
-- Find the cost range of the top performing product
WITH product_subcategory_segment AS (
	SELECT
	subcategory,
	SUM(sales_amount) AS total_sales,
	SUM(cost) AS total_cost,
	CASE
		WHEN AVG(cost) < 100 THEN 'Below 100'
		WHEN AVG(cost) BETWEEN 100 AND 500 THEN '100-500'
		WHEN AVG(cost) BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END total_cost_range
	FROM
	gold.dim_products p
	LEFT JOIN 
	gold.fact_sales f
	ON p.product_key = f.product_key
	WHERE subcategory IS NOT NULL
	GROUP BY subcategory
)
SELECT 
--subcategory,
--total_cost,
--SUM(total_cost) OVER () AS overall_cost,
max(total_cost) min_total_cost,
min(total_cost) max_total_cost
FROM product_subcategory_segment;


/*
Group customers into three segments based on their spending behaviour:
	- VIP: Customers with at least 12 months of history and spending more that 5000
	- Regular: Customers with at least 12 months of history and spending less that 5000
	- New: Customers with less than 12 months of history
And find the total number of customers in each group
*/
WITH customer_spending AS (
	SELECT
	c.customer_key,
	SUM(f.sales_amount) total_spending,
	MIN(f.order_date) AS first_order,
	MAX(f.order_date) AS lasr_order,
	DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
	SELECT
	customer_key,
	total_spending,
	lifespan,
	CASE
		WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment
	FROM customer_spending 
) s
GROUP BY customer_segment
ORDER BY total_customers DESC;

