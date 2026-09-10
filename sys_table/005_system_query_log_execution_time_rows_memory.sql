
/*
It records information about executed queries, including:

	execution time
	rows read
	bytes read
	memory usage
	which tables were accessed
	query text
	exceptions
 */


select
    event_time,
    query_duration_ms,
    read_rows,
    read_bytes,
    result_rows,
    memory_usage,
    formatReadableSize(memory_usage) as memory_usage_readable,
    query
from system.query_log
where type = 'QueryFinish'
order by event_time desc
limit 20;

--longest query
select
    event_time,
    query_duration_ms,
    case 
    	when query_duration_ms / 1000 >= 1 then formatReadableTimeDelta(query_duration_ms / 1000)   
    	else concat(cast(query_duration_ms as String), ' ms')
    end as execution_time,
    read_rows,
    read_bytes,
    result_rows,
    memory_usage,
    formatReadableSize(memory_usage) as memory_usage_readable,
    query
from system.query_log
where type = 'QueryFinish'
order by query_duration_ms desc
limit 10;


--most rows read
select
    event_time,
    query_duration_ms,
    case 
    	when query_duration_ms / 1000 >= 1 then formatReadableTimeDelta(query_duration_ms / 1000)   
    	else concat(cast(query_duration_ms as String), ' ms')
    end as execution_time,
    read_rows,
    read_bytes,
    result_rows,
    memory_usage,
    formatReadableSize(memory_usage) as memory_usage_readable,
    query
from system.query_log
where type = 'QueryFinish'
order by read_rows desc
limit 10;

--returned few rows but read lots of rows
/*
A 1,000,000× read amplification means your query is reading about a 
million times more data than it needs to. In ClickHouse's columnar storage, 
this usually occurs when the WHERE clause cannot effectively prune data before reading, 
forcing the engine to scan an enormous number of rows and granules and then filter them one-by-one
*/
select
    event_time,
    read_rows,
    result_rows,
    result_rows * 100.0 / read_rows as rows_share,
    read_rows - result_rows as rows_diff,  
    case when result_rows != 0  then (read_rows - result_rows) / result_rows else 0 end as amplification,  --This query had a 1,000,000× read amplification.    
    query
from system.query_log
where type = 'QueryFinish'
order by amplification desc;

