# Output the public IP of the EC2 instance
output "instance_ip" {
    value = aws_instance.ec2_t2micro.public_ip
}

# Output AWS Account name
output "account_name" {
    value = data.aws_caller_identity.current.account_id
}

# Output the secret manager ARN
output "secret_arn" {
    value = aws_secretsmanager_secret.my_test_secret.arn
}