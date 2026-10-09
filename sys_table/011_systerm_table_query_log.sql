

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

/*
read_rows: rows read by the query.
read_size: bytes read, displayed in a human-readable format.
result_rows: rows returned by the query.
query_duration_ms: execution time in milliseconds.
projections: projection information recorded in the query log, where supported by your version.
*/