#
# VPC, 서브넷, IG, 라우트테이블 모두 추가
#

provider "aws" {
  region = "ap-northeast-2"
}

#
#
resource "aws_vpc" "s3ich4n-chapter02-ex02-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "s3ich4n-chapter02-ex02-t101-study"
  }
}

resource "aws_subnet" "s3ich4n-chapter02-ex02-subnet1" {
  vpc_id     = aws_vpc.s3ich4n-chapter02-ex02-vpc.id
  cidr_block = "10.10.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "s3ich4n-chapter02-ex02-t101-subnet1"
  }
}

resource "aws_subnet" "s3ich4n-chapter02-ex02-subnet2" {
  vpc_id     = aws_vpc.s3ich4n-chapter02-ex02-vpc.id
  cidr_block = "10.10.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "s3ich4n-chapter02-ex02-t101-subnet2"
  }
}

resource "aws_internet_gateway" "s3ich4n-chapter02-ex02-igw" {
  vpc_id = aws_vpc.s3ich4n-chapter02-ex02-vpc.id

  tags = {
    Name = "s3ich4n-chapter02-ex02-t101-igw"
  }
}

resource "aws_route_table" "s3ich4n-chapter02-ex02-rt" {
  vpc_id = aws_vpc.s3ich4n-chapter02-ex02-vpc.id

  tags = {
    Name = "s3ich4n-chapter02-ex02-t101-rt"
  }
}

resource "aws_route_table_association" "s3ich4n-chapter02-ex02-rtassociation1" {
  subnet_id      = aws_subnet.s3ich4n-chapter02-ex02-subnet1.id
  route_table_id = aws_route_table.s3ich4n-chapter02-ex02-rt.id
}

resource "aws_route_table_association" "s3ich4n-chapter02-ex02-rtassociation2" {
  subnet_id      = aws_subnet.s3ich4n-chapter02-ex02-subnet2.id
  route_table_id = aws_route_table.s3ich4n-chapter02-ex02-rt.id
}

resource "aws_route" "s3ich4n-chapter02-ex02-defaultroute" {
  route_table_id         = aws_route_table.s3ich4n-chapter02-ex02-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.s3ich4n-chapter02-ex02-igw.id
}
