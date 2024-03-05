locals {
  table_schemas = {
    for table in var.table_names :
    table => jsondecode(file(format("%s/../resources/schemas/%s.json", path.cwd, table)))
  }
}

resource "aws_glue_catalog_table" "iceberg_tables_from_json" {
  for_each = local.table_schemas

  name          = format("%s_from_json", lower(each.key))
  database_name = aws_glue_catalog_database.iceberg_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location   = var.location
    compressed = true

    dynamic "columns" {
      for_each = each.value.fields

      content {
        comment = columns.value.description
        name    = columns.value.name
        type    = try(columns.value.logicalType, columns.value.type)
      }
    }
  }

  open_table_format_input {
    iceberg_input {
      metadata_operation = "CREATE"
      version            = 2
    }
  }
}

