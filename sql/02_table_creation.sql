USE blinkit_db;

-- =====================================================
-- TABLE CREATION
-- =====================================================

-- CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id INT,
    area VARCHAR(100),
    registration_date VARCHAR(50),
    customer_segment VARCHAR(50),
    total_orders INT,
    avg_order_value FLOAT
);


-- PRODUCTS TABLE
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price FLOAT,
    mrp FLOAT,
    dmargin_percentage INT
);


-- ORDERS TABLE
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id INT,
    promised_delivery_time VARCHAR(50),
    actual_delivery_time VARCHAR(50),
    delivery_status VARCHAR(50),
    order_total FLOAT,
    payment_method VARCHAR(50),
    delivery_partner_id BIGINT
);


-- ORDER ITEMS TABLE
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price FLOAT
);


-- DELIVERY PERFORMANCE TABLE
CREATE TABLE delivery_performance (
    order_id INT,
    delivery_partner_id INT,
    distance_km FLOAT,
    delivery_time_minutes INT,
    delivery_status VARCHAR(100),
    reasons_if_delayed VARCHAR(100)
);
