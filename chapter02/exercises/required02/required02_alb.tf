resource "aws_lb" "s3ich4n-chapter02-ex02-alb" {
  name               = "t101-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.s3ich4n-chapter02-ex02-subnet1.id,
    aws_subnet.s3ich4n-chapter02-ex02-subnet2.id
  ]
  security_groups = [aws_security_group.s3ich4n-chapter02-ex02-sg.id]

  tags = {
    Name = "t101-alb"
  }
}

resource "aws_lb_listener" "s3ich4n-chapter02-ex02-http-listener" {
  # ARN? Amazon Resource Number, AWS 서비스 내 리소스의 고유식별값
  load_balancer_arn = aws_lb.s3ich4n-chapter02-ex02-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 study(s3ich4n)"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "s3ich4n-chapter02-ex02-alb-tg" {
  name     = "t101-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.s3ich4n-chapter02-ex02-vpc.id

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

output "s3ich4n-chapter02-ex02-alb_dns" {
  value       = aws_lb.s3ich4n-chapter02-ex02-alb.dns_name
  description = "The DNS Address of the ALB"
}
