

--create sample table to store versions of customer changes (like: scd 2)
--we use final to deduplcate data but is resource cosuming
--and also by default in replacingmargetree data gets merged 
--so if it is surley needed we use it!
DROP TABLE IF EXISTS test_db.customer_versions;

CREATE TABLE test_db.customer_versions
(
    customer_id UInt32,
    name String,
    country String,
    status String,
    version UInt32, --not using in calculations, we use updated_at instead 
	updated_at DateTime64(3)
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY customer_id;

--DateTime64(0)  --> seconds
--DateTime64(3)  --> milliseconds
--DateTime64(6)  --> microseconds
--DateTime64(9)  --> nanoseconds

--temporarly disable merge to see the result
SYSTEM STOP MERGES test_db.customer_versions;


--insert sample data (we insert row separately to avoid merging them automatically)
INSERT INTO test_db.customer_versions VALUES
(101, 'Ali',  'IR', 'Active',   1, '2026-08-01 10:00:00.001');
INSERT INTO test_db.customer_versions VALUES
(101, 'Ali',  'IR', 'Inactive', 2, '2026-08-10 12:00:00.125');
INSERT INTO test_db.customer_versions VALUES
(101, 'Ali',  'IQ', 'Active',   3, '2026-08-20 15:00:00.201');

INSERT INTO test_db.customer_versions VALUES
(102, 'Sara', 'IQ', 'Active',   1, '2026-08-02 09:00:00.401');
INSERT INTO test_db.customer_versions VALUES
(102, 'Sara', 'IQ', 'Inactive', 2, '2026-08-15 11:00:00.781');

INSERT INTO test_db.customer_versions VALUES
(103, 'John', 'LB', 'Active',   1, '2026-08-03 14:00:00.131');

INSERT INTO test_db.customer_versions VALUES
(104, 'Mina', 'IR', 'Active',   1, '2026-08-04 16:00:00.641');
INSERT INTO test_db.customer_versions VALUES
(104, 'Mina', 'IR', 'Active',   2, '2026-08-25 17:00:00.361');


--show data
SELECT *
FROM test_db.customer_versions
ORDER BY customer_id, version;

--latest version (deduplication)
SELECT *
FROM test_db.customer_versions FINAL
ORDER BY customer_id;











