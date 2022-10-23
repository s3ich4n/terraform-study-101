provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-d-terraform-101"
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
    Name = "3-2-d-terraform-101-subnet-1"
  }
}

# Subnet 2 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "second_subset" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "3-2-d-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-d-terraform-101-igw-main"
  }
}

# Route table 생성
# provider  : aws
# type      : route_table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-d-terraform-101-route-table"
  }
}

# 서브넷과의 연결
# Route table에 서브넷 1을 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.first_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# 서브넷과의 연결
# Route table에 서브넷 2를 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.second_subset.id
  route_table_id = aws_route_table.route_table.id
}
