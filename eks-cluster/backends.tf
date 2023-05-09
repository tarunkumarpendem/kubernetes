terraform {
  backend "s3" {
    bucket = "openmrs-terraform-statefile"
    key = "openmrs"
    dynamodb_table = "openmrs-dynamo-db-table"
    region = "us-east-1"
  }
}