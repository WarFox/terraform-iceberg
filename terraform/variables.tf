variable "table_names" {
  description = "Create Schemas for the below tables"
  type        = list(string)
  default     = ["iceberg_table"]
}

variable "environment" {
  description = "Environment to deploy to"
  type        = string
  default     = "playground"
}

variable "location" {
  description = "Location of the data"
  type        = string
}
