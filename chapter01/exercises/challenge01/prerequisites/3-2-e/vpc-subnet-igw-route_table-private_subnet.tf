provider "aws" {
  region = "ap-northeast-2"
}

# Nat Gateway는 Public 서브넷에 위치하지만, 연결은 private 서브넷과 합니다.
# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-e-terraform-101"
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
    Name = "3-2-e-terraform-101-subnet-1"
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
    Name = "3-2-e-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-e-terraform-101-igw-main"
  }
}

# Route table 생성
# provider  : aws
# type      : route_table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-e-terraform-101-route-table"
  }
}

# 서브넷과의 연결
# Route table에 서브넷 1을 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id = aws_subnet.first_subnet.id

  # 인터넷 게이트웨이와 연결함
  route_table_id = aws_route_table.route_table.id
}

# 서브넷과의 연결
# Route table에 서브넷 2를 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id = aws_subnet.second_subset.id

  # 인터넷 게이트웨이와 연결함
  route_table_id = aws_route_table.route_table.id
}

# Private Subnet 1 생성방법
# provider  : aws
# type      : subnet
# 인터넷 게이트웨이에 연결되어있지 않음!
resource "aws_subnet" "first_private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-e-terraform-101-private-subnet-01"
  }
}

# Private Subnet 2 생성방법
# provider  : aws
# type      : subnet
# 인터넷 게이트웨이에 연결되어있지 않음!
resource "aws_subnet" "second_private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-e-terraform-101-private-subnet-02"
  }
}

# NAT Gateway 생성
# AWS Elastic IP도 함께 생성됨에 유의
# Nat Gateway는 Public 서브넷에 위치하지만, 연결은 private 서브넷과 한다.
resource "aws_eip" "nat_01" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat_02" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.nat_01.id

  # Nat Gateway는 Public 서브넷에 위치하지만
  # 연결은 private 서브넷과 진행함에 유의
  subnet_id = aws_subnet.first_subnet.id

  tags = {
    Name = "NAT-GW-01"
  }
}

resource "aws_nat_gateway" "nat_gateway_02" {
  allocation_id = aws_eip.nat_02.id

  subnet_id = aws_subnet.second_subset.id

  tags = {
    Name = "NAT-GW-02"
  }
}
