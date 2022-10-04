
# aws providers terraform


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}



### ec2 instance creation  app_server-pub

resource "aws_instance" "app_server-pub" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = var.ec2-type
  key_name = var.generated_key_name
  security_groups = [ aws_security_group.allow-sg-pub.id ]
  subnet_id = aws_subnet.public-sub.id
  associate_public_ip_address = true
  user_data = "user.tpl"
  #  count = 2

  tags = merge(
    local.tags,
    {
      #    Name = "pub-ec2-${count.index}"
      Name="pub-ec2"
      name= "devops-raju"
    })
}

## terraform-key-pair ssh-keygen  generated_key

resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.dev_key.public_key_openssh

  provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./'${var.generated_key_name}'.pem
      chmod 400 ./'${var.generated_key_name}'.pem
    EOT
  }

}


#creating elastic ip
resource "aws_eip" "nat-eip" {
  vpc=true
}


# creating vpc my-vpc


resource "aws_vpc" "my_vpc" {
  cidr_block = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "my-vpc"
  }
}

#### aws subnets public-sub and private-sub 


resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "172.31.0.0/28"
  availability_zone = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch="true"
  map_public_ip_on_launch = "true"
  tags = merge(
    local.tags,
    {
      Name = "my_vpc-pub-sub"
    })
}


resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "172.31.0.16/28"
  availability_zone = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch="true"
  tags = merge(
    local.tags,
    {
      Name = "my_vpc-pvt-sub"
    })
}


##### aws internet gate way

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    local.tags,{
      Name = "my-vpc-igw"
    })
}


### aws nat gateway 

resource "aws_nat_gateway" "dev-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.public-sub.id
  tags={
    Name="Nat Gateway"
  }
  depends_on = [aws_internet_gateway.my_vpc_igw]
}



# aws internet gateway attachment not working in this version



#resource "aws_internet_gateway_attachment" "igw-attach" {
#  internet_gateway_id=aws_internet_gateway.my_vpc_igw.id
#  vpc_id=aws_vpc.my_vpc.id
#}

###################### aws route tables and association 

resource "aws_route_table" "my-pvt-rt" {
  vpc_id =aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-nat.id
  }
  tags =merge(
    local.tags,
    {
      Name="pvt-RT"
    })
}

resource "aws_route_table_association" "sub-pub" {
  subnet_id =aws_subnet.public-sub.id
  route_table_id = aws_route_table.my-pub-rt.id
}
resource "aws_route_table_association" "sub-pvt" {
  subnet_id =aws_subnet.private-sub.id
  route_table_id = aws_route_table.my-pvt-rt.id
}
resource "aws_route_table" "my-pub-rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = merge(
    local.tags,
    {
      Name = "pub-rt"
    })
}



############################## aws security groups


resource "aws_security_group" "allow-sg-pub" {
  name        = "allow-sg-pub"
  description = "Allow SSH inbound connections"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allowing all ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_sg-pub"
  }

}

resource "aws_security_group" "allow-sg-pvt" {
  name        = "allow-sg-pvt"
  description = "Allow SSH inbound connections"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allowing with in vpc "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.31.0.0/26"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_sg-pvt"
  }

}

###################################### aws ALB load balancers terraform code  security groups public and private vpc attachments 



resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.my_vpc.id

    ingress {
from_port   = 443
to_port     = 443
protocol    = "tcp"
cidr_blocks = ["172.0.0.0/26"]
}

ingress {
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["172.0.0.0/26"]
}

# Allow all outbound traffic.
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "alb-sg"
}
}


####################### aws ALB creation 



resource "aws_alb" "alb" {
  name            = "terraform-alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.public-sub.id,aws_subnet.private-sub.id]
  tags = {
    Name = "terraform-alb"
  }
}

 
 
########### outputs in terraform 
 
 
 
output "vpc-id" {
  value = aws_vpc.my_vpc.id
}

output "ssh_key" {
  description = "ssh key generated by terraform"
  sensitive = true
  value       = tls_private_key.dev_key.private_key_pem
}



#################### variables in terraform 


variable "ec2-type" {
  description = "Ec2 Instance Type"
  type=string
  default = "t2.micro"
}


variable "generated_key_name" {
  type        = string
  default     = "terraform-key-pair"
  description = "Key-pair generated by Terraform"
}

############# local variable in aws terraform 


locals {
  tags= {
    env="dev"
    project = "aws-vpc"
  }
}

