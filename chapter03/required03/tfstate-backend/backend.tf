provider "aws" {
  region = "ap-northeast-2"
}

############## S3

resource "aws_s3_bucket" "s3ich4n-chapter03-ex03-s3-bucket" {
  bucket = "s3ich4n-chapter03-ex03-t101study-tfstate"
}

resource "aws_s3_bucket_versioning" "s3ich4n-chapter03-ex03-s3-bucket-versioning" {
  bucket = aws_s3_bucket.s3ich4n-chapter03-ex03-s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

############### DynamoDB

resource "aws_dynamodb_table" "s3ich4n-chapter03-ex03-dynamodb-table" {
  name         = "terraform-lock-mgmt"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

############### Output


output "s3_bucket_arn" {
  value       = aws_s3_bucket.s3ich4n-chapter03-ex03-s3-bucket.arn
  description = "ARN of this S3 bucket"
}


output "dynamodb_table_name" {
  value       = aws_dynamodb_table.s3ich4n-chapter03-ex03-dynamodb-table.arn
  description = "ARN of this DynamoDB"
}
