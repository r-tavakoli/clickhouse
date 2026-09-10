
/*
table 				Name of the table the column belongs to
name				Name of the column
type				Data type of the column (e.g., String, UInt64, DateTime)
default_kind		Default value type: DEFAULT, MATERIALIZED, ALIAS, or empty if none
compression_codec	Compression codec used for the column (e.g., LZ4, ZSTD)
is_in_primary_key	Whether the column is part of the primary key (1 = yes, 0 = no)
*/

select
    table,
    name,
    type,
    default_kind,
    compression_codec,
    is_in_primary_key
from system.columns
where database = 'test_db'
order by table, position;