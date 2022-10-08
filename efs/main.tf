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

resource "aws_vpc" "my_vpc-efs" {
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
  cidr_block = "172.31.0.0/28"
  availability_zone = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch="true"
  map_public_ip_on_launch = "true"
  tags = merge(
    local.tags,
    {
      Name = "public-sub-efs"
    })
}


resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.my-vpc-efs.id
  cidr_block = "172.31.0.16/28"
  availability_zone = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch="true"
  tags = merge(
    local.tags,
    {
      Name = "private-sub-efs"
    })
}