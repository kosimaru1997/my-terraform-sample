data "aws_iam_policy" "code_deploy_for_ecs_policy" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
# CodeDeploy用のIAMロール
resource "aws_iam_role" "code_deploy_for_ecs_role" {
  name = "koshimaru-sample-code-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.code_deploy_for_ecs_role.name
  policy_arn = data.aws_iam_policy.code_deploy_for_ecs_policy.arn
}