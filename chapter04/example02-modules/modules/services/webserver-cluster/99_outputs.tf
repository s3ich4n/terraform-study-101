output "alb_dns" {
  value       = aws_lb.ex4-file-layout-alb.dns_name
  description = "The DNS Address of the ALB"
}
