provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "challenge01-terraform-101"
  }
}


# Subnet 1 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "challenge01-terraform-101-subnet-1"
  }
}

# Internet Gateway 생성
# provider  : aws
# type      : internet_gateway
resource "aws_internet_gateway" "challenge01-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "challenge01-terraform-101-challenge01-igw-main"
  }
}

# Security Group 생성
# provider  : aws
# type      : security_group
resource "aws_security_group" "challenge-01-instance" {
  vpc_id = aws_vpc.main.id
  name   = var.challenge_01_security_group_name

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group 규칙 생성
# provider  : aws
# type      : security_group_rule
resource "aws_security_group_rule" "challenge01-inbound" {
  type              = "ingress"
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.challenge-01-instance.id
}

# Security Group 규칙 생성
# provider  : aws
# type      : security_group_rule
resource "aws_security_group_rule" "challenge01-outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.challenge-01-instance.id
}

variable "challenge_01_security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "challenge01-terraform-sg"
}

# Route table 생성
# provider  : aws
# type      : route_table
resource "aws_route_table" "challenge01-route-table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "challenge01-terraform-101-route-table"
  }
}

# 서브넷과의 연결
# Route table에 서브넷 1을 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.first_subnet.id
  route_table_id = aws_route_table.challenge01-route-table.id
}

# aws_route 라는 내용이 신규로 추가!
# 관련 링크: https://devops.stackexchange.com/questions/16241/aws-terraform-vpc-difference-between-aws-route-table-and-aws-route
# provider  : aws
# type      : route_table
resource "aws_route" "challenge01-default-route" {
  route_table_id         = aws_route_table.challenge01-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.challenge01-igw.id
}

######################################## OUTPUT

output "public_ip" {
  value       = aws_instance.challenge01-server.public_ip
  description = "The public IP of my instance"
}
