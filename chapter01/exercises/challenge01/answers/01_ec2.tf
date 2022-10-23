resource "aws_instance" "challenge01-server" {
  ami                         = "ami-0e9bfdb247cc8de84"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.first_subnet.id
  vpc_security_group_ids      = [aws_security_group.challenge-01-instance.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
              mv busybox-x86_64 busybox
              chmod +x busybox
              RZAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
              IID=$(curl 169.254.169.254/latest/meta-data/instance-id)
              LIP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
              echo "<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "challenge01-my-server"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}
