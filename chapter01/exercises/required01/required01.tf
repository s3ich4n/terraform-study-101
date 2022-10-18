provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "s3ich4n-exercises-01" {
  ami                    = "ami-0775b32552c39d15c"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt install -y apache2
              sudo ufw allow 'Apache'
              sudo echo "s3ich4n" | sudo tee /var/www/html/index.html > /dev/null
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "s3ich4n-chapter01-exercises-01"
  }
}

resource "aws_security_group" "instance" {
  name = var.security_group_name

  ingress {
    from_port   = 80
    to_port     = 80
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
  default     = "s3ich4n-chapter01-exercises-01-sg"
}

output "public_ip" {
  value       = aws_instance.s3ich4n-exercises-01.public_ip
  description = "Public IP of the instance"
}
