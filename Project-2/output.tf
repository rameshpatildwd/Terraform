output "public-ip" {
  value = aws_instance.public-instance.public_ip
}

output "public_dns" {
  value = aws_instance.public-instance.public_dns
}

output "secuity-group" {
  value = aws_instance.public-instance.security_groups
}
