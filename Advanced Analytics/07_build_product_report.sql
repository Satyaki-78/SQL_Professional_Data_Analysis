/*
====================================================================================
Product Report
====================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours

Highlights:
	1. Gather essential fields such as product name, category, subcategory and cost
	2. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	3. Segments products by revenue to identify High-Performers, Mid-Range and Low-Performers
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
====================================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
	SELECT 
	f.order_number,
	f.order_date,
	f.sales_amount,
	f.quantity,
	f.customer_key,
	p.product_key,
	p.product_id,
	p.product_number,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
)
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
, product_aggregation AS (
	SELECT
		product_key,
		product_id,
		product_number,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity_sold,
		COUNT(DISTINCT customer_key) AS total_unique_customers,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
		MAX(order_date) AS last_sale_date,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
	FROM base_query
	GROUP BY
		product_key,
		product_id,
		product_number,
		product_name,
		category,
		subcategory,
		cost
)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	lifespan,
	CASE 
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	total_orders,
	total_sales,
	total_quantity_sold,
	total_unique_customers,
	avg_selling_price,
	-- Computing Average Order Revenue
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END AS avg_order_revenue,

	-- Computing Average Monthly Revenue
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan 
	END AS avg_monthly_revenue

FROM product_aggregation
