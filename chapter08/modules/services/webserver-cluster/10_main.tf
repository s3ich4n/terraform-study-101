##### terraform_remote_state 를 가져오는 예시

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket_name
    key    = var.db_remote_state_key
    region = "ap-northeast-2"
  }
}

##### subnets

resource "aws_subnet" "webserver-subnet1" {
  vpc_id     = data.terraform_remote_state.db.outputs.vpc_id
  cidr_block = "10.100.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.env_type}-t101-webserver-subnet1"
  }
}

resource "aws_subnet" "webserver-subnet2" {
  vpc_id     = data.terraform_remote_state.db.outputs.vpc_id
  cidr_block = "10.100.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.env_type}-t101-webserver-subnet2"
  }
}


##### Internet gateways

resource "aws_internet_gateway" "ex4-file-layout-webserver-igw" {
  vpc_id = data.terraform_remote_state.db.outputs.vpc_id

  tags = {
    Name = "${var.env_type}-t101-webserver-igw"
  }
}

##### Route tables

resource "aws_route_table" "ex4-file-layout-webserver-rt" {
  vpc_id = data.terraform_remote_state.db.outputs.vpc_id

  tags = {
    Name = "${var.env_type}-t101-webserver-rt"
  }
}

resource "aws_route_table_association" "ex4-file-layout-webserver-rt-association1" {
  subnet_id      = aws_subnet.webserver-subnet1.id
  route_table_id = aws_route_table.ex4-file-layout-webserver-rt.id
}

resource "aws_route_table_association" "ex4-file-layout-webserver-rt-association2" {
  subnet_id      = aws_subnet.webserver-subnet2.id
  route_table_id = aws_route_table.ex4-file-layout-webserver-rt.id
}

resource "aws_route" "ex4-file-layout-webserver-default-route" {
  route_table_id         = aws_route_table.ex4-file-layout-webserver-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ex4-file-layout-webserver-igw.id
}

##### Security groups

resource "aws_security_group" "ex4-file-layout-webserver-sg" {
  vpc_id      = data.terraform_remote_state.db.outputs.vpc_id
  name        = "${var.ex4_cluster_name}-alb"
  description = "${var.env_type}-T101 study sg webserver"
}

resource "aws_security_group_rule" "ex4-file-layout-webserver-inbound" {
  type              = "ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ex4-file-layout-webserver-sg.id
}

resource "aws_security_group_rule" "ex4-file-layout-webserver-outbound" {
  type              = "egress"
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ex4-file-layout-webserver-sg.id
}

################################################
#
# ASG
#
################################################

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = local.http_port
    db_address  = data.terraform_remote_state.db.outputs.rds_address
    db_port     = data.terraform_remote_state.db.outputs.rds_port
  }
}

data "aws_ami" "ex4-file-layout-amazonlinux2" {
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

resource "aws_launch_configuration" "ex4-file-layout-launchconfig" {
  name_prefix                 = "${var.env_type}-t101-launchconfig-"
  image_id                    = data.aws_ami.ex4-file-layout-amazonlinux2.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ex4-file-layout-webserver-sg.id]
  associate_public_ip_address = true

  # Render the User Data script as a template
  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = local.http_port
    db_address  = data.terraform_remote_state.db.outputs.rds_address
    db_port     = data.terraform_remote_state.db.outputs.rds_port
  })

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ex4-file-layout-asg" {
  name                 = "${var.env_type}-ex4-file-layout-asg"
  health_check_type    = "ELB"
  target_group_arns    = [aws_lb_target_group.ex4-file-layout-albtg.arn]
  launch_configuration = aws_launch_configuration.ex4-file-layout-launchconfig.name
  vpc_zone_identifier = [
    aws_subnet.webserver-subnet1.id,
    aws_subnet.webserver-subnet2.id
  ]
  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "${var.env_type}-Name"
    value               = "${var.env_type}-terraform-asg"
    propagate_at_launch = true
  }
}

################################################
#
# ALB
#
################################################

resource "aws_lb" "ex4-file-layout-alb" {
  name               = "${var.env_type}-t101-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.webserver-subnet1.id,
    aws_subnet.webserver-subnet2.id
  ]
  security_groups = [aws_security_group.ex4-file-layout-webserver-sg.id]

  tags = {
    Name = "${var.env_type}-t101-alb"
  }
}

resource "aws_lb_listener" "ex4-file-layout-http" {
  load_balancer_arn = aws_lb.ex4-file-layout-alb.arn
  port              = local.http_port
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

resource "aws_lb_target_group" "ex4-file-layout-albtg" {
  name     = "t101-alb-tg"
  port     = local.http_port
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

resource "aws_lb_listener_rule" "ex4-file-layout-albrule" {
  listener_arn = aws_lb_listener.ex4-file-layout-http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ex4-file-layout-albtg.arn
  }
}
