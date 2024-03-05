# create iceberg tables with partition using null resource

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "null_resource" "iceberg_table_with_partition" {
  # for each file in the ddl folder
  for_each = {
    # get the filename
    for filename in fileset("../resources/ddl/", "*.sql") :
    # filename => file contents
    trimsuffix(filename, ".sql") => file("../resources/ddl/${filename}")
  }

  provisioner "local-exec" {
    command = <<EOF
    echo "Creating table ${each.key}"
    less ../resources/ddl/${each.key}.sql
    aws athena start-query-execution \
      --output json \
      --query-string file://../resources/ddl/${each.key}.sql \
      --query-execution-context "Database=iceberg_db" \
      --result-configuration "OutputLocation=s3://aws-athena-query-results-${local.account_id}-${local.region}"
EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    aws athena start-query-execution \
      --output json \
      --query-string "DROP TABLE IF EXISTS ${each.key};" \
      --query-execution-context "Database=iceberg_db" \
      --result-configuration "OutputLocation=s3://my-athena-query-results-bucket" # only reference attributes of the related resource, via 'self', 'count.index', or 'each.key'
EOF
  }
}
