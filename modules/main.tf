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

# vpc

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "172.31.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  private_subnets = ["172.31.0.0/24", "172.31.0.18/24"]
  public_subnets  = ["172.31.0.16/24", "172.31.0.48/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


