resource "aws_security_group" "challenge-01-instance" {
  vpc_id = aws_vpc.main.id
  name   = var.challenge_01_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

variable "challenge_01_security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-my-instance"
}
