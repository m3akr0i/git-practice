terraform {
  backend "s3" {
    bucket         = "hw6-terraform-state"           # Your S3 bucket name
    key            = "dev/terraform.tfstate"        # Path to the state file in S3
    region         = "us-east-1"                    # S3 bucket region
  }
}