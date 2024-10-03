variable "aws_region" {
    description = "AWS region to deploy resources"
    default     = "us-east-1"
}

variable "home_ip" {
    description = "Home IP address for SSH access"
    default     = "194.62.137.21/32"
}

variable "key_name" {
    description = "The name of the SSH key pair"
    default     = "test-mykola1_pair"
}

variable "instance_type" {
    description = "EC2 instance type"
    default     = "t2.micro"
}

variable "security_group_name" {
    description = "Name of the security group"
    default     = "ssh_access_from_home-hw2"
}

variable "password_length" {
    description = "Password length"
    default = "16" 
}

variable "ami_ubuntu" {
    description = "AMI Id"
    default = "ami-06ceb6b6dca8ff42f"
}

variable "meta_ip_mask" {
    description = "Loopback IP"
    default = "0.0.0.0/0" 
}