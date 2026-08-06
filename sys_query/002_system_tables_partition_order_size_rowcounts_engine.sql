
--engine → Which table engine is being used (MergeTree, ReplacingMergeTree, etc.).
--total_rows → Approximate number of rows.
--size → Total table size.
--partition_key → How the table is partitioned.
--sorting_key → The ORDER BY key.

select
    database,
    name,
    engine,
    total_rows,
    formatReadableSize(total_bytes) as size,
    partition_key,
    sorting_key
from system.tables
where database = 'test_db';