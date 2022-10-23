provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-c-terraform-101"
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
    Name = "3-2-c-terraform-101-subnet-1"
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
    Name = "3-2-c-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-c-terraform-101-igw-main"
  }
}
