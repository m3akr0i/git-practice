resource "aws_ecr_repository" "fastapi_app" {
  name                 = "fastapi-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}