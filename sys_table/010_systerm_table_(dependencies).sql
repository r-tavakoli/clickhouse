

/*
The dependencies_table column is particularly useful 
for finding Materialized Views that depend on a source table
source table → Materialized View → target table
*/

--find all Tables and their dependencies
select
    database,
    name as table_name,
    engine,
    dependencies_database,
    dependencies_table
from system.tables
where database = 'test_db'
  and (length(dependencies_table) > 0 or length(dependencies_database) > 0)
order by database, name;

--find all Materialized Views and their source dependencies
select
    database,
    name as mv_name,
    dependencies_database,
    dependencies_table
from system.tables
where engine = 'MaterializedView'
  and database = 'test_db';