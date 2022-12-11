output "rds_address" {
  value       = aws_db_instance.ex8_rds.address
  description = "DB connect endpoint addr."
}

output "rds_port" {
  value       = aws_db_instance.ex8_rds.port
  description = "DB connect endpoint port"
}

output "vpc_id" {
  value       = aws_vpc.mysql_vpc.id
  description = "RDS VPC ID"
}
