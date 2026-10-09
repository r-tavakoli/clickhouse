

/*
Analysts frequently query individual products 
over date ranges. Your source table is ordered by
 (order_date, customer_id), 
and they want to keep using their existing SQL.

Would you choose a Projection or a Materialized View?
What alternative sorting key would you consider?
How would you verify that the change improves performance?

*/

--projection with an alternative sorting key
ALTER TABLE test_db.orders
ADD PROJECTION IF NOT EXISTS projection_by_product
(
    SELECT *
    ORDER BY (product_id, order_date)
);

--materialize the projection for existing data
ALTER TABLE test_db.orders
MATERIALIZE PROJECTION projection_by_product;


--query
SELECT
    product_id,
    order_date,
    count() AS order_count
FROM test_db.orders
WHERE product_id = 100
  AND order_date >= '2026-01-01'
  AND order_date < '2026-02-01'
GROUP BY
    product_id,
    order_date;

--verify
EXPLAIN indexes = 1
SELECT
    product_id,
    order_date,
    count() AS order_count
FROM test_db.orders
WHERE product_id = 100
  AND order_date >= '2026-01-01'
  AND order_date < '2026-02-01'
GROUP BY
    product_id,
    order_date;


--ReadFromMergeTree (projection_by_product) -> shows! plan is using projection

--and less granules is using
--	Parts: 1
--	Granules: 1
--	...
--	Granules: 1/38
/*
1/38 is the number of granules selected by the index, 
not the actual read_rows value. Use EXPLAIN to understand
pruning and system.query_log to measure execution.
 */

/*
explain                                                                                                                          |
---------------------------------------------------------------------------------------------------------------------------------+
Output: product_id, order_date, count()                                                                                          |
                                                                                                                                 |
Aggregating                                                                                                                      |
│  Keys: product_id, order_date                                                                                                  |
│  Aggregates: count()                                                                                                           |
│  Skip merging: 0                                                                                                               |
└──ReadFromMergeTree (projection_by_product)                                                                                     |
      Read type: Default                                                                                                         |
      Parts: 1 | Granules: 1                                                                                                     |
      Output: product_id, order_date                                                                                             |
      Prewhere filter                                                                                                            |
      Prewhere filter column:  product_id = 100 AND order_date >= '2026-01-01' AND order_date < '2026-02-01'                     |
      Indexes:                                                                                                                   |
        PrimaryKey                                                                                                               |
          Keys:                                                                                                                  |
            product_id                                                                                                           |
            order_date                                                                                                           |
          Condition: and((order_date in (-Inf, 1769903999]), and((order_date in [1767225600, +Inf)), (product_id in [100, 100])))|
          Parts: 1/1                                                                                                             |
          Granules: 1/38                                                                                                         |
          Search Algorithm: binary search                                                                                        |
        Ranges: 1                                                                                                                |

*/


--A better way to see the read rows and if plan has used projection or not
SYSTEM FLUSH LOGS;

SELECT
    event_time,
    query_duration_ms,
    read_rows,
    formatReadableSize(read_bytes) AS read_size,
    result_rows,
    query
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query LIKE '%projection_by_product%'
ORDER BY event_time DESC
LIMIT 10;






