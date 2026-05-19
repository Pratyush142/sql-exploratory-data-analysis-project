--===========================================================
-- >> Date Exploration
--===========================================================
-- Identify the earlies and latest dates (boundaries).

-- Find the date of the first and the last order
-- How many years of sales are available
SELECT 
MIN(order_date) first_order_date, 
MAX(order_date) last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) order_range_years
FROM gold.fact_sales

-- Find the youngest and the oldest customer
SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) as oldest_age,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) as youngest_srhage
FROM gold.dim_customers
