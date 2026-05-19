--===========================================================
-- >> Part-to-Whole 
--===========================================================
-- Which categories contribute the most to overall sales?

WITH category_sales AS (
SELECT
p.category,
SUM(f.sales_amount) category_total_sales
--SUM(SUM(f.sales_amount)) OVER() AS overall_sales,
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON		f.product_key = p.product_key
GROUP BY p.category
)

SELECT 
category,
category_total_sales,
SUM(category_total_sales) OVER() AS overall_sales,
CONCAT(ROUND((CAST(category_total_sales AS FLOAT) / SUM(category_total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY category_total_sales DESC

--===========================================================
-- >> Segmentation
--===========================================================
/* Segment products into cost ranges and count how many products fall into each segment */
WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products
)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/* Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than 5000.
	- Regular: Customers with at least 12 months of history but spending 5000 or less.
	- New: Customers with a lifspan less than 12 months.
   And find the total number os customers by each group
*/
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP' 
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment,
COUNT(customer_key) AS total_customer_count
FROM customer_spending
GROUP BY (CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP' 
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END) 


-- if don't want to use the case twice
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT
customer_segment,
COUNT(customer_key) as total_customers
FROM(
	SELECT
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP' 
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment
	FROM customer_spending
)t 
GROUP BY customer_segment
ORDER BY total_customers
