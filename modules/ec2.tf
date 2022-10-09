# create "ec2 instance"

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "module-instance"

  ami                    = "ami-087c17d1fe0178315"
  instance_type          = "t2.micro"
  key_name               = "module-key"
  monitoring             = true
  vpc_security_group_ids = ["aws_security_group.ec2.id"]
  #subnet_id              = "aws_subnet.ec2.id"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server-module"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = "aws_vpc.vpc.id"

  ingress_cidr_blocks = ["10.10.0.0/16"]
}