module "vpc" {
  source = "./modules/vpc"
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

module "alb_sg" {
  source                  = "terraform-aws-modules/security-group/aws"
  version                 = "4.17.2"
  name                    = "koshimaru-sample-alb-sg"
  vpc_id                  = module.vpc.vpc_id
  ingress_prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  ingress_with_cidr_blocks = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = 6 # "tcp"
      description     = "Allow inbound traffic from CloudFront"
      prefix_list_ids = data.aws_ec2_managed_prefix_list.cloudfront.id
    }
  ]
  egress_rules = ["all-all"]
}

module "alb" {
  source            = "./modules/alb"
  alb_name          = "koshimaru-sample-alb"
  public_subnet_1   = module.vpc.public_subnets[0]
  public_subnet_2   = module.vpc.public_subnets[1]
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.alb_sg.security_group_id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  alb_id = module.alb.id
  alb_dns = module.alb.alb_dns
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "koshimaru-sample-ecr"
}

module "ecs_app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"
  name    = "koshimaru-sample-ecs-app-sg"
  vpc_id  = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
}

module "ecs" {
  source                     = "./modules/ecs"
  task_family                = "koshimaru-sample-task"
  container_name             = "sample-app"
  vpc_id                     = module.vpc.vpc_id
  service_security_group_ids = [module.ecs_app_sg.security_group_id]
  service_subnet_list        = [module.vpc.private_subnets[0]]
  target_group_name          = "koshimaru-sample-tg"
  alb_listener_arn           = module.alb.alb_listener_arn
  alb_health_check_path      = "/index.html"
}

module "codedeploy" {
  source = "./modules/codedeploy"
  application_name = "koshimaru-sample-app"
  deploy_group_name = "koshimaru-sample-deployment-group"
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
  listener_arn = module.alb.alb_listener_arn
  target_group_name1 = module.ecs.target_group_blue_name
  target_group_name2 = module.ecs.target_group_green_name
}
