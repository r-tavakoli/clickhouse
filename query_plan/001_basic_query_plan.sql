--Partition pruning
--↓
--Primary index pruning
--↓
--PREWHERE
--↓
--Read remaining columns

EXPLAIN
SELECT *
FROM test_db.orders
WHERE country = 'US';

--explain                                                                                                             |
----------------------------------------------------------------------------------------------------------------------+
--Output: order_id, customer_id, order_date, product_id, category, quantity, price, country, payment_method, status   |
--                                                                                                                    |
--ReadFromMergeTree (test_db.orders)                                                                                  |
--   Read type: Default                                                                                               |
--   Parts: 36 | Granules: 1233                                                                                       |
--   Output: country, order_id, customer_id, order_date, product_id, category, quantity, price, payment_method, status|
--   Prewhere filter                                                                                                  |
--   Prewhere filter column:  country = 'US'                                                                          |

EXPLAIN
SELECT *
FROM test_db.orders
WHERE order_date >= today() - 30;

--explain                                                                                                             |
----------------------------------------------------------------------------------------------------------------------+
--Output: order_id, customer_id, order_date, product_id, category, quantity, price, country, payment_method, status   |
--                                                                                                                    |
--ReadFromMergeTree (test_db.orders)                                                                                  |
--   Read type: Default                                                                                               |
--   Parts: 1 | Granules: 24                                                                                          |
--   Output: order_date, order_id, customer_id, product_id, category, quantity, price, country, payment_method, status|
--   Prewhere filter                                                                                                  |
--   Prewhere filter column:  order_date >= '2026-07-08'                                                              |

--prewhere: (Much less disk I/O)
--Read only order_date
--        ↓
--Apply filter
--        ↓
--Determine matching rows
--        ↓
--Read the remaining columns
   
   
   
