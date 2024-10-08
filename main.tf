provider "aws" {
  region = var.aws_region
}

  # Get current AWS account info
data "aws_caller_identity" "current" {}

# Define the security group
resource "aws_security_group" "hw2_sshfromhome" {
  name        = var.security_group_name
  description = "EC2: ssh from home; http(s) from anywhere"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.home_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.meta_ip_mask]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.meta_ip_mask]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.meta_ip_mask]
  }
}

resource "aws_instance" "ec2_t2micro" {
  ami           = var.ami_ubuntu
  instance_type = var.instance_type

  key_name = var.key_name

  vpc_security_group_ids = [aws_security_group.hw2_sshfromhome.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "terraform-ec2-instance"
  }
}

# Random password for Secrets Manager
resource "random_password" "password" {
  length  = var.password_length
  special = true
}

# Create a secret in AWS Secrets Manager
# This name used cause other secret with name was created manually & marked as deleted before
resource "aws_secretsmanager_secret" "my_test_secret" {
  name = "my-test-secret_unique"
}

# Add random password to the secret
resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.my_test_secret.id
  secret_string = random_password.password.result
}