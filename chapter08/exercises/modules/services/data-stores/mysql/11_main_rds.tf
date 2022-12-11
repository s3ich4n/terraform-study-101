resource "aws_db_subnet_group" "ex8_dbsubnet" {
  name = "${var.env_type}-dbsubnet-group"
  subnet_ids = [
    aws_subnet.ex8_subnet3.id,
    aws_subnet.ex8_subnet4.id,
  ]

  tags = {
    Name = "${var.env_type}-dbsubnet-group"
  }
}

resource "aws_db_instance" "ex8_rds" {
  identifier             = "${var.env_type}-rds"
  engine                 = "mysql"
  allocated_storage      = 10
  instance_class         = "db.t2.micro"
  db_subnet_group_name   = aws_db_subnet_group.ex8_dbsubnet.name
  vpc_security_group_ids = [aws_security_group.ex8_sg2.id]
  skip_final_snapshot    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
}
