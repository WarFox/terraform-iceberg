# Terraform Iceberg

Setup iceberg tables with terraform

This is a POC for setting up iceberg tables using avro schemas definition in aws.

## Run

1. Authenticate AWS
2. cd terraform/
3. terraform init
4. terraform plan
5. terraform apply
6. terraform destroy

## Why?

Terraform does not support creating iceberg tables with partitions, because this functionality is not available in the upstream Go SDK.

Refer the following files to see how you can use `null_resource` with `local-exec` `provsioner` to create and destroy ICEBERG tables using DDLs.

1. https://github.com/WarFox/terraform-iceberg/blob/main/terraform/iceberg_table_with_partition.tf
2. https://github.com/WarFox/terraform-iceberg/blob/main/resources/ddl/iceberg_table_with_partition.sql

> [!CAUTION]
> Important: Terraform docs warns to use provisioners as a last resort. Use this is as a stop gap until the feature is directly available.
> Run this as a separate script as you may need to run `terraform destroy` to make changes to the table.

## References

- https://github.com/hashicorp/terraform-provider-aws/issues/12129
- https://discuss.hashicorp.com/t/partition-columns-to-aws-athena-iceberg-table/61049
- https://stackoverflow.com/questions/75581933/how-to-deploy-iceberg-tables-to-aws-through-terraform
- https://stackoverflow.com/questions/75383898/issues-when-i-try-to-configure-an-aws-athena-iceberg-table-using-terraform?noredirect=1&lq=1

<!-- Copyright (C) 2024 by Deepu Mohan Puthrote -->
