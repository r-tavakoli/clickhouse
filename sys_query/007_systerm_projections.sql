--before creating projection shows it is reading from table
EXPLAIN
select 
	country,
	count() as count
from test_db.orders 
group by country

--explain |
---------------------------------------+
--Output: country, count() |
--|
--Aggregating |
--│ Keys: country |
--│ Aggregates: count() |
--│ Skip merging: 0 |
--└──ReadFromMergeTree (test_db.orders)|


--create a projection (no need to "from" part)
alter table test_db.orders
add projection if not exists projection_country(
	select 
		country,
		count() as count
	group by country
);

--this builds the projection for the existing data.
alter table test_db.orders materialize PROJECTION projection_country;

--inspect projections associated with tables
select
    database,
    table,
    name,
    type,
    query,
    settings
from system.projections
where database = 'test_db';

--plan to see projection
EXPLAIN
select 
	country,
	count() as count
from test_db.orders 
group by country

EXPLAIN indexes = 1
select 
	country,
	count() as count
from test_db.orders 
group by country

--explain                                  |
-------------------------------------------+
--Output: country, count()                 |
--                                         |
--Aggregating                              |
--│  Keys: country                         |
--│  Aggregates: count()                   |
--│  Skip merging: 0                       |
--└──ReadFromMergeTree (projection_country)| here!
--      Read type: Default                 |
--      Parts: 36 | Granules: 36           |
--      Output: country, count()           |
--      Indexes:                           |
--        PrimaryKey                       |
--          Condition: true                |
--          Parts: 36/36                   |
--          Granules: 36/36                |
--        Ranges: 36                       |

EXPLAIN projections = 1
select 
	country,
	count() as count
from test_db.orders 
group by country

--explain                                  |
-------------------------------------------+
--Output: country, count()                 |
--                                         |
--Aggregating                              |
--│  Keys: country                         |
--│  Aggregates: count()                   |
--│  Skip merging: 0                       |
--└──ReadFromMergeTree (projection_country)| here!
--      Read type: Default                 |
--      Parts: 36 | Granules: 36           |
--      Output: country, count()           |



