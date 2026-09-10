
/*
name					The name of the table engine (e.g., MergeTree, ReplicatedMergeTree, Log, Memory, etc.).
supports_sort_order		A boolean flag (1 = true, 0 = false) indicating whether the engine supports sort order
supports_replication	A boolean flag indicating whether the engine supports data replication.
supports_settings		A boolean flag indicating whether the engine supports engine-specific settings.
 */


select
    name,
    supports_sort_order,
    supports_replication,
    supports_settings
from system.table_engines
order by name;