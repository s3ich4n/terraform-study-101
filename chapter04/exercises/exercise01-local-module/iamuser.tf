provider "aws" {
  region = "ap-northeast-2"
}

locals {
  name = "s3ich4n-test"
  team = {
    group = "dev"
  }
}

resource "aws_iam_user" "s3ich4n-user01" {
  name = local.name
  tags = local.team
}

resource "aws_iam_user" "s3ich4n-user02" {
  name = local.name
  tags = local.team
}
