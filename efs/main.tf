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

resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EFS"
   }
 }

# creating vpc my-vpc-efs

resource "aws_vpc" "my-vpc-efs" {
  cidr_block = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "my-vpc-efs"
  }
}

#### aws subnets public-sub and private-sub


resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.my-vpc-efs.id
  cidr_block = "192.0.0.0/25"
  availability_zone = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch="true"
  map_public_ip_on_launch = "true"
  tags = merge(
    {
      Name = "public-sub-efs"
    })
}


resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.my-vpc-efs.id
  cidr_block = "192.0.0.128/25"
  availability_zone = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch="true"
  tags = merge(
    {
      Name = "private-sub-efs"
    })
}



### aws security groups


resource "aws_security_group" "allow-sg-pub" {
  name        = "allow-sg-pub"
  description = "Allow SSH inbound connections"
  vpc_id      = aws_vpc.my-vpc-efs.id

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
    Name = "allow_sg-pub-efs"
  }

}

resource "aws_security_group" "allow-sg-pvt" {
  name        = "allow-sg-pvt"
  description = "Allow SSH inbound connections"
  vpc_id      = aws_vpc.my-vpc-efs.id

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
    Name = "allow_sg-pvt-efs"
  }

}

resource "aws_instance" "efsinstance" {
    ami = "ami-087c17d1fe0178315"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet[0].id
    associate_public_ip_address= true
    vpc_security_group_ids = [ aws_vpc.my-vpc-efs.id ]
    key_name="efs"
    tags= {
        Name = "efsinstance"
    }
}