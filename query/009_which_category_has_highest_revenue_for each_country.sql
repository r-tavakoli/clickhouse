

--For each country, find the category that generated the highest revenue.

with cte_agg as
(
	select 
		country,
		category,
		sum(quantity * price) as revenue
	from test_db.orders 
	group by 
		country, 
		category
), cte_rn as (
	select 
		*, 		
		row_number() over(partition by country order by revenue desc) as rn 
	from cte_agg
)
select 
	country,
	category,
	revenue	
from cte_rn where rn=1

