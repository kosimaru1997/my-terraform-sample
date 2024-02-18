resource "aws_lb" "alb" {
  name                       = var.alb_name
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 120
  enable_deletion_protection = false

  subnets = [
    var.public_subnet_1,
    var.public_subnet_2
  ]

  security_groups = [
    var.security_group_id
  ]
}

resource "aws_lb_listener" "http" {
  # HTTPでのアクセスを受け付ける
  port     = "80"
  protocol = "HTTP"

  load_balancer_arn = aws_lb.alb.id

  # 指定custom-header以外は弾く
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "headerの要件を満たしていません。"
      status_code  = "403"
    }
  }
}
