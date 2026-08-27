
--Calculate for each customer:
--
--customer_id
--total_orders
--total_spent
--average_order_value (total revenue / number of orders)
--last_order_date
--only include customers with at least 10 orders
--sort by highest total spending

select 
	customer_id,
	count(distinct order_id) as total_orders, --order_id is unique so no need to distinct!
	sum(quantity * price) as total_spent,
	sum(quantity * price)/count(distinct order_id) as average_order_value, --aov is better to write avg(quantity * price) in this case 
	max(order_date) as last_order_date
from test_db.orders
where status in ('Paid', 'Pending')
group by customer_id 
having total_orders >= 10
order by total_spent desc;


