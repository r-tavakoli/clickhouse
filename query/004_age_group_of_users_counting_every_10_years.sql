
----------------------------------------
--age distribution of users
----------------------------------------

/*
a query that returns:

Age Group	Users
0–9			...
10–19		...
20–29		...
...			...

Calculate each user's age from birth_date.
Group users into 10-year age buckets.
Sort from the youngest age group to the oldest.
Find the age group with the most users.

*/

--calculate age 
select
	*,
	date_diff('year', birth_date, today()) as age_with_date_diff,
	age('year', birth_date, today()) as age
from test_db.users;

--age groups
with 
	age('year', birth_date, today()) as age
select
	intDiv(age, 10) * 10 as from_age,
	from_age + 9 as to_age,
	count() as user_counts
from test_db.users
where age >= 0
group by 	
	from_age
order by from_age;

WITH intDiv(age('year', birth_date, today()), 10) * 10 AS age_group
SELECT
    age_group,
    count()
FROM test_db.users
GROUP BY age_group
ORDER BY age_group;

--age group with the most users
with 
	age('year', birth_date, today()) as age
select
	intDiv(age, 10) * 10 as from_age,
	from_age + 9 as to_age,
	count() as user_counts
from test_db.users
where age >= 0
group by 	
	from_age
order by user_counts desc
limit 1;





