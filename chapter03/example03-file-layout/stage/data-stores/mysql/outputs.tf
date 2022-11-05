output "rds_address" {
  value       = aws_db_instance.ex3-file-layout-rds.address
  description = "Can connect to the database at this endpoint"
}

output "rds_port" {
  value       = aws_db_instance.ex3-file-layout-rds.port
  description = "The port the database is listening on"
}

output "vpc_id" {
  value       = aws_vpc.ex3-file-layout-vpc.id
  description = "My VPC id"
}
