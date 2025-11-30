/* ============================================================
   02_seed_items.sql
   Purpose:
     - Seed the item table with a small reference list
   ============================================================ */

USE christmas_orders;

INSERT INTO item (item_name, item_cat, item_size, unit_price)
VALUES
  ('side_rice',              'food',     'standard',   5.00),
  ('side_rice',              'food',     'family_xl',  8.00),
  ('side_collard_greens',    'food',     'family_xl',  7.00),
  ('side_black_eyed_peas',   'food',     'standard',   6.00),
  ('side_pinto_beans',       'food',     'standard',   6.00),
  ('side_cabbage',           'food',     'family_xl',  7.00),
  ('side_mixed_veggies',     'food',     'standard',   5.00),
  ('shoes',                  'clothing', 'boy_5_5',   25.00),
  ('hygiene_kit',            'hygiene',  'infant',    10.00)
ON DUPLICATE KEY UPDATE
  item_cat   = VALUES(item_cat),
  item_size  = VALUES(item_size),
  unit_price = VALUES(unit_price);