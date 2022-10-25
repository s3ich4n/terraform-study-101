data "aws_ami" "s3ich4n-chapter02-ex02-amazonlinux2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "s3ich4n-chapter02-ex02-launchconfig" {
  name_prefix                 = "s3ich4n-chapter02-ex02-"
  image_id                    = data.aws_ami.s3ich4n-chapter02-ex02-amazonlinux2.id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.s3ich4n-chapter02-ex02-sg.id]
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
              nohup ./busybox httpd -f -p 80 &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "s3ich4n-chapter02-ex02-asg" {
  name                 = "s3ich4n-chapter02-ex02-asg"
  launch_configuration = aws_launch_configuration.s3ich4n-chapter02-ex02-launchconfig.name
  vpc_zone_identifier = [
    aws_subnet.s3ich4n-chapter02-ex02-subnet1.id,
    aws_subnet.s3ich4n-chapter02-ex02-subnet2.id
  ]
  min_size = 3
  max_size = 10

  # 새 대상그룹을 지정 및 Healthcheck 변경 
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.s3ich4n-chapter02-ex02-alb-tg.arn]

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}
