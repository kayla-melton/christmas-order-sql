/* ============================================================
   CHRISTMAS ORDER PROJECT — SCHEMA
   Tables:
     - customers
     - address
     - item
     - shopping_trip
     - christmas_order
     - christmas_order_stage (staging table)
     - trip_item
     - inventory_receipt
   ============================================================ */

-- ------------------------------------------------------------
-- 0. Create / select database
-- ------------------------------------------------------------
DROP DATABASE IF EXISTS christmas_orders;
CREATE DATABASE christmas_orders;
USE christmas_orders;

-- ------------------------------------------------------------
-- 1. Customers
-- ------------------------------------------------------------
CREATE TABLE `customers` (
  `cust_id` int NOT NULL AUTO_INCREMENT,
  `cust_firstname` varchar(25) NOT NULL,
  `cust_lastname` varchar(25) NOT NULL,
  PRIMARY KEY (`cust_id`),
  UNIQUE KEY `u_customer_name` (`cust_firstname`,`cust_lastname`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 2. Address
-- ------------------------------------------------------------
CREATE TABLE `address` (
  `add_id` int NOT NULL AUTO_INCREMENT,
  `delivery_address1` varchar(100) NOT NULL,
  `delivery_address2` varchar(100) DEFAULT NULL,
  `delivery_city` varchar(60) NOT NULL,
  `delivery_zipcode` varchar(20) NOT NULL,
  PRIMARY KEY (`add_id`),
  UNIQUE KEY `u_address` (`delivery_address1`,`delivery_city`,`delivery_zipcode`)
) ENGINE=InnoDB AUTO_INCREMENT=274 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- ------------------------------------------------------------
-- 3. Item
-- ------------------------------------------------------------
CREATE TABLE `item` (
  `item_id` varchar(10) NOT NULL,
  `sku` varchar(30) NOT NULL,
  `item_name` varchar(120) NOT NULL,
  `item_cat` varchar(60) NOT NULL,
  `item_size` varchar(40) DEFAULT NULL,
  `item_price` decimal(10,2) DEFAULT NULL,
  `item_name_norm` varchar(255) DEFAULT NULL,
  `item_size_norm` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uq_item_name_size` (`item_name_norm`,`item_size_norm`),
  KEY `idx_item_sku` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 4. Shopping Trip (one row per store visit)
-- ------------------------------------------------------------
CREATE TABLE `shopping_trip` (
  `trip_id` int NOT NULL AUTO_INCREMENT,
  `trip_date` datetime NOT NULL,
  `store_name` varchar(100) DEFAULT NULL,
  `payment_method` varchar(30) DEFAULT NULL,
  `total_spent` decimal(10,2) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`trip_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14025 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- ------------------------------------------------------------
-- 5. Christmas Order (one row per item on an order)
-- ------------------------------------------------------------
CREATE TABLE `christmas_order` (
  `row_id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(25) NOT NULL,
  `item_id` varchar(10) NOT NULL,
  `quantity` int NOT NULL,
  `cust_id` int NOT NULL,
  `delivery` tinyint(1) NOT NULL DEFAULT '0',
  `add_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`row_id`),
  UNIQUE KEY `uq_order_line` (`order_id`,`item_id`,`add_id`),
  KEY `item_id` (`item_id`),
  KEY `cust_id` (`cust_id`),
  KEY `add_id` (`add_id`),
  CONSTRAINT `christmas_order_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `christmas_order_ibfk_2` FOREIGN KEY (`cust_id`) REFERENCES `customers` (`cust_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `christmas_order_ibfk_3` FOREIGN KEY (`add_id`) REFERENCES `address` (`add_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_delivery_bool` CHECK ((`delivery` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=1087 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 6. Staging table: raw CSV import
--    (your existing 'stage' table)
-- ------------------------------------------------------------
CREATE TABLE `christmas_order_stage` (
  `row_id` int DEFAULT NULL,
  `order_id` varchar(25) DEFAULT NULL,
  `item_id` varchar(10) DEFAULT NULL,
  `item_name` varchar(120) DEFAULT NULL,
  `item_cat` varchar(60) DEFAULT NULL,
  `item_size` varchar(40) DEFAULT NULL,
  `item_price` varchar(64) DEFAULT NULL,
  `quantity` varchar(20) DEFAULT NULL,
  `delivery` varchar(10) DEFAULT NULL,
  `cust_firstname` varchar(25) DEFAULT NULL,
  `cust_lastname` varchar(25) DEFAULT NULL,
  `delivery_address1` varchar(100) DEFAULT NULL,
  `delivery_address2` varchar(100) DEFAULT NULL,
  `delivery_city` varchar(60) DEFAULT NULL,
  `delivery_zipcode` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `item_name_norm` varchar(255) DEFAULT NULL,
  `item_size_norm` varchar(255) DEFAULT NULL,
  `cust_id` int DEFAULT NULL,
  `add_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 7. Trip Item (what was bought on each shopping trip)
--    one row per item purchased on a trip
-- ------------------------------------------------------------
CREATE TABLE `trip_item` (
  `row_id` int NOT NULL AUTO_INCREMENT,
  `trip_id` int NOT NULL,
  `item_id` varchar(10) NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`row_id`),
  KEY `trip_id` (`trip_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `trip_item_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `shopping_trip` (`trip_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `trip_item_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 8. Inventory Receipt (when items are received into inventory)
--    can tie back to trip_item if you want detailed tracking
-- ------------------------------------------------------------
CREATE TABLE `inventory_receipt` (
  `receipt_id` int NOT NULL AUTO_INCREMENT,
  `item_id` varchar(10) NOT NULL,
  `received_date` datetime NOT NULL,
  `received_qty` int NOT NULL DEFAULT '0',
  `source` varchar(100) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`receipt_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `inventory_receipt_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------

