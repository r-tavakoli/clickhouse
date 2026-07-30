----------------------------------------
--Show the top 5 birth years with the highest number of users
----------------------------------------
--Return only the top 5 years.
--Sort from highest to lowest number of users.
--If two years have the same count, show the earlier year first.

select 
	toYear(birth_date) as year,
	count() as total_users
from test_db.users
group by year
order by 
	user_born_counts desc,
	year asc;

select 
	toYear(birth_date) as year,
	count() as total_users
from test_db.users
group by year
order by 
	total_users desc,
	year asc -- If two years have the same count, show the earlier year first
limit 5;

