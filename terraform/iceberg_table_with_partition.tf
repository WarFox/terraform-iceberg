# create iceberg tables with partition using null resource

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# create a local file for each file in the resources/ddl folder
resource "local_file" "drop_table_files" {
  for_each = {
    for filename in fileset("../resources/ddl/", "*.sql") : trimsuffix(filename, ".sql") => filemd5("../resources/ddl/${filename}")
  }

  content = templatefile("./bin/drop_table.sh.tpl", {
    table_name    = each.key,
    database_name = "iceberg_db",
    account_id    = local.account_id,
    region        = local.region
  })

  # create new executable file for each table
  filename = "./bin/drop_table_${each.key}.sh"
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
    command = "./bin/drop_table_${each.key}.sh"
  }

  depends_on = [local_file.drop_table_files]

}
