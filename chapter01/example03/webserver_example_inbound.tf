provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "example" {
  ami                    = "ami-0e9bfdb247cc8de84"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, T101 Study 9090" > index.html
              nohup busybox httpd -f -p 9090 &
              EOF

  # 이거 안맞으면 `user_data` 내용이 싱크 안맞는다!
  user_data_replace_on_change = false

  tags = {
    Name = "terraform-study-101-webserver"
  }
}

resource "aws_security_group" "instance" {
  name = var.new_security_group_name

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "new_security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the Instance"
}
