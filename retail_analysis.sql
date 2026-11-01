-- Retail Sales Analysis | MySQL 8+
-- Load data into a table named retail_sales.
-- Example import: use MySQL Workbench Table Data Import Wizard.

CREATE DATABASE IF NOT EXISTS retail_analysis;
USE retail_analysis;

CREATE TABLE IF NOT EXISTS retail_sales (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE NOT NULL,
    region VARCHAR(30) NOT NULL,
    category VARCHAR(50) NOT NULL,
    product VARCHAR(80) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_pct DECIMAL(5,2) NOT NULL,
    revenue DECIMAL(14,2) NOT NULL,
    cost DECIMAL(14,2) NOT NULL,
    profit DECIMAL(14,2) NOT NULL
);

-- 1. Overall business KPIs
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct
FROM retail_sales;

-- 2. Monthly revenue and profit trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM retail_sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

-- 3. Category performance
SELECT
    category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS margin_pct
FROM retail_sales
GROUP BY category
ORDER BY revenue DESC;

-- 4. Regional performance
SELECT
    region,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM retail_sales
GROUP BY region
ORDER BY revenue DESC;

-- 5. Top 10 products by revenue
SELECT
    product,
    category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(revenue), 2) AS revenue
FROM retail_sales
GROUP BY product, category
ORDER BY revenue DESC
LIMIT 10;

-- 6. Discount analysis
SELECT
    CASE
        WHEN discount_pct = 0 THEN 'No discount'
        WHEN discount_pct <= 5 THEN '1-5%'
        WHEN discount_pct <= 10 THEN '6-10%'
        WHEN discount_pct <= 15 THEN '11-15%'
        ELSE '16-20%'
    END AS discount_band,
    COUNT(*) AS order_lines,
    ROUND(AVG(profit), 2) AS avg_profit,
    ROUND(SUM(revenue), 2) AS revenue
FROM retail_sales
GROUP BY discount_band
ORDER BY MIN(discount_pct);

-- 7. Orders with negative profit (if any)
SELECT order_id, order_date, region, category, product, revenue, cost, profit
FROM retail_sales
WHERE profit < 0
ORDER BY profit ASC;
