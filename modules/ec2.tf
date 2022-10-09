# create "ec2 instance"

module "aws_instance"  {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "module-instance"

  ami                    = "ami-087c17d1fe0178315"
  instance_type          = "t2.micro"
  key_name               = "module-key"
  monitoring             = true
  vpc_security_group_ids = ["aws_security_group.ec2.id"]
  subnet_id              = "aws_subnet_id.ec2.id"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}