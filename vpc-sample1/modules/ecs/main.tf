resource "aws_ecs_cluster" "cluster" {
  name = "koshimaru-sample-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "main" {
  family = var.task_family

  # データプレーンの選択
  requires_compatibilities = ["FARGATE"]

  # ECSタスクが使用可能なリソースの上限
  # タスク内のコンテナはこの上限内に使用するリソースを収める必要があり、メモリが上限に達した場合OOM Killer にタスクがキルされる
  cpu    = "256"
  memory = "512"

  # ECSタスクのネットワークドライバ
  # Fargateを使用する場合は"awsvpc"決め打ち
  network_mode = "awsvpc"

  # 起動するコンテナの定義
  # 「nginxを起動し、80ポートを開放する」設定を記述。
    container_definitions = templatefile("./modules/ecs/container_definitions.tpl", {
    container_name    = var.container_name,
  })
  execution_role_arn = aws_iam_role.koshimaru-sample-ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/koshimaru-ecs-sample" # This should match the name in your task definition

  retention_in_days = 7 # Optional: Set the retention policy for your logs
}