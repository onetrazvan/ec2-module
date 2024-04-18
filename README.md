
```main.tf
module "ec2" {
  source = "github.com/onetrazvan/ec2-module.git"
  region           = "eu-west-3"
  environment      = "dev"
  instance_type    = "t2.micro"
  ami              = "ami-00c71bd4d220aa22a"
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  availability_zone = "eu-west-3a"
  deployer          = "Razvan"
}



output "ec2-public-ip" {
  value = module.ec2.instance_public_ip
}
```
