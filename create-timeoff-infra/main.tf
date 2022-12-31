terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
    backend "s3" {
      bucket = "terraform-luis-state"
      region = "us-east-1"
      key    = "terraform/prod/timeoff-app/terraform.tfstate"
    }
}
