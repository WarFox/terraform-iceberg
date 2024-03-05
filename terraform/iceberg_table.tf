# create iceberg tables

resource "aws_glue_catalog_table" "iceberg_tables" {
  for_each = toset(var.table_names)

  name          = lower(each.key)
  database_name = aws_glue_catalog_database.iceberg_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location   = var.location
    compressed = true

    columns {
      comment = "ID of the record"
      name    = "id"
      type    = "string"
    }

    columns {
      comment = "Name of the record"
      name    = "name"
      type    = "string"
    }

    columns {
      comment = "Country"
      name    = "country"
      type    = "string"
    }
  }

  open_table_format_input {
    iceberg_input {
      metadata_operation = "CREATE"
      version            = 2
    }
  }
}
