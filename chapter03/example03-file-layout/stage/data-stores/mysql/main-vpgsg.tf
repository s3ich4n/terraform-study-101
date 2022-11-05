terraform {
  backend "s3" {
    bucket         = "s3ich4n-ex3-file-layout-bucket"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week3-files"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

##### vpcs

resource "aws_vpc" "ex3-file-layout-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "t101-study"
  }
}

##### subnets

resource "aws_subnet" "ex3-file-layout-subnet3" {
  vpc_id     = aws_vpc.ex3-file-layout-vpc.id
  cidr_block = "10.10.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "t101-subnet3"
  }
}

resource "aws_subnet" "ex3-file-layout-subnet4" {
  vpc_id     = aws_vpc.ex3-file-layout-vpc.id
  cidr_block = "10.10.4.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "t101-subnet4"
  }
}


##### route tables

resource "aws_route_table" "ex3-file-layout-rt2" {
  vpc_id = aws_vpc.ex3-file-layout-vpc.id

  tags = {
    Name = "t101-route-table-2"
  }
}

resource "aws_route_table_association" "ex3-file-layout-rt2-association3" {
  subnet_id      = aws_subnet.ex3-file-layout-subnet3.id
  route_table_id = aws_route_table.ex3-file-layout-rt2.id
}

resource "aws_route_table_association" "ex3-file-layout-rt2-association4" {
  subnet_id      = aws_subnet.ex3-file-layout-subnet4.id
  route_table_id = aws_route_table.ex3-file-layout-rt2.id
}


##### Security groups

resource "aws_security_group" "ex3-file-layout-sg2" {
  vpc_id      = aws_vpc.ex3-file-layout-vpc.id
  name        = "T101 SG - RDS"
  description = "T101 Study SG - RDS"
}

resource "aws_security_group_rule" "ex3-file-layout-sg-inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ex3-file-layout-sg2.id
}

resource "aws_security_group_rule" "ex3-file-layout-sg-outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ex3-file-layout-sg2.id
}
