resource "aws_security_group" "s3ich4n-chapter02-ex01-sg" {
  vpc_id      = aws_vpc.s3ich4n-chapter02-ex01-vpc.id
  name        = "s3ich4n-chapter02-ex01 T101 SG"
  description = "s3ich4n-chapter02-ex01 T101 Study SG"
}

resource "aws_security_group_rule" "s3ich4n-chapter02-ex01-inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.s3ich4n-chapter02-ex01-sg.id
}

resource "aws_security_group_rule" "s3ich4n-chapter02-ex01-outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.s3ich4n-chapter02-ex01-sg.id
}
