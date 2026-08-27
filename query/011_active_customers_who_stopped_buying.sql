

--"Which customers were active before but have stopped buying recently?"

--Previous activity: customer has orders before
--Inactive: no orders in the last 90 days from the maximum order date in the table


select 
	customer_id,
	max(order_date) as last_order_date
from test_db.orders
where 
		status in ('Paid', 'Pending') 
	and order_date < (select max(order_date) - interval 90 day from test_db.orders)
group by customer_id


--pre calculated (more efficient)
with cutoff_date as (
    select max(order_date) - interval 90 day as date
    from test_db.orders
)
select 
    o.customer_id,
    max(o.order_date) as last_order_date,
    dateDiff('day', max(order_date), today()) as days_since_last_order
from test_db.orders o
cross join cutoff_date c
where 
    	o.status in ('Paid', 'Pending') 
    and o.order_date < c.date
group by o.customer_id;

