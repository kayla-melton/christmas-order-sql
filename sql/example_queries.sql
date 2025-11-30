/* ============================================================
   05_example_queries.sql
   Purpose:
     - Example analytics queries for the Christmas Order project
   ============================================================ */

USE christmas_orders;

-- 1. Total items ordered by item_name
SELECT
    i.item_name,
    SUM(co.quantity) AS total_quantity
FROM christmas_order co
JOIN item i ON i.item_id = co.item_id
GROUP BY i.item_name
ORDER BY total_quantity DESC;


-- 2. Orders by city
SELECT
    a.city,
    COUNT(DISTINCT co.order_id) AS num_orders,
    SUM(co.quantity)            AS total_items
FROM christmas_order co
JOIN address a ON a.add_id = co.add_id
GROUP BY a.city
ORDER BY num_orders DESC;


-- 3. Items fulfilled per shopping trip
SELECT
    st.trip_id,
    st.trip_date,
    st.store_name,
    COUNT(DISTINCT co.order_id)    AS orders_fulfilled,
    SUM(co.quantity)               AS items_fulfilled
FROM christmas_order co
LEFT JOIN shopping_trip st
    ON st.trip_id = co.trip_id
GROUP BY st.trip_id, st.trip_date, st.store_name
ORDER BY st.trip_date, st.store_name;


-- 4. Top customers by items received
SELECT
    c.cust_firstname,
    c.cust_lastname,
    COUNT(DISTINCT co.order_id) AS num_orders,
    SUM(co.quantity)            AS total_items
FROM christmas_order co
JOIN customers c ON c.cust_id = co.cust_id
GROUP BY c.cust_id, c.cust_firstname, c.cust_lastname
ORDER BY total_items DESC;