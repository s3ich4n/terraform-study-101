provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: AWS
# type:     VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-a-terraform-101"
  }
}
