## outputs in terraform 
 
 vpc-id" {
  value = aws_vpc.my_vpc.id
}

output "ssh_key" {
  description = "ssh key generated by terraform"
  sensitive = true
  value       = tls_private_key.dev_key.private_key_pem
}