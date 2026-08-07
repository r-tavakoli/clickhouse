

/*
Create a report showing:
	Country/Category/Revenue/Rank
	
Revenue = SUM(price * quantity)
Categories are ranked inside each country
Highest revenue gets rank 1
TOP 2 highest categories
*/

with cte as (
	select
		country,
		category,
		sum(price * quantity) as revenue
	from test_db.orders
	group by country, category
)
select 
	*,
	row_number() over(partition by country order by revenue desc) as rn,
	rank() over(partition by country order by revenue desc) as rank_,	
	dense_rank() over(partition by country order by revenue desc) as dense_rank_	
from cte;

--top 2
with cte as (
	select
		country,
		category,
		sum(price * quantity) as revenue
	from test_db.orders
	group by country, category
), cte_rank as (
	select 
		*,
		row_number() over(partition by country order by revenue desc) as rn,
		rank() over(partition by country order by revenue desc) as rank_,	
		dense_rank() over(partition by country order by revenue desc) as dense_rank_	
	from cte
)
select * from cte_rank where rn<=2

