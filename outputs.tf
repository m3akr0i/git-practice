output "ecr_repository_uri" {
  value = aws_ecr_repository.fastapi_app.repository_url
}