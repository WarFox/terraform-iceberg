provider "aws" {
  region = "eu-west-1"

  # default tags for all resouces
  default_tags {
    tags = {
      "Environment" = var.environment
      "Project"     = "IcebergTest"
    }
  }
}
