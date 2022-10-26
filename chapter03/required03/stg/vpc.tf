provider "aws" {
  region = "ap-northeast-2"
}

########## VPC

resource "aws_vpc" "s3ich4n-stg-ch3-ex3-vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "s3ich4n-stg-ch3-ex3-t101-study"
  }
}

########## Subnets

resource "aws_subnet" "s3ich4n-stg-ch3-ex3-subnet01" {
  vpc_id     = aws_vpc.s3ich4n-stg-ch3-ex3-vpc.id
  cidr_block = "10.20.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "s3ich4n-stg-ch3-ex3-t101-subnet1"
  }
}

resource "aws_subnet" "s3ich4n-stg-ch3-ex3-subnet02" {
  vpc_id     = aws_vpc.s3ich4n-stg-ch3-ex3-vpc.id
  cidr_block = "10.20.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "s3ich4n-stg-ch3-ex3-t101-subnet2"
  }
}

########## Internet Gateways

resource "aws_internet_gateway" "s3ich4n-stg-ch3-ex3-igw" {
  vpc_id = aws_vpc.s3ich4n-stg-ch3-ex3-vpc.id

  tags = {
    Name = "s3ich4n-stg-ch3-ex3-t101-igw"
  }
}

########## Routing tables

resource "aws_route_table" "s3ich4n-stg-ch3-ex3-rt" {
  vpc_id = aws_vpc.s3ich4n-stg-ch3-ex3-vpc.id

  tags = {
    Name = "s3ich4n-stg-ch3-ex3-t101-rt"
  }
}

resource "aws_route_table_association" "s3ich4n-stg-ch3-ex3-rt-association01" {
  subnet_id      = aws_subnet.s3ich4n-stg-ch3-ex3-subnet01.id
  route_table_id = aws_route_table.s3ich4n-stg-ch3-ex3-rt.id
}

resource "aws_route_table_association" "s3ich4n-stg-ch3-ex3-rt-association02" {
  subnet_id      = aws_subnet.s3ich4n-stg-ch3-ex3-subnet02.id
  route_table_id = aws_route_table.s3ich4n-stg-ch3-ex3-rt.id
}

resource "aws_route" "s3ich4n-stg-ch3-ex3-default-route" {
  route_table_id         = aws_route_table.s3ich4n-stg-ch3-ex3-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.s3ich4n-stg-ch3-ex3-igw.id
}
