--For each country, 
--calculate the percentage of orders that are Paid, 
--and show only countries where the Paid percentage is greater than 20%.

select 
	country,
	count() as total_orders,
	countIf(status = 'Paid') as paid_orders_count,
	countIf(status = 'Paid') * 100.0 / count() as paid_order_pct
from test_db.orders
group by country
having paid_order_pct > 50;