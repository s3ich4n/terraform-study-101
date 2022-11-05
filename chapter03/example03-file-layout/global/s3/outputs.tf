output "s3_bucket_arn" {
  value       = aws_s3_bucket.ex3-file-layout-bucket.arn
  description = "The ARN of this S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.ex3-file-layout-dynamodb-table.name
  description = "The name of this DynamoDB table"
}
