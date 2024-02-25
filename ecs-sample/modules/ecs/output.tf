output "cluster_name" {
    value = aws_ecs_cluster.cluster.name
}
output "service_name" {
    value = aws_ecs_service.service.name
}

output "target_group_blue_name" {
  value = aws_lb_target_group.blue.name
}
output "target_group_green_name" {
  value = aws_lb_target_group.green.name
}