CREATE TABLE iceberg_db.iceberg_table_with_partition (id string, data string, category string)
  PARTITIONED BY (category, bucket(16, id))
  LOCATION 's3://my-iceberg-database-bucket/'
  TBLPROPERTIES ('table_type' = 'ICEBERG', 'format' = 'PARQUET', 'write_compression' = 'ZSTD', 'vacuum_min_snapshots_to_keep' = '10', 'vacuum_max_snapshot_age_seconds' = '604800');
