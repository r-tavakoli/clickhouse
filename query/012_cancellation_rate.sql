

--Calculate the net revenue by country, excluding cancelled orders.
--country
--total_orders = all orders
--valid_orders = orders that aren't cancelled
--net_revenue = revenue from valid orders
--cancellation_rate = cancelled orders / total orders


select
	country,
	count() as total_orders,
	countIf(status!='Cancelled') as valid_orders,
	sumIf(quantity * price, status!='Cancelled') as net_revenue,
    round(countIf(status = 'Cancelled') * 100.0 / count(), 2) as  cancellation_rate
from test_db.orders
group by country;

