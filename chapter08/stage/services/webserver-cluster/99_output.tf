output "alb_dns" {
  description = "DNS Address of the ALB"
  value       = module.webserver_cluster.alb_dns
}
