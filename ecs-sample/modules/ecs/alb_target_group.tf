resource "aws_lb_target_group" "blue" {
  name                 = "${var.target_group_name}-bule"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  health_check {
    path                = var.alb_health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

resource "aws_lb_target_group" "green" {
  name                 = "${var.target_group_name}-green"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  health_check {
    path                = var.alb_health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener_rule" "custom_header_limit" {
  listener_arn = var.alb_listener_arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 1
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = 0
      }
    }
  }
  condition {
    path_pattern { values = ["/*"] }
  }

  lifecycle {
    ignore_changes = [action]
  }
  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = ["custom-value-1111"]
    }
  }
}
