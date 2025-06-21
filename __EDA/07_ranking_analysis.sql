-- Which 5 products generate the highest revenue ?
SELECT * from gold.dim_products;
SELECT * from gold.fact_sales;

SELECT TOP 5
p.product_key,
p.product_name,
p.category,
SUM(sales_amount) revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY 
p.product_key, 
p.product_name,
p.category
ORDER BY revenue DESC;

-- What are the 5 worst-performing products in terms of sales ?
SELECT TOP 5
p.product_key,
p.product_name,
p.category,
SUM(sales_amount) revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY 
p.product_key, 
p.product_name,
p.category
ORDER BY revenue ASC;

SELECT *
FROM (
	SELECT 
	p.product_name,
	SUM(f.sales_amount) revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount)) AS product_rank
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY  
	p.product_name) s
WHERE product_rank <= 5;


-- Find top 10 customers who have generated the highest revenue
SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(sales_amount) revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.product_key = c.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY revenue DESC;

-- The 3 customers with fewest orders placed
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders;