
/*
It shows you what the system is doing behind the scenes, 
specifically merges (combining small data parts into larger,
more efficient ones) and part mutations
(like ALTER TABLE ... UPDATE or DELETE)
*/


--This is particularly useful for identifying merge processes 
--that are taking an unusually long time, 
--which could be a sign of a performance bottleneck
SELECT
    database,
    table,
    elapsed,
    progress,
    is_mutation,
    total_size_bytes_compressed
FROM system.merges
ORDER BY elapsed DESC;

