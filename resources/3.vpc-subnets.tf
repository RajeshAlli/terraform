## creating vpc my-vpc


resource "aws_vpc" "my_vpc" {
  cidr_block = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "my-vpc"
  }
}

## aws subnets public-sub and private-sub 


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
