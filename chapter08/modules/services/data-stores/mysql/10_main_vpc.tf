resource "aws_vpc" "mysql_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_type}-terraform-study"
  }
}

resource "aws_subnet" "ex4_subnet3" {
  vpc_id     = aws_vpc.mysql_vpc.id
  cidr_block = var.subnet3_cidr

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.env_type}-terraform-ex4-subnet3"
  }
}

resource "aws_subnet" "ex4_subnet4" {
  vpc_id     = aws_vpc.mysql_vpc.id
  cidr_block = var.subnet4_cidr

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.env_type}-terraform-ex4-subnet4"
  }
}

resource "aws_security_group" "ex4_sg2" {
  vpc_id      = aws_vpc.mysql_vpc.id
  name        = "${var.env_type}-sg-rds"
  description = "terraform Study SG - RDS"
}

resource "aws_security_group_rule" "rds_sg_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = local.mysql_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ex4_sg2.id
}

resource "aws_security_group_rule" "rds_sg_outbound" {
  type              = "egress"
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ex4_sg2.id
}
