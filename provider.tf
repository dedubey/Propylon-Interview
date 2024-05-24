terraform {
  required_version = "~> 1.3.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
  }
#  backend "s3" {
#    bucket         = "terraform-state-902362636025"
 #   dynamodb_table = "terraform-state-902362636025"
 #   encrypt        = true
#    key            = "s3/terraform-s3-state/terraform.tfstate"
#    region         = "us-west-2"
#    session_name   = "terraform-s3"
 # }
}

