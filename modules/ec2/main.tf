variable "ami_ubuntu" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_group_name" {}
variable "home_ip" {}
variable "meta_ip_mask" {}

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

variable "secret_id" {}

resource "aws_instance" "ec2_t2micro" {
  ami           = var.ami_ubuntu
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.hw2_sshfromhome.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Install AWS CLI to retrieve secrets
              yum install aws-cli -y

              # Retrieve secret from AWS Secrets Manager and save it to the .env file
              secret=$(aws secretsmanager get-secret-value --secret-id ${var.secret_id} --query SecretString --output text)
              echo $secret > /home/ec2-user/.env

              # Optional: set environment variables from .env
              export $(grep -v '^#' /home/ec2-user/.env | xargs)
              EOF

  tags = {
    Name = "terraform-ec2-instance"
  }
}