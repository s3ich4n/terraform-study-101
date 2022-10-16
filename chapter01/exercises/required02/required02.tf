provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "s3ich4n-exercises-02" {
  ami                    = "ami-0775b32552c39d15c"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo echo "s3ich4n" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "s3ich4n-chapter01-exercises-02"
  }
}

resource "aws_security_group" "instance" {
  name = var.security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "s3ich4n-chapter01-exercises-02-sg"
}

output "public_ip" {
  value       = aws_instance.s3ich4n-exercises-02.public_ip
  description = "Public IP of the instance"
}
