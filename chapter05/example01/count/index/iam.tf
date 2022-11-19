provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "ch05-iam" {
  count = 3
  name  = "s3ich4n.${count.index}"
}
