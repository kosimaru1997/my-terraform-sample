# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name   = "my-sample-vpc"
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
    Name   = "public-${var.availability_zones[count.index]}"
    System = "terraform-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + 4)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name   = "private-${var.availability_zones[count.index]}"
    System = "terraform-subnet"
  }
}

# internet-gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "my-sample-gateway"
    System = "terraform-gateway"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "my-sample-route-table"
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