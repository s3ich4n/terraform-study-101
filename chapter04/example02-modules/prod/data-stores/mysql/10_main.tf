provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  backend "s3" {
    bucket         = "ex4-s3-bucket"
    key            = "prod/data-stores/mysql/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week4-files"
  }
}

module "mysql" {
  source = "../../../modules/services/data-stores/mysql"

  db_username = "terraform"
  db_password = "terraform!!"

  env_type     = "prod"
  vpc_cidr     = "10.100.0.0/16"
  subnet3_cidr = "10.100.3.0/24"
  subnet4_cidr = "10.100.4.0/24"
}
