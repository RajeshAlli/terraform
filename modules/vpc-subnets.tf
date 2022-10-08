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

# created vpc

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "module-vpc"
  cidr = "10.0.0.0/26"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.0.8/28"]
  public_subnets  = ["10.0.0.0/28"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


