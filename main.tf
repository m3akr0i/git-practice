provider "aws" {
  region = var.aws_region
}

# Get current AWS account info
data "aws_caller_identity" "current" {}

# Random password for Secrets Manager
resource "random_password" "password" {
  length  = var.password_length
  special = true
}

# Create a secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "my_test_secret" {
  name = "my-test-secret_unique"
}

# Add random password to the secret
resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.my_test_secret.id
  secret_string = random_password.password.result
}

# Module for EC2 instance and Security Group
module "ec2_instance" {
  source            = "./modules/ec2"
  ami_ubuntu        = var.ami_ubuntu
  instance_type     = var.instance_type
  key_name          = var.key_name
  security_group_name = var.security_group_name
  home_ip           = var.home_ip
  meta_ip_mask      = var.meta_ip_mask
  secret_id         = aws_secretsmanager_secret.my_test_secret.id
}

output "instance_ip" {
  value = module.ec2_instance.instance_ip
}