/* ============================================================
   03_stage_to_dimensions.sql
   Purpose:
     - Load / update dimension tables from the stage table:
       customers, address, item, shopping_trip
   ============================================================ */

USE christmas_orders;

-- ------------------------------------------------------------
-- Cleanup on stage (trim spaces)
-- ------------------------------------------------------------
UPDATE stage
SET
    cust_firstname = TRIM(cust_firstname),
    cust_lastname  = TRIM(cust_lastname),
    address1       = TRIM(address1),
    address2       = TRIM(address2),
    city           = TRIM(city),
    zipcode        = TRIM(zipcode),
    item_name      = TRIM(item_name),
    item_cat       = TRIM(item_cat),
    item_size      = TRIM(item_size),
    store_name     = TRIM(store_name),
    shopper_name   = TRIM(shopper_name),
    payment_method = TRIM(payment_method);


-- ------------------------------------------------------------
-- 1. Upsert Customers
--    (one row per unique first + last name)
-- ------------------------------------------------------------
INSERT IGNORE INTO customers (cust_firstname, cust_lastname)
SELECT DISTINCT
    s.cust_firstname,
    s.cust_lastname
FROM stage s
WHERE s.cust_firstname IS NOT NULL
  AND s.cust_lastname  IS NOT NULL;


-- ------------------------------------------------------------
-- 2. Upsert Address
--    (one row per unique address1 + city + zipcode)
-- ------------------------------------------------------------
INSERT IGNORE INTO address (address1, address2, city, zipcode)
SELECT DISTINCT
    s.address1,
    s.address2,
    s.city,
    s.zipcode
FROM stage s
WHERE s.address1 IS NOT NULL
  AND s.city     IS NOT NULL
  AND s.zipcode  IS NOT NULL;


-- ------------------------------------------------------------
-- 3. Upsert Item
--    (one row per unique item_name + item_size)
-- ------------------------------------------------------------
INSERT IGNORE INTO item (item_name, item_cat, item_size, unit_price)
SELECT DISTINCT
    s.item_name,
    s.item_cat,
    s.item_size,
    s.item_price      -- using price from stage as unit_price
FROM stage s
WHERE s.item_name IS NOT NULL
  AND s.item_size IS NOT NULL;


-- ------------------------------------------------------------
-- 4. Upsert Shopping Trip
--    (one row per unique trip_date + store_name + payment_method)
-- ------------------------------------------------------------
INSERT IGNORE INTO shopping_trip (trip_date, shopper_name, store_name, payment_method)
SELECT DISTINCT
    s.trip_date,
    s.shopper_name,
    s.store_name,
    s.payment_method
FROM stage s
WHERE s.trip_date IS NOT NULL;