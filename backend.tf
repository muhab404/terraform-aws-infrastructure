terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-unique-12345"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
