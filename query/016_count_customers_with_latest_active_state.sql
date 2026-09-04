

--Determine each customer's latest state first.
--Then count them.
--Don't count historical states.
--Return the number of customers whose latest plan is Premium, by country.

--table 
drop table if exists test_db.customer_activity;

create table test_db.customer_activity
(
    customer_id uint32,
    country string,
    status string,
    plan string,
    updated_at datetime64(3)
)
engine = mergeTree()
order by (customer_id, updated_at);


--insert sample data
insert into test_db.customer_activity values

-- Customer 101
(101, 'IR', 'Active',   'Basic',   '2026-09-04 10:00:00.000'),
(101, 'IR', 'Active',   'Premium', '2026-09-04 11:00:00.000'),
(101, 'IR', 'Inactive', 'Premium', '2026-09-04 12:00:00.000'),

-- Customer 102
(102, 'IQ', 'Active',   'Basic',   '2026-09-04 09:00:00.000'),
(102, 'IQ', 'Active',   'Premium', '2026-09-04 13:00:00.000'),

-- Customer 103
(103, 'LB', 'Active',   'Basic',   '2026-09-04 08:30:00.000'),
(103, 'LB', 'Inactive', 'Basic',   '2026-09-04 14:00:00.000'),

-- Customer 104
(104, 'IR', 'Active',   'Basic',   '2026-09-04 09:15:00.000'),

-- Customer 105
(105, 'IQ', 'Active',   'Basic',   '2026-09-04 10:30:00.000'),
(105, 'IQ', 'Active',   'Premium', '2026-09-04 11:45:00.000');


--desplay data
select *
from test_db.customer_activity
order by customer_id, updated_at;

--query (count customers with latest active state)
with cte as 
(
	select 
		customer_id,
		argMax(status, updated_at) as latest_status
	from test_db.customer_activity
	group by customer_id
	having latest_status = 'Active'
)
select count(customer_id) as customers_with_latest_active_state
from cte

--query (number of customers whose latest plan is Premium, by country)
with cte as 
(
	select 
		customer_id,
		argMax(country, updated_at) as latest_country,
		argMax(plan, updated_at) as latest_plan
	from test_db.customer_activity
	group by customer_id
	having latest_plan = 'Premium'
)
select 
	latest_country as country,
	count(customer_id) as customers_with_latest_premium_plan
from cte
group by latest_country


--query (number of customers whose latest plan is Premium, by country)
--latest_data.1 → country
--latest_data.2 → plan
select
    latest_data.1 as latest_country,
    count() as customers_count
from
(
    select
        customer_id,
        argMax((country, plan), updated_at) as latest_data
    from test_db.customer_activity
    group by customer_id
) as t
where latest_data.2 = 'Premium'
group by latest_data.1;

