/* ============================================================
   04_stage_to_christmas_order.sql
   Purpose:
     - Insert order line items into christmas_order
       using IDs from customers, address, item, shopping_trip
     - Idempotent via UNIQUE(order_id, item_id, add_id)
   ============================================================ */

USE christmas_orders;

-- ------------------------------------------------------------
-- Insert from stage into christmas_order
-- ------------------------------------------------------------
INSERT IGNORE INTO christmas_order (
    order_id,
    created_at,
    cust_id,
    add_id,
    delivery,
    trip_id,
    item_id,
    item_price,
    quantity
)
SELECT
    s.order_id,
    s.created_at,

    c.cust_id,
    a.add_id,
    s.delivery,

    st.trip_id,

    i.item_id,
    s.item_price,
    COALESCE(s.quantity, 1)
FROM stage s
LEFT JOIN customers c
    ON c.cust_firstname = s.cust_firstname
   AND c.cust_lastname  = s.cust_lastname
LEFT JOIN address a
    ON a.address1 = s.address1
   AND a.city     = s.city
   AND a.zipcode  = s.zipcode
LEFT JOIN item i
    ON i.item_name = s.item_name
   AND i.item_size = s.item_size
LEFT JOIN shopping_trip st
    ON st.trip_date      = s.trip_date
   AND st.store_name     = s.store_name
   AND st.payment_method = s.payment_method
WHERE s.order_id IS NOT NULL
  AND s.item_name IS NOT NULL
  AND s.item_size IS NOT NULL;