
--latest version of customer with row_number
--we mostly use this method in non ReplacingMergeTree
select
    customer_id,
    name,
    country,
    status,
    version,
    updated_at
from
(
    select
        *,
        row_number() over (
            partition by customer_id
            order by version desc
        ) as rn
    from test_db.customer_versions
)
where rn = 1
order by customer_id;