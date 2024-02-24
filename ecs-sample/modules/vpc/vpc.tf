# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "20.0.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name   = "koshimaru-sample-vpc"
    System = "terraform-vpc"
  }
}

# Subnet
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name   = "koshimaru-public-${var.availability_zones[count.index]}"
    System = "terraform-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + 4)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name   = "koshimaru-private-${var.availability_zones[count.index]}"
    System = "terraform-subnet"
  }
}

# internet-gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "koshimaru-sample-gateway"
    System = "terraform-gateway"
  }
}

# Route Table
# Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "koshimaru-sample-route-table"
    System = "terraform-rote-table"
  }
}
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.gateway.id
}
# Associate public subnet
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "20.0.10.0/24"
    # ローカルゲートウェイを指定
    gateway_id = "local"
  }

  tags = {
    Name = "koshimaru-sample-private-route-table"
  }
}
# Associate private subnet
resource "aws_route_table_association" "parivate" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# VPC Endpoint
# ECR Docker Endpoint for pulling images from ECR
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecr_vpc_sg.id]

  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-vpc-endpoint"
  }
}

# ECR API Endpoint for ECR API calls
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecr_vpc_sg.id]

  private_dns_enabled = true

  tags = {
    Name = "ecr-api-vpc-endpoint"
  }
}

# SSM Messages VPC Endpoint for ECS Exec
resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecr_vpc_sg.id]

  private_dns_enabled = true

  tags = {
    Name = "ssm-messages-vpc-endpoint"
  }
}

# S3 Gateway Endpoint for ECR to store images on S3
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  # ルートテーブルは後で作成する
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "s3-gateway-vpc-endpoint"
  }
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type  = "Interface" # This assumes that CloudWatch Logs requires an interface endpoint
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecr_vpc_sg.id]

  private_dns_enabled = true

  tags = {
    Name = "cloudwatch-logs-vpc-endpoint"
  }
}

# Security Group for ECR VPC Endpoints
resource "aws_security_group" "ecr_vpc_sg" {
  name        = "ecr-vpc-endpoint-sg"
  description = "Security Group for ECR VPC Endpoints"
  vpc_id      = aws_vpc.vpc.id

  # ECRおよびS3へのアクセスを許可するインバウンドルール
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecr-vpc-endpoint-sg"
  }
}
