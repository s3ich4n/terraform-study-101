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
