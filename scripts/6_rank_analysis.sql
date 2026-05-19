--===========================================================
-- >> Ranking Analysis
--===========================================================

-- Which 5 Products generate the highest revenue
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- with window fn
SELECT *
FROM (
SELECT
p.product_name,
SUM(f.sales_amount) AS total_revenue,
ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) as rank_products
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
)t WHERE rank_products < 6


-- Which 5 Products generate the lowest revenue
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue

-- Find the Top-10 customers who have generated the highest revenue 
SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

-- 3 customers with the fewest orders placed
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders
