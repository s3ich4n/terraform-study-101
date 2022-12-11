provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "ex8-bucket" {
  bucket = "ex8-s3-bucket"
}

resource "aws_s3_bucket_versioning" "ex8-bucket-versioning" {
  bucket = aws_s3_bucket.ex8-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "ex8-dynamodb-table" {
  name         = "terraform-locks-week4-files"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
