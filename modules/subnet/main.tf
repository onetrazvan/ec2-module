resource "aws_subnet" "mysubnet" {
  cidr_block              = var.cidr_block
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = var.is_public
  availability_zone       = var.availability_zone

  tags = {
    Name = var.name
  }
}