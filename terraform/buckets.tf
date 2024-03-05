resource "aws_s3_bucket" "iceberg_bucket" {
  bucket = "iceberg-tables-${local.account_id}-${local.region}"
}
