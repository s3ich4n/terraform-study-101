provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  backend "s3" {
    bucket         = "ex8-s3-bucket"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week4-files"
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  ex8_cluster_name            = "webservers-prod"
  db_remote_state_bucket_name = "ex8-s3-bucket"
  db_remote_state_key         = "prod/data-stores/mysql/terraform.tfstate"
  env_type                    = "production"

  instance_type = "m4.large"
  min_size      = 2
  max_size      = 5
}
