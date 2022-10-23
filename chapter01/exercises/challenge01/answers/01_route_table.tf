# Route table 생성
# provider  : aws
# type      : route_table
resource "aws_route_table" "route_table" {
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
  route_table_id = aws_route_table.route_table.id
}
