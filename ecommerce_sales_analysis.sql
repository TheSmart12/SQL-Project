-- E-Commerce Sales & Customer Behavior Analysis

-- 1. Month-over-Month Revenue & Orders
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Delivered'
GROUP BY sales_month
ORDER BY sales_month ASC;

-- 2. Top 3 Selling Products Per Category (Window Function)
WITH RankedProducts AS (
    SELECT 
        category,
        product_name,
        SUM(quantity) AS total_units_sold,
        SUM(quantity * unit_price) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(quantity * unit_price) DESC) AS rank_in_category
    FROM order_items
    JOIN orders ON order_items.order_id = orders.order_id
    WHERE orders.status = 'Delivered'
    GROUP BY category, product_name
)
SELECT category, product_name, total_units_sold, total_revenue
FROM RankedProducts
WHERE rank_in_category <= 3;

-- 3. High-Value Repeat Customers
SELECT 
    c.customer_id,
    c.name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.name, c.city
HAVING COUNT(o.order_id) >= 2 AND SUM(o.total_amount) > 5000
ORDER BY lifetime_value DESC;
