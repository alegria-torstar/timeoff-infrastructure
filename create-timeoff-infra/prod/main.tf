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

module "automated_content_lambdas" {
  source = "../../modules/ec2/create-delete-ASG"
  app_name = "timeoff"
  environment = "prod"
}