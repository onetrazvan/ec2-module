provider "aws" {
  region = var.region
}

resource "aws_vpc" "tfvpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.deployer}-terragrunt-vpc-${var.environment}"
  }
}

resource "aws_security_group" "aws-public-sg" {
  name   = "${var.deployer}-public-SG-${var.environment}"
  vpc_id = aws_vpc.tfvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "public_subnet" {
  source            = "./modules/subnet"
  cidr_block        = var.subnet_cidr
  vpc_id            = aws_vpc.tfvpc.id
  name              = "${var.deployer}-terragrunt-subnet-${var.environment}"
  availability_zone = var.availability_zone
  is_public         = true
}

resource "aws_instance" "tfinstance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.aws-public-sg.id]
  subnet_id              = module.public_subnet.subnet_id
  user_data              = templatefile("${path.module}/nginx-cloud-init.cfg", { package = "nginx" })

  tags = {
    Name = "${var.deployer}-terragrunt-instance-${var.environment}"
  }
}
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    Name = "${var.deployer}-terragrunt-igw-${var.environment}"
  }
}

resource "aws_route_table" "tf-routetable-public" {
  vpc_id = aws_vpc.tfvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }

  tags = {
    Name = "${var.deployer}-terragrunt-routetable-public-${var.environment}"
  }
}

resource "aws_route_table_association" "tf-routetable-assoc-public" {
  subnet_id      = module.public_subnet.subnet_id
  route_table_id = aws_route_table.tf-routetable-public.id
}

