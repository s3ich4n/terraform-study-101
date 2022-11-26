provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_secretsmanager_secret" "example" {
  name = "t101-study"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = jsonencode(var.rdb_cred)
}
