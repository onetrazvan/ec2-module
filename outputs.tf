output "vpc_id" {
  value = aws_vpc.tfvpc.id
}

output "public_subnet_id" {
  value = module.public_subnet.subnet_id
}

output "instance_public_ip" {
  value = aws_instance.tfinstance.public_ip
}

output "environment" {
  value = var.environment
}