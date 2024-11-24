resource "aws_db_instance" "myapp_db" {
  identifier         = var.identifier
  engine             = var.engine
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  username           = var.username
  password           = var.password
  skip_final_snapshot = true
}