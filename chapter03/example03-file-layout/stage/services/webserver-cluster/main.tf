terraform {
  backend "s3" {
    bucket         = "s3ich4n-ex3-file-layout-bucket"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week3-files"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

##### terraform_remote_state 를 가져오는 예시

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "s3ich4n-ex3-file-layout-bucket"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

##### subnets

resource "aws_subnet" "webserver-subnet1" {
  vpc_id     = data.terraform_remote_state.db.outputs.vpc_id
  cidr_block = "10.10.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "t101-webserver-subnet1"
  }
}

resource "aws_subnet" "webserver-subnet2" {
  vpc_id     = data.terraform_remote_state.db.outputs.vpc_id
  cidr_block = "10.10.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "t101-webserver-subnet2"
  }
}


##### Internet gateways

resource "aws_internet_gateway" "ex3-file-layout-webserver-igw" {
  vpc_id = data.terraform_remote_state.db.outputs.vpc_id

  tags = {
    Name = "t101-webserver-igw"
  }
}

##### Route tables

resource "aws_route_table" "ex3-file-layout-webserver-rt" {
  vpc_id = data.terraform_remote_state.db.outputs.vpc_id

  tags = {
    Name = "t101-webserver-rt"
  }
}

resource "aws_route_table_association" "ex3-file-layout-webserver-rt-association1" {
  subnet_id      = aws_subnet.webserver-subnet1.id
  route_table_id = aws_route_table.ex3-file-layout-webserver-rt.id
}

resource "aws_route_table_association" "ex3-file-layout-webserver-rt-association2" {
  subnet_id      = aws_subnet.webserver-subnet2.id
  route_table_id = aws_route_table.ex3-file-layout-webserver-rt.id
}

resource "aws_route" "ex3-file-layout-webserver-default-route" {
  route_table_id         = aws_route_table.ex3-file-layout-webserver-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ex3-file-layout-webserver-igw.id
}

##### Security groups

resource "aws_security_group" "ex3-file-layout-webserver-sg" {
  vpc_id      = data.terraform_remote_state.db.outputs.vpc_id
  name        = "T101 sg webserver"
  description = "T101 study sg webserver"
}

resource "aws_security_group_rule" "ex3-file-layout-webserver-inbound" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ex3-file-layout-webserver-sg.id
}

resource "aws_security_group_rule" "ex3-file-layout-webserver-outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ex3-file-layout-webserver-sg.id
}


################################################
#
# ASG
#
################################################

data "template_file" "user_data" {
  template = file("user-data.sh")

  vars = {
    server_port = 8080
    db_address  = data.terraform_remote_state.db.outputs.rds_address
    db_port     = data.terraform_remote_state.db.outputs.rds_port
  }
}

data "aws_ami" "ex3-file-layout-amazonlinux2" {
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

resource "aws_launch_configuration" "ex3-file-layout-launchconfig" {
  name_prefix                 = "t101-launchconfig-"
  image_id                    = data.aws_ami.ex3-file-layout-amazonlinux2.id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.ex3-file-layout-webserver-sg.id]
  associate_public_ip_address = true

  # Render the User Data script as a template
  user_data = templatefile("user-data.sh", {
    server_port = 8080
    db_address  = data.terraform_remote_state.db.outputs.rds_address
    db_port     = data.terraform_remote_state.db.outputs.rds_port
  })

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ex3-file-layout-asg" {
  name                 = "ex3-file-layout-asg"
  health_check_type    = "ELB"
  target_group_arns    = [aws_lb_target_group.ex3-file-layout-albtg.arn]
  launch_configuration = aws_launch_configuration.ex3-file-layout-launchconfig.name
  vpc_zone_identifier = [
    aws_subnet.webserver-subnet1.id,
    aws_subnet.webserver-subnet2.id
  ]
  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}

################################################
#
# ALB
#
################################################

resource "aws_lb" "ex3-file-layout-alb" {
  name               = "t101-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.webserver-subnet1.id,
    aws_subnet.webserver-subnet2.id
  ]
  security_groups = [aws_security_group.ex3-file-layout-webserver-sg.id]

  tags = {
    Name = "t101-alb"
  }
}

resource "aws_lb_listener" "ex3-file-layout-http" {
  load_balancer_arn = aws_lb.ex3-file-layout-alb.arn
  port              = 8080
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - s3ich4n's T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "ex3-file-layout-albtg" {
  name     = "t101-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.db.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "ex3-file-layout-albrule" {
  listener_arn = aws_lb_listener.ex3-file-layout-http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ex3-file-layout-albtg.arn
  }
}

output "myalb_dns" {
  value       = aws_lb.ex3-file-layout-alb.dns_name
  description = "The DNS Address of the ALB"
}
