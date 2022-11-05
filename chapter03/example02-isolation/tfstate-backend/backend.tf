provider "aws" {
  region = "ap-northeast-2"
}

#
# tags 정보를 default 와 나머지 작업공간을 다르게 설정되게 코드를 변경 해보고 테스트 해보아야 함!
#
resource "aws_s3_bucket" "s3ich4n-ch03-isolation-s3-bucket" {
  bucket = "s3ich4n-ch03-isolation-t101study-tfstate-week3"
}

resource "aws_s3_bucket_versioning" "s3ich4n-ch03-isolation-s3-bucket-versioning" {
  bucket = aws_s3_bucket.s3ich4n-ch03-isolation-s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "s3ich4n-ch03-isolation-dynamodb-table" {
  name         = "terraform-locks-week3"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.s3ich4n-ch03-isolation-s3-bucket.arn
  description = "ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.s3ich4n-ch03-isolation-dynamodb-table.name
  description = "Name of the DynamoDB table"
}
