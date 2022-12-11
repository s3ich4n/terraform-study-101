output "alb_dns" {
  value       = aws_lb.ex8-file-layout-alb.dns_name
  description = "The DNS Address of the ALB"
}
