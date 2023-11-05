terraform {
  backend "s3" {
    bucket = "terraform-project-1-2023"
    key    = "Project-1/terraform.tfstate"
    region = "us-east-1"
  }
}


