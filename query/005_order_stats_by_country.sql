
----------------------------------------
--country order stats
----------------------------------------

/*
Return one row per country with:

Country/Orders/Revenue/Avg Order/Paid Orders

Orders = total number of orders
Revenue = price × quantity
Avg Order = average order value (price × quantity)
Paid Orders = number of orders whose status is 'Paid'

*/


select
	country,
	count() as orders,
	sum(price * quantity) as revenue,
	sum(case when status = 'Paid' then price * quantity else 0 end) as paid_revenue,
	sumIf(price * quantity, status = 'Paid') as paid_revenue_2,
	round(avg(price * quantity), 2) as avg_order,
	sum(case when status = 'Paid' then 1 else 0 end) as paid_orders,
	sum(if(status = 'Paid', 1, 0)) as paid_orders_2,
	countIf(status = 'Paid') as paid_orders_3
from
	test_db.orders
group by country;


