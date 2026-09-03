

--latest customer version using argMax
select
    customer_id,
    argMax(name, version) as name,
    argMax(country, version) as country,
    argMax(status, version) as status,
    max(version) as latst_version
from test_db.customer_versions
group by customer_id
order by customer_id;