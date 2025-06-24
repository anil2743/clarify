output "instance_ip" {
  value = aws_eip.web_eip.public_ip
}
