# Christmas Order SQL Project 🎄

![Status](https://img.shields.io/badge/Status-Portfolio%20Ready-brightgreen)
![MySQL](https://img.shields.io/badge/SQL-MySQL-blue?logo=mysql&logoColor=white)
![Workbench](https://img.shields.io/badge/Tool-MySQL%20Workbench-informational)
![Focus](https://img.shields.io/badge/Focus-Data%20Engineering-yellow)
![License](https://img.shields.io/badge/License-Personal%20Portfolio-lightgrey)

A **relational SQL project** built around a fictional _Christmas Orders_ workflow.  
This repo shows how to:

- Design a **normalized schema** for customers, addresses, orders, items, trips, and inventory  
- Use a **staging table** to safely import messy CSV data  
- Build a **repeatable ETL pipeline** from `christmas_order_stage` into clean target tables  
- Track **shopping trips** and **inventory receipts** alongside orders  
- Run **analysis queries** to answer real-world questions about demand, cost, and order patterns  

This project is designed as a **portfolio piece** to demonstrate SQL skills using MySQL + MySQL Workbench.

---

## 📚 Table of Contents

1. [Project Overview](#project-overview)
2. [Business Context](#business-context)
3. [Tech Stack](#tech-stack)
4. [Folder Structure](#folder-structure)
5. [ERD (Entity Relationship Diagram)](#erd-entity-relationship-diagram)
6. [Database Schema & Tables](#database-schema--tables)
7. [Data Flow & ETL Pipeline](#data-flow--etl-pipeline)
8. [How to Run This Project](#how-to-run-this-project)
9. [Example Analysis Questions](#example-analysis-questions)
10. [Contact](#contact)

---

## 📝 Project Overview

Many community organizations run **holiday donation programs** where volunteers shop for families, purchase items, and deliver them as Christmas orders.  
This project simulates that process and focuses on the **data infrastructure** behind it:

- Each **family order** lists the items they receive (food, clothing, hygiene kits, etc.).
- Volunteers complete **shopping trips** at stores like CVS, Costco, and Sam’s Club.
- Each trip has a payment method, total spent, and a note explaining the purpose (e.g. “Weekly run”, “Gift drive”, “Holiday restock”).
- Data is collected first in Excel/CSV and then loaded into MySQL through a **staging table**.
- From there, SQL scripts clean, de-duplicate, and load data into a **normalized schema**.

This repo shows the **full SQL side** of that story: tables, pipeline scripts, and example queries.

---

## 🧩 Business Context

This project is built to answer questions that a real stakeholder might ask, such as:

- _“How many items did we deliver per family?”_  
- _“Which cities received the most orders?”_  
- _“Which items are most in demand?”_  
- _“How much did we spend per shopping trip or store?”_  
- _“Are we overspending on certain categories or sizes?”_  

By separating raw data (staging) from clean, relational tables, we can:

- Safely re-run imports  
- Preserve data quality  
- Support repeatable reporting and analytics  

---

## 🛠 Tech Stack

- **Database:** MySQL  
- **Tooling:** MySQL Workbench (schema design, ERD, queries)  
- **Data source:** CSV files (Excel exports)  
- **Focus areas:**
  - Schema design & normalization  
  - ETL pipelines (`christmas_order_stage` → target tables)  
  - Data cleaning & de-duplication  
  - Basic analytics queries (GROUP BY, JOINs, aggregates)

---

## 📁 Folder Structure

Below is a representation of the folder structure:

```text
.
├─ data/
│  └─ christmas_orders_sample.csv     # small, anonymized example dataset
│
├─ erd/
│  └─ christmas_orders_erd.png        # exported ER diagram from MySQL Workbench
│
├─ sql/
│  ├─ 01_schema.sql                   # creates all tables in the christmas_orders database
│  ├─ 02_seed_items.sql               # optional: seeds item reference data
│  ├─ 03_stage_to_dimensions.sql      # loads customers, address, item, shopping_trip from stage
│  ├─ 04_stage_to_christmas_order.sql # loads the main christmas_order fact table
│  └─ 05_example_queries.sql          # example analysis queries
│
└─ README.md                          # you are here 😊👋

```
--- 

## 🗺 ERD (Entity Relationship Diagram)

The ERD for this project lives nice and cozy here: 👉 [ERD Diagram](erd/christmas_orders_erd.png).

At a high level, it shows:

- **customers** connected to **christmas_order**
- **address** connected to **christmas_order**
- **item** connected to **christmas_order** and **trip_item**
- **shopping_trip** connected to **trip_item**
- **trip_item** connected to **inventory_receipt**
- **christmas_order_stage** as a staging table feeding the others

Open the ERD image to see how all tables relate visually.

---

## 🗄 Database Schema & Tables

The project uses a **normalized schema** centered around the `christmas_orders` database.  
Here’s a summary of each core table in plain English.

---

### 👨‍👩‍👧 `customers`

One row per **customer/recipient household**.

**Key columns:**

- `cust_id` – primary key  
- `cust_firstname`, `cust_lastname` – recipient name  
- `created_at` – when the customer record was created  

Used to answer: _“How many orders did each family receive?”_

---

### 📫 `address`

One row per **delivery address**.

**Key columns:**

- `add_id` – primary key  
- `address1`, `address2` – street address  
- `city`, `zipcode` – location fields  
- `created_at` – when the address record was created  

Used to answer: _“Which cities or ZIP codes received the most orders?”_

---

### 🎁 `item`

One row per **unique item + size combination**.

**Key columns (adapted to this project):**

- `item_id` – primary key  
- `item_name` – e.g. `side_rice`, `shoes`, `hygiene_kit`  
- `item_cat` – high-level category like `food`, `clothing`, `hygiene`  
- `item_size` – size or variant (e.g. `standard`, `family_xl`, `boy_5_5`)  
- `item_price` – price for that item/size combination  

This supports consistent item tracking and avoids having to repeat raw text in every order row.

---

### 🛒 `shopping_trip`

One row per **shopping trip** to a store.

**Key columns (matching the dataset shown):**

- `trip_id` – primary key  
- `store_name` – e.g. `CVS`, `Costco`, `Sam's Club`  
- `trip_date` – date/time of the trip  
- `payment_method` – e.g. `CC`, `DB`, `cash`  
- `total_spent` – total amount spent on that trip  
- `note` – descriptive note like `Weekly run`, `Gift drive`, `Holiday restock`

Used to answer:  
- _“How much do we spend per store?”_  
- _“Which trips were for gift drives vs weekly restocks?”_

---

### 📦 `christmas_order`

One row per **line item on an order**  
(i.e. this is the main **fact table**).

**Key columns:**

- `row_id` – primary key (surrogate key)  
- `order_id` – order identifier from the original file  
- `created_at` – datetime when the order was created  
- `cust_id` – FK → `customers.cust_id`  
- `add_id` – FK → `address.add_id`  
- `delivery` – whether this order is for delivery (vs pickup)  
- `item_id` – FK → `item.item_id`  
- `item_price` – price at the time of the order  
- `quantity` – number of units of that item on this order  

There is also a **UNIQUE constraint** on:

- `(order_id, item_id, add_id)`

This prevents duplicate rows for the same order + item + address and makes the ETL idempotent.

---

### 🧾 `christmas_order_stage`

The **staging table**, used as a landing zone for raw CSV/Excel imports.  
This table mirrors the structure of the raw file as closely as possible, including text fields.

**Key columns (representative):**

- `stage_id` – primary key  
- `order_id`, `created_at` – raw order fields  
- `item_name`, `item_cat`, `item_size`, `item_price`, `quantity`, `delivery`  
- `cust_firstname`, `cust_lastname`  
- `address1`, `address2`, `city`, `zipcode`  
- `trip_date`, `store_name`, `payment_method`, `note` (if captured from the trip file)

No foreign keys are enforced here on purpose.  
This keeps the staging area flexible and forgiving while the data is being cleaned.

---

### 📊 `trip_item`

One row per **item purchased on a shopping trip** (optional advanced tracking).

Typical columns:

- `row_id` – primary key  
- `trip_id` – FK → `shopping_trip.trip_id`  
- `item_id` – FK → `item.item_id`  
- `quantity` – how many units bought on that trip  
- `unit_price` – cost details  

This table connects store purchase behavior to items.

---

### 📦 `inventory_receipt`

Tracks **when items are received into inventory**, linked to `trip_item`.

Typical columns:

- `receipt_id` – primary key  
- `item_id` – FK → `trip_item.item_id`  
- `received_date`
- `received_qty`
- `source`  
- `notes`  

This supports more advanced inventory workflows, such as tracking how items flow from store → inventory → orders.

---

## 🔄 Data Flow & ETL Pipeline

This project uses a **stage → dimension → fact** pattern.

High-level flow:

1. **Load raw data into `christmas_order_stage`**
   - Import CSV/Excel exports using MySQL Workbench.
   - No constraints here; it’s just a safe landing zone.

2. **Populate dimension tables** (`customers`, `address`, `item`, `shopping_trip`)
   - Use [stage_to_dimensions.sql](sql/stage_to_dimensions.sql) to:
     - `INSERT IGNORE` distinct customers from `cust_firstname`, `cust_lastname`
     - `INSERT IGNORE` distinct addresses from `address1`, `city`, `zipcode`
     - `INSERT IGNORE` items from `item_name`, `item_size` (and `item_cat`, `item_price`)
     - `INSERT IGNORE` shopping trips from `trip_date`, `store_name`, `payment_method`, etc.

3. **Populate the main fact table** (`christmas_order`)
   - Use [stage_to_christmas_order.sql](sql/stage_to_christmas_order.sql) to:
     - Join `christmas_order_stage` to `customers`, `address`, and `item` using cleaned keys
     - Insert one row per order line into `christmas_order`
     - Respect the `UNIQUE(order_id, item_id, add_id)` constraint so you can re-run the script without creating duplicates (`INSERT IGNORE` pattern).

4. **(Optional) Populate `trip_item` and `inventory_receipt`**
   - These can be loaded from separate trip-level or inventory files, or derived from the same source data if your design supports it.

This approach keeps the pipeline:

- **Repeatable** – you can reload from staging as needed  
- **Safe** – target tables are protected by constraints  
- **Clean** – dimension tables hold the “master” records for customers, addresses, items, and trips

- ## 🧪 How to Run This Project

### 1️⃣ Create the database & tables

1. Open **MySQL Workbench**.
2. Connect to your MySQL instance.
3. Open [schema.sql](sql/schema.sql).
4. Run the script (lightning bolt) to create the `christmas_orders` database and all tables.

### 2️⃣ (Optional) Seed item reference data

1. Open [seed_items.sql](sql/seed_items.sql).
2. Run the script to insert sample `item` rows.

### 3️⃣ Load sample data into `christmas_order_stage`

1. Open the `christmas_orders_sample.csv` file from the `data/` folder in Excel to preview.
2. In MySQL Workbench, use:
   - **Server → Data Import** or
   - `Table Data Import Wizard`
3. Choose `christmas_order_stage` as the target table.
4. Map CSV columns to table columns and complete the import.

### 4️⃣ Populate dimensions (customers, address, item, shopping_trip)

1. Open [stage_to_dimensions.sql](sql/stage_to_dimensions.sql).
2. Run the script to upsert records into:
   - `customers`
   - `address`
   - `item`
   - `shopping_trip`

### 5️⃣ Populate the main fact table (christmas_order)

1. Open [stage_to_christmas_order.sql](sql/stage_to_christmas_order.sql)
.
2. Run the script.
3. Check that `christmas_order` now contains one row per order + item combination.

You can re-run steps 4–5 safely if:

- You keep using `INSERT IGNORE` and
- Maintain the unique keys (e.g. `UNIQUE(order_id, item_id, add_id)`)

---

## 📊 Example Analysis Questions

The file [example_queries.sql](sql/example_queries.sql) contains sample queries such as:

- **Top items by quantity ordered**

  - See which items are most requested by families.

- **Orders by city or ZIP code**

  - Analyze demand by geography.

- **Total items delivered per customer**

  - Identify heavy-recipient households or households with multiple orders.

- **Spending per shopping trip**

  - Combine `shopping_trip` and (optionally) `trip_item` to see where money is going.

You can also extend this with your own analysis, for example:

- _“Which store gives the best value per dollar spent?”_  
- _“What is the average cost per order?”_  
- _“How do ‘Gift drive’ trips compare to ‘Weekly run’ trips?”_

---

## 🚀 How This Fits in a Portfolio

This project showcases:

- **SQL fundamentals**
  - SELECTs, JOINs, GROUP BY, aggregates
- **Schema design**
  - Normalized tables, primary/foreign keys, unique constraints
- **Data engineering thinking**
  - Staging vs target tables
  - Idempotent loading patterns (safe re-runs)


## 📬 Contact

If you'd like to discuss this project or collaborate:

**Kayla Melton**  
📧 Email: kaylamelton22@icloud.com  
💼 LinkedIn: https://www.linkedin.com/in/jakayla-melton-001a782bb/  
🗂️ GitHub: https://github.com/kayla-melton  

---

## ⭐ If this project helped you…  
Please consider giving the repo a **star**! ⭐
