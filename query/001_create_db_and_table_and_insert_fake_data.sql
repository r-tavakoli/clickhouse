------------------------------------------
-- Create db
------------------------------------------
drop database if exists test_db;
create database test_db;

------------------------------------------
-- Switch to test_db
------------------------------------------
use test_db;

-- In DBeaver, when you execute individual statements (Ctrl+Enter), each statement is often sent as a separate request.
-- so default db does not change and u have to edit connection or use db_name before table_name --> test_db.users
select currentDatabase();

------------------------------------------
-- Create tables (orders and users)
------------------------------------------
drop table if exists test_db.users;
create table  test_db.users ( 
    id UInt64,
    first_name String,
    full_name String,
    birth_date Date
) 
engine = MergeTree()
order by (birth_date, id)  -- Order for efficient queries
settings index_granularity = 8192;  -- 8192 rows per index mark (8192 = 2^13 (power of 2)) / default value so we dont need to write!

-- Example: Table with 1,000,000 rows
-- index_granularity = 8192 means:
-- 1,000,000 / 8192 ≈ 122 index marks created
-- Each mark points to the first row of each block of 8192 rows

drop table if exists test_db.orders;
create table test_db.orders
(
    order_id UInt64,
    customer_id UInt64,
    order_date DateTime,

    product_id UInt32,
    category LowCardinality(String),

    quantity UInt8,
    price Decimal(10,2),

    country LowCardinality(String),

    payment_method LowCardinality(String),

    status LowCardinality(String)
)
engine = MergeTree()
partition by toYYYYMM(order_date)
order by (order_date, customer_id);

------------------------------------------
-- Insert table with fake data (100 million records)
------------------------------------------

-- users
with names as (
	select 	['John','Jane','Michael','Sarah','David','Emma','James','Lisa','Robert','Maria'] as first_names,
			['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez'] as last_names
)
insert into test_db.users
select
    number + 1 as id,
    first_names[1 + modulo(rand(), length(first_names))] as first_name,
    last_names[1 + modulo(rand(), length(first_names))] as full_name,
    toDate('1950-01-01') + (rand() % (60 * 365)) as birth_date
from numbers(100000000) as n
cross join names as t
settings max_insert_threads = 16;

-- orders
insert into test_db.orders
select
    number + 1 as order_id,
    randUniform(1,100000) as customer_id,
    now() - interval randUniform(0,1000) day as order_date,
    randUniform(1,50000) as product_id,
    arrayElement(
        ['Electronics','Books','Clothing','Home','Sports'],
        toUInt8(randUniform(1,5))
    ) as category,
    randUniform(1,10) as quantity,
    toDecimal64(randUniform(10,500),2) as price,
    arrayElement(
        ['IR','IQ','LB','ES','YE'],
        toUInt8(randUniform(1,5))
    ) as country,
    arrayElement(
        ['Credit Card','PayPal','Bank Transfer'],
        toUInt8(randUniform(1,3))
    ) as payment_method,
    arrayElement(
        ['Pending','Paid','Cancelled','Refunded'],
        toUInt8(randUniform(1,4))
    ) as status
from numbers(10000000);

--ClickHouse documentation recommends:
--Keep the total number of partitions relatively low (often under a few thousand).
--Don't create hundreds of partitions from a single insert.

--Partitioning is mainly for:
--DROP PARTITION
--Archiving
--TTL
--Data lifecycle management

--It is not the primary mechanism for query acceleration.

------------------------------------------
-- Check data
------------------------------------------
select * from test_db.users;
select count(*) from test_db.users;

select * from test_db.orders;
select count(*) from test_db.orders;




