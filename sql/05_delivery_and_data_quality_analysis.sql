-- =====================================================================
-- 05_delivery_and_data_quality_analysis.sql
-- Delivery performance, data quality investigation, and customer
-- revenue concentration analysis for the Blinkit Business Analytics project
-- =====================================================================

USE blinkit_db;

-- ---------------------------------------------------------------------
-- SECTION 1: DATA CLEANING
-- ---------------------------------------------------------------------

-- 1.1 Check for invalid negative delivery times before cleaning
SELECT COUNT(*) AS bad_rows
FROM delivery_performance
WHERE delivery_time_minutes < 0;

-- 1.2 Fix negative delivery times (assumption: sign error, not a
-- meaningful early-delivery offset — documented in README)
SET SQL_SAFE_UPDATES = 0;

UPDATE delivery_performance
SET delivery_time_minutes = ABS(delivery_time_minutes)
WHERE delivery_time_minutes < 0;

SELECT ROW_COUNT();  -- confirms number of rows updated

COMMIT;

-- 1.3 Verify the fix worked
SELECT COUNT(*) AS remaining_bad_rows
FROM delivery_performance
WHERE delivery_time_minutes < 0;


-- ---------------------------------------------------------------------
-- SECTION 2: DATA QUALITY INVESTIGATION — delivery_status vs reasons_if_delayed
-- ---------------------------------------------------------------------

-- 2.1 Full cross-tab of every status + reason combination
-- Reveals: only "Traffic" or blank ever appears as a reason, and some
-- "On Time" orders illogically carry a delay reason
SELECT
    delivery_status,
    CASE WHEN reasons_if_delayed IS NULL OR TRIM(reasons_if_delayed) = ''
         THEN 'BLANK' ELSE reasons_if_delayed END AS reason_clean,
    COUNT(*) AS count
FROM delivery_performance
GROUP BY delivery_status, reason_clean
ORDER BY delivery_status, count DESC;

-- 2.2 Quantify the inconsistency for the README write-up
-- (uses a scalar subquery in the SELECT list to combine two calculations
-- into a single result row)
SELECT
    (SELECT COUNT(*) FROM delivery_performance
     WHERE delivery_status = 'On Time' AND reasons_if_delayed = 'Traffic') AS inconsistent_rows,
    COUNT(*) AS total_rows,
    ROUND(100.0 * (SELECT COUNT(*) FROM delivery_performance
     WHERE delivery_status = 'On Time' AND reasons_if_delayed = 'Traffic') / COUNT(*), 2) AS pct_of_total
FROM delivery_performance;

-- 2.3 Confirm delayed orders always have a reason logged (no reverse gap)
SELECT delivery_status, COUNT(*) AS missing_reason_count
FROM delivery_performance
WHERE (reasons_if_delayed IS NULL OR TRIM(reasons_if_delayed) = '')
  AND delivery_status != 'On Time'
GROUP BY delivery_status;


-- ---------------------------------------------------------------------
-- SECTION 3: OVERALL DELIVERY PERFORMANCE
-- ---------------------------------------------------------------------

-- 3.1 Overall on-time vs delayed percentage
-- Window function (SUM(...) OVER ()) calculates each group's share of
-- the grand total in the same query, without a second pass
SELECT
    delivery_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM delivery_performance
WHERE delivery_time_minutes >= 0
GROUP BY delivery_status;


-- ---------------------------------------------------------------------
-- SECTION 4: DELAY RATE BY DISTANCE BAND
-- ---------------------------------------------------------------------

-- 4.1 Buckets orders into distance bands using CASE WHEN, then computes
-- delay rate per band — tests the assumption that longer distance
-- causes more delays
SELECT
    CASE
        WHEN distance_km < 2 THEN 'Under 2km'
        WHEN distance_km < 5 THEN '2-5km'
        ELSE '5km+'
    END AS distance_band,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN delivery_status != 'On Time' THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(100.0 * SUM(CASE WHEN delivery_status != 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM delivery_performance
WHERE delivery_time_minutes >= 0
GROUP BY distance_band
ORDER BY distance_band;


-- ---------------------------------------------------------------------
-- SECTION 5: DELAY RATE BY TIME OF DAY
-- ---------------------------------------------------------------------

-- 5.1 By hour — STR_TO_DATE converts the text datetime column into a
-- real datetime so HOUR() can extract the hour component
SELECT
    HOUR(STR_TO_DATE(actual_delivery_time, '%d-%m-%Y %H:%i')) AS delivery_hour,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN delivery_status != 'On Time' THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(100.0 * SUM(CASE WHEN delivery_status != 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM orders
GROUP BY HOUR(STR_TO_DATE(actual_delivery_time, '%d-%m-%Y %H:%i'))
ORDER BY delivery_hour;

-- 5.2 By day of week — FIELD() forces calendar order instead of
-- alphabetical sorting in the ORDER BY
SELECT
    DAYNAME(STR_TO_DATE(actual_delivery_time, '%d-%m-%Y %H:%i')) AS delivery_day,
    COUNT(*) AS total_orders,
    ROUND(100.0 * SUM(CASE WHEN delivery_status != 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM orders
GROUP BY DAYNAME(STR_TO_DATE(actual_delivery_time, '%d-%m-%Y %H:%i'))
ORDER BY FIELD(delivery_day, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


-- ---------------------------------------------------------------------
-- SECTION 6: CUSTOMER REVENUE CONCENTRATION
-- ---------------------------------------------------------------------

-- 6.1 Repeat vs one-time customer revenue share
-- CASE WHEN segments customers on the fly; window function again
-- calculates each segment's % share of both customer count and revenue
SELECT
    CASE WHEN total_orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type,
    COUNT(*) AS num_customers,
    SUM(total_orders * avg_order_value) AS total_revenue,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,
    ROUND(100.0 * SUM(total_orders * avg_order_value) / SUM(SUM(total_orders * avg_order_value)) OVER (), 2) AS pct_of_revenue
FROM customers
GROUP BY CASE WHEN total_orders > 1 THEN 'Repeat' ELSE 'One-time' END;


-- ---------------------------------------------------------------------
-- SECTION 7: DELIVERY PERFORMANCE BY CUSTOMER SEGMENT
-- ---------------------------------------------------------------------

-- 7.1 JOIN across orders + customers to check whether higher-value
-- segments (Premium) receive better delivery service than others
SELECT
    c.customer_segment,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_orders,
    ROUND(100.0 * SUM(CASE WHEN o.delivery_status = 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 2) AS on_time_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY on_time_pct DESC;
