resource "aws_db_subnet_group" "ex3-file-layout-db-subnet" {
  name = "ex3-file-layout-db-subnet-group"
  subnet_ids = [
    aws_subnet.ex3-file-layout-subnet3.id,
    aws_subnet.ex3-file-layout-subnet4.id
  ]

  tags = {
    Name = "my DB subnet group"
  }
}

resource "aws_db_instance" "ex3-file-layout-rds" {
  identifier_prefix    = "t101"
  engine               = "mysql"
  allocated_storage    = 10
  instance_class       = "db.t2.micro"
  db_subnet_group_name = aws_db_subnet_group.ex3-file-layout-db-subnet.name
  vpc_security_group_ids = [
    aws_security_group.ex3-file-layout-sg2.id
  ]
  skip_final_snapshot = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
}
