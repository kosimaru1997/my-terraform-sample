output "id" {
  value = aws_lb.alb.id
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}

# output "certificate_arn" {
#   value = aws_acm_certificate.certificate.arn
# }


output "alb_listener_arn" {
  value = aws_lb_listener.http.arn
}