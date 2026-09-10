--Let's see what happens without an index.
select count()
from  test_db.orders
where country = 'IR';


select
    query_duration_ms,
    read_rows,
    formatReadableSize(read_bytes) as read_size,
    result_rows,
    query
from system.query_log
where 
		type = 'QueryFinish'
  and 	query like '%country = ''IR''%'
order by event_time desc
limit 1;

EXPLAIN indexes = 1
select count()
from test_db.orders
where country = 'IR';

--That means nothing was skipped.
-- partition and primary key(sorting key) did not help
--PrimaryKey: 1233/1233
--MinMax:     1233/1233
--Partition:  1233/1233

/*
    Min-Max                            
     Condition: true                  
     Parts: 36/36                     
     Granules: 1233/1233              
   Partition                          
     Condition: true                  
     Parts: 36/36                     
     Granules: 1233/1233              
   PrimaryKey                         
     Condition: true                  
     Parts: 36/36                     
     Granules: 1233/1233              
   Ranges: 36                         
 */

--creating a set index
alter table test_db.orders
add index idx_country country
type set(10)
granularity 1;
--the index definition is added to the table, but existing parts don't necessarily have the index materialized yet.


--this command builds the index for the existing parts
alter table test_db.orders materialize index idx_country;

--verify index
select
    name,
    type,
    expr,
    granularity
from system.data_skipping_indices
where database = 'test_db' and table = 'orders';

--lets check plan again
EXPLAIN indexes = 1
select count()
from test_db.orders
where country = 'IR';

--so the result show set index not skiping any granule
--✅ Index exists
--✅ Index was materialized
--✅ ClickHouse considered it
--❌ But it couldn't eliminate any granules

/*
Skip                                  
  Name: idx_country                   
  Description: set GRANULARITY 1      
  Condition: (country in ['IR', 'IR'])
  Parts: 36/36                        
  Granules: 1233/1233                 
*/

--remove index
alter table test_db.orders drop index idx_country;
