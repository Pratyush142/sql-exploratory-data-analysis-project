--===========================================================
-- >> Cumulative Analysis
--===========================================================
-- Calculate the total sales per month
-- And the running total of sales over time.

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date ASC) AS running_total_sales -- Default Frame of the WINDOW Fn is " ROWS/RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW "
FROM (
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t -- This is giving the running total sales for all the months

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ASC) AS running_total_sales -- Default Frame of the WINDOW Fn is " ROWS/RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW "
FROM (
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t -- This is giving the running total sales for all the months of a year

-- moving average
SELECT
order_date,
total_sales,
avg_price,
SUM(total_sales) OVER (ORDER BY order_date ASC) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date ASC) AS moving_average_price
FROM (
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t
