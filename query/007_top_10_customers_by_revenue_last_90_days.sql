
/*
Show the top 10 customers by revenue during the last 90 days
	Use only orders from the last 90 days.
	Revenue = price * quantity.
	Sort by revenue descending.
	Return only the top 10.
	Return average_order_value too if possible
	Including customers with at least 5 orders
*/

with today() - INTERVAL 90 day as from_date
select 
	customer_id,
	sum(price * quantity) as revenue,
	avg(price * quantity) as average_order_value,
	count(order_id) as order_count
from test_db.orders
where order_date >= from_date
group by customer_id
having order_count >= 5
order by revenue desc
limit 10;

