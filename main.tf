provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "random_password" "password" {
  length  = var.password_length
  special = true
}

resource "aws_secretsmanager_secret" "my_test_secret" {
  name = "my-test-secret_unique-c"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.my_test_secret.id
  secret_string = random_password.password.result
}

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

module "rds_instance" {
  source             = "./modules/rds"
  identifier         = "myapp-db"
  engine             = "mysql"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = "admin"
  password           = "nkp8dy3WLoBzRU2"
}

output "instance_ip" {
  value = module.ec2_instance.instance_ip
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_security_group"
  description = "Allow HTTP access"
  vpc_id      = "vpc-0534eba8f0fccca70"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-0ddecd7cce1de8e55", "subnet-0bad8a1096921e468", "subnet-0202f5cebf5f3c58e", "subnet-0993e407ea571d980", "subnet-0c60d04012f245ab4", "subnet-033e7893eeb886211"]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_target_group" {
  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0534eba8f0fccca70"

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = var.ami_ubuntu
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [module.ec2_instance.security_group_id]
}

resource "aws_autoscaling_group" "app_asg" {
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  min_size         = 1
  max_size         = 1
  desired_capacity = 1
  vpc_zone_identifier  = ["subnet-0ddecd7cce1de8e55", "subnet-0bad8a1096921e468", "subnet-0202f5cebf5f3c58e", "subnet-0993e407ea571d980", "subnet-0c60d04012f245ab4", "subnet-033e7893eeb886211"]
  target_group_arns    = [aws_lb_target_group.app_target_group.arn]

  health_check_type        = "EC2"
  health_check_grace_period = 300
}


