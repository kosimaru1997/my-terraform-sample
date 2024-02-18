# data "aws_ecs_task_definition" "web" {
#   task_definition = aws_ecs_task_definition.dev_bukkaku_backend_taskdifinition.family
# }

resource "aws_ecs_service" "service" {
  name    = "koshimaru-sample-service"
  cluster = aws_ecs_cluster.cluster.arn
  // 初回実行時のみjsonを参照する
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 3600
  enable_execute_command            = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # codedeployで管理
  lifecycle {
    ignore_changes = [task_definition, load_balancer, desired_count, platform_version, deployment_maximum_percent, deployment_minimum_healthy_percent, force_new_deployment, enable_execute_command, launch_type, capacity_provider_strategy]
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = var.service_security_group_ids
    subnets          = var.service_subnet_list
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.container_name
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "sample_log" {
  name              = "koishimaru-sample-log-group"
  retention_in_days = 180
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_policy" {
  name               = "koshimaru-sample-scale-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_out_cooldown = 30
    scale_in_cooldown  = 60
  }
}
