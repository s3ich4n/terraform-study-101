provider "aws" {
  region = "ap-northeast-2"
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "t101-study"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "aws_db_instance" "myrds" {
  identifier_prefix   = "t101-sensitivedata"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true

  db_name  = "with_aws_secret_manager_demo"
  username = local.db_creds.username
  password = local.db_creds.password
}
