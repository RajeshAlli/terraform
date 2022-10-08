
#creating elastic ip

resource "aws_eip" "nat-eip" {
  vpc=true
}


## aws internet gate way

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




## aws ALB load balancers terraform code  security groups public and private vpc attachments 



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


## aws ALB creation 



resource "aws_alb" "alb" {
  name            = "terraform-alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.public-sub.id,aws_subnet.private-sub.id]
  tags = {
    Name = "terraform-alb"
  }
}

 
 




