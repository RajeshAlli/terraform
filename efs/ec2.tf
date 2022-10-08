## create "ec2 instance" 

 resource "aws_instance" "testinstance" {
    ami = "ami-087c17d1fe0178315"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet[0].id
    associate_public_ip_address= true
    vpc_security_group_ids = [ aws_security_group.ec2.id ]
    key_name= var.generated_key_name
    tags= {
        Name = "testinstance"
    }
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







