provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "ex3-file-layout-bucket" {
  bucket = "s3ich4n-ex3-file-layout-bucket"
}

resource "aws_s3_bucket_versioning" "ex3-file-layout-bucket-versioning" {
  bucket = aws_s3_bucket.ex3-file-layout-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_dynamodb_table" "ex3-file-layout-dynamodb-table" {
  name         = "terraform-locks-week3-files"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
