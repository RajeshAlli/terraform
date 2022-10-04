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

 resource "aws_launch_configuration" "sample" {
  image_id          = "ami-04afe279c8bff9ed8"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.efs.id,
  ]

  user_data = <<-EOF
              #!/bin/bash
              mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs_mount.file_system_dns_name}:/ /your/mount/point/
              EOF
  lifecycle {
    create_before_destroy = true
  }
}