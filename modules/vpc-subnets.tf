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
  cidr = "192.0.0.0/24"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["192.0.0.0/25", "192.0.0.0/25"]
  public_subnets  = ["192.0.0.128/25", "192.0.0.128/25"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


