-- Run this after creating the table and importing cleaned_ecommerce_orders.csv.
-- PostgreSQL syntax. For MySQL, change DATE_TRUNC expressions to DATE_FORMAT(order_date, '%Y-%m').

CREATE TABLE ecommerce_orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    region VARCHAR(30) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    discount_pct NUMERIC(5,2) NOT NULL,
    payment_mode VARCHAR(40) NOT NULL,
    gross_sales NUMERIC(14,2),
    discount_amount NUMERIC(14,2),
    net_sales NUMERIC(14,2),
    order_month VARCHAR(7)
);

-- 1. Overall KPI summary
SELECT COUNT(DISTINCT order_id) AS total_orders,
       COUNT(DISTINCT customer_id) AS unique_customers,
       SUM(quantity) AS units_sold,
       ROUND(SUM(net_sales),2) AS total_revenue,
       ROUND(AVG(net_sales),2) AS avg_order_value
FROM ecommerce_orders;

-- 2. Monthly revenue trend
SELECT order_month, ROUND(SUM(net_sales),2) AS revenue
FROM ecommerce_orders
GROUP BY order_month
ORDER BY order_month;

-- 3. Category performance
SELECT category, SUM(quantity) AS units_sold,
       ROUND(SUM(net_sales),2) AS revenue
FROM ecommerce_orders
GROUP BY category
ORDER BY revenue DESC;

-- 4. Region performance
SELECT region, ROUND(SUM(net_sales),2) AS revenue
FROM ecommerce_orders
GROUP BY region
ORDER BY revenue DESC;

-- 5. Top 10 customers
SELECT customer_id, COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(net_sales),2) AS lifetime_revenue
FROM ecommerce_orders
GROUP BY customer_id
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- 6. Payment method share
SELECT payment_mode, COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS order_share_pct
FROM ecommerce_orders
GROUP BY payment_mode
ORDER BY orders DESC;

-- 7. Repeat customer analysis
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM ecommerce_orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) x;

-- 8. Average discount by category
SELECT category, ROUND(AVG(discount_pct)*100,2) AS avg_discount_pct,
       ROUND(SUM(discount_amount),2) AS discount_given
FROM ecommerce_orders
GROUP BY category
ORDER BY discount_given DESC;

-- 9. Best-selling products
SELECT product_name, SUM(quantity) AS units_sold,
       ROUND(SUM(net_sales),2) AS revenue
FROM ecommerce_orders
GROUP BY product_name
ORDER BY units_sold DESC
LIMIT 10;

-- 10. Revenue by weekday
SELECT TRIM(TO_CHAR(order_date, 'Day')) AS weekday,
       ROUND(SUM(net_sales),2) AS revenue
FROM ecommerce_orders
GROUP BY TRIM(TO_CHAR(order_date, 'Day'))
ORDER BY revenue DESC;
