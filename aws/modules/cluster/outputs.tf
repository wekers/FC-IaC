# output "private_dns" {
#   value = aws_instance.instances[0].private_dns
# }

output "lb_arn" {
  value = aws_lb.app_lb.arn

}
