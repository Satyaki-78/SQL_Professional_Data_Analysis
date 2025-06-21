-- Explore all countries the customers come from

SELECT DISTINCT country from gold.dim_customers;


-- Explore all categories "The Major Divisions"

SELECT DISTINCT category from gold.dim_products;


-- Explore all categories and the subcategory "Specific Categorization"
SELECT DISTINCT category, subcategory from gold.dim_products;


-- select count(*) as Total_Rows from gold.dim_products;


-- Exploring how many subcategories does each 'category' have

SELECT category, count(distinct subcategory) as No_of_Subcategories from gold.dim_products group by category;


-- Explore all categories, subcategory and product name "The Detailed Division"

SELECT DISTINCT category, subcategory, product_name from gold.dim_products


-- Exploring how many different products are there under subcategory of a category

SELECT category, subcategory, COUNT(DISTINCT product_name) AS No_of_Products 
FROM gold.dim_products 
GROUP BY category, subcategory
ORDER BY 1,2;

-- select category, subcategory, product_name from gold.dim_products order by category;