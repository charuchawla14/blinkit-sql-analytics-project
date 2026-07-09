
-- =====================================================
-- CUSTOMER ANALYSIS
-- Objective:
-- Analyze customer spending behavior and retention
-- =====================================================

-- 1. Top High-Value Customers
SELECT c.customer_id,
       c.customer_segment,
       ROUND(SUM(o.order_total), 2) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_segment
ORDER BY total_spent DESC
LIMIT 10;


-- 2. Customer Lifetime Value Estimation
SELECT customer_id,
       total_orders,
       ROUND(avg_order_value, 2) AS avg_order_value,
       ROUND((total_orders * avg_order_value), 2) AS estimated_clv
FROM customers
ORDER BY estimated_clv DESC
LIMIT 10;


-- 3. Repeat Customer Analysis
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
ORDER BY total_orders DESC;


-- 4. Revenue Contribution by Customer Segment
SELECT c.customer_segment,
       ROUND(SUM(o.order_total), 2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;


-- 5. Average Order Value by Customer Segment
SELECT c.customer_segment,
       ROUND(AVG(o.order_total), 2) AS avg_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_segment
ORDER BY avg_order_value DESC;


-- =====================================================
-- SALES ANALYSIS
-- =====================================================

-- 6. Total Revenue Generated
SELECT ROUND(SUM(order_total), 2) AS total_revenue
FROM orders;


-- 7. Payment Method Distribution
SELECT payment_method,
       COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;


-- 8. Order Status Analysis
SELECT delivery_status,
       COUNT(*) AS total_orders
FROM orders
GROUP BY delivery_status;


-- 9. Full Business Overview by Category
SELECT 
    p.category,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_sales
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;


-- =====================================================
-- PRODUCT ANALYSIS
-- =====================================================

-- 10. Top Revenue Generating Products
SELECT p.product_name,
       p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;


-- 11. Most Frequently Ordered Products
SELECT p.product_name,
       SUM(oi.quantity) AS total_units_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 10;


-- 12. Category-wise Sales Performance
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_sales
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_sales DESC;


-- 13. Products with Highest Profit Margin
SELECT product_name,
       category,
       dmargin_percentage
FROM products
ORDER BY dmargin_percentage DESC
LIMIT 10;


-- =====================================================
-- DELIVERY ANALYSIS
-- =====================================================

-- 14. Delivery Partner Performance
SELECT delivery_partner_id,
       COUNT(*) AS total_deliveries,
       ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM delivery_performance
GROUP BY delivery_partner_id
ORDER BY total_deliveries DESC;


-- 15. Delivery Efficiency Analysis
SELECT delivery_status,
       ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM delivery_performance
GROUP BY delivery_status;


-- =====================================================
-- ADVANCED BUSINESS ANALYSIS
-- =====================================================

-- 16. Most Valuable Product Categories
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_sales,
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- 17. Customer Purchase Behavior Analysis
SELECT c.customer_segment,
       COUNT(DISTINCT o.customer_id) AS total_customers,
       ROUND(AVG(o.order_total), 2) AS avg_spending
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_segment
ORDER BY avg_spending DESC;


-- 18. Top 10 Orders by Order Value
SELECT order_id,
       customer_id,
       ROUND(order_total, 2) AS order_value
FROM orders
ORDER BY order_total DESC
LIMIT 10;


-- 19. Rank Products by Revenue
SELECT 
       p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
       RANK() OVER(
       ORDER BY SUM(oi.quantity * oi.unit_price) DESC
       ) AS revenue_rank
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name;


-- 20. Orders Above Average Order Value
SELECT order_id,
       customer_id,
       order_total
FROM orders
WHERE order_total >
(
    SELECT AVG(order_total)
    FROM orders
);
