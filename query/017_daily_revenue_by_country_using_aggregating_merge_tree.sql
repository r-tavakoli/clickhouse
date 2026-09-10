

--daily revenue and number of orders for each country
--excluding Cancelled orders
--using AggregatinMergeTree table

--drop table
drop table if exists test_db.daily_sales_by_country;

--create table
create table test_db.daily_sales_by_country
(
    order_date Date,
    country LowCardinality(String),
    
    revenue AggregateFunction(sum, Decimal(10, 2)),
    orders AggregateFunction(count, UInt64)
)
engine = AggregatingMergeTree()
partition by toYYYYMM(order_date)
order by (order_date, country);

--query to insert
insert into test_db.daily_sales_by_country
select
	order_date,
	country,
	sumState(quantity * price) as revenue,
	countState() as orders
from test_db.orders
where status != 'Cancelled'
group by 
	order_date,
	country;
	
--display result
select
    order_date,
    country,
    sumMerge(revenue) as total_revenue,
    countMerge(orders) as total_orders
from test_db.daily_sales_by_country
group by order_date, country
order by order_date, country;

----------------------------
--MV method
----------------------------
--what does Materialized View do?
--when new rows are inserted into source table ("orders")
--the MV is triggered and automatically processes those inserted rows 
--and writes the aggregation states into target table ("daily_sales_by_country")

--creating materialized view (a better pattern)
drop view if exists test_db.daily_sales_by_country_mv;

create materialized view test_db.daily_sales_by_country_mv
to test_db.daily_sales_by_country
as
select
    toDate(order_date) as order_date,
    country,
    sumState(quantity  * price) as revenue, --sumState explicitly cast to match the target Decimal
    countState() as orders
from test_db.orders
group by order_date, country;

--new data if inserted new data will be aggregated and result add to previous result

--display data
select
    order_date,
    country,
    sumMerge(revenue) as total_revenue,
    countMerge(orders) as total_orders
from test_db.daily_sales_by_country
group by order_date, country
order by order_date, country;











