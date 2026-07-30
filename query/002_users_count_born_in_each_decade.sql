----------------------------------------
--How many users were born in each decade?
----------------------------------------

--my solution:

select distinct
	extract(DECADE from birth_date) * 10 as from_,
	ceil(toYear(birth_date) + 0.0001, -1) as to_ --added 0.0001 to convert 2000 to 2010 and not 2000 (i know i dont need this field. and i know i can calculate it with from_)
from test_db.users
where id<20;

with cte as (
	select 
		extract(DECADE from birth_date) * 10 as from_,
		count() as users_born_count
	from test_db.users
	group by from_
)
select 
	from_,
	from_ + 10 as to_,
	users_born_count
from cte;

----------------------------------------
--solutions i could find:
----------------------------------------

--solution 1:
with
    extract(DECADE from birth_date) * 10 as decade
select
    decade as from_,
    decade + 10 as to_,
    count() as users_born_count
from test_db.users
group by decade
order by decade;

--solution 2:
select
    intDiv(toYear(birth_date), 10) * 10 as from_, --performs integer division directly
    from_ + 10 as to_,
    count() as users_born_count
from test_db.users
group by from_
order by from_;





