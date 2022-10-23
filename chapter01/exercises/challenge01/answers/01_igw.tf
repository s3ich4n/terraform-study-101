# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "challenge01-terraform-101-igw-main"
  }
}
