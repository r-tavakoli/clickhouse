
--it shows how your MergeTree tables are physically stored

--partition → Partition identifier (empty if the table isn't partitioned)
	--Internally, ClickHouse still stores a partition value for every data part. When there is no partition key, it uses an empty tuple
--rows → Number of rows in each data part
--bytes_on_disk → Disk space used
--active → Whether the part is currently active
	--active = 1 => This data part is currently used for queries. e.x:
	--active = 0 does not mean a partition is unused. It means that specific data part has become obsolete because of a merge
	/*
	 ------------------------
		Part 1
		Part 2
		Part 3
	 ------------------------
		Part 1
		      \
		       ----> Part 123
		      /
		Part 2
		Part 3
	 ------------------------		
		Part 123  active = 1
		Part 3    active = 1
		
		Part 1    active = 0
		Part 2    active = 0
	*/

select
    database,
    table,
    partition,
    rows,
    bytes_on_disk,
    formatReadableSize(bytes_on_disk) as space_used,
    active
from system.parts
where database = 'test_db'
order by table, partition;


select
    table,
    count() AS part_counts,
    sum(rows) AS total_rows,
    formatReadableSize(sum(bytes_on_disk)) AS disk_size
from system.parts
where 
		database = 'test_db'
  AND 	active = 1
group by table;


--Each insert creates one or more immutable data parts. 
--Background merge threads continuously combine smaller parts into larger ones. 
--This design avoids in-place updates, keeps inserts fast, and improves read performance over time.



