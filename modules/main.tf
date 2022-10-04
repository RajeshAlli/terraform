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
  cidr = "172.31.0.0/18"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["172.31.1.0/28", "172.31.2.0/28"]
  public_subnets  = ["172.31.101.0/28", "172.31.102.0/28"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


