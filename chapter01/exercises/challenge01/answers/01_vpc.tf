# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "challenge01-terraform-101"
  }
}

output "public_ip" {
  value       = aws_instance.challenge01-server.public_ip
  description = "The public IP of my instance"
}
