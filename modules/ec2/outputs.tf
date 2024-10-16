output "instance_id" {
  value = aws_instance.ec2_t2micro.id
}

output "security_group_id" {
  value = aws_security_group.hw2_sshfromhome.id
}

output "instance_ip" {
  value = aws_instance.ec2_t2micro.public_ip
}