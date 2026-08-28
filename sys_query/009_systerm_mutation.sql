


select
    database,
    table,
    mutation_id,
    command, -- The mutation command (UPDATE/DELETE)
    create_time,
    is_done, --I ran an UPDATE but my data hasn't changed yet! identify here is done or not
    parts_to_do, -- Number of parts still waiting for the mutation
    latest_fail_reason -- If failed, the error message
from system.mutations
where database = 'test_db'
order by create_time desc;