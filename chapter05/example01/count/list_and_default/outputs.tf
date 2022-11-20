output "first_arn" {
  value       = aws_iam_user.ch05-ex01-count[0].arn
  description = "The ARN for the first user"
}

output "all_arns" {
  value       = aws_iam_user.ch05-ex01-count[*].arn
  description = "The ARNs for all users"
}
