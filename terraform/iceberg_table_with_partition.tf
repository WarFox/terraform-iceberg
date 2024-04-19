# create iceberg tables with partition using null resource

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "null_resource" "iceberg_table_with_partition" {
  # for each file in the resources/ddl folder, make a map of filename => ../resources/ddl/filename.sql
  for_each = {
    for filename in fileset("../resources/ddl/", "*.sql") : trimsuffix(filename, ".sql") => "../resources/ddl/${filename}.sql"
  }

  triggers = {
    # Changes content of the file will trigger the resource to be recreated
    file_md5s = filemd5("../resources/ddl/${each.key}.sql")
  }

  provisioner "local-exec" {
    command = "./bin/create_table.sh"

    # environtment variables are available in the script
    environment = {
      TABLE_NAME    = each.key
      DATABASE_NAME = "iceberg_db"
      REGION        = local.region
      ACCOUNT_ID    = local.account_id
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    aws athena start-query-execution \
      --output json \
      --query-string "DROP TABLE IF EXISTS ${each.key};" \
      --query-execution-context "Database=iceberg_db" \
      --result-configuration "OutputLocation=s3://aws-athena-query-results-bucket" # only reference attributes of the related resource, via 'self', 'count.index', or 'each.key'
EOF
  }
}
