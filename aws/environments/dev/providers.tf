terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
  }

  backend "s3" {
    bucket         = "fernando-fullcycle-terraform"
    key            = "states/terraform.dev.tfstate"
    region         = "us-west-2"
    profile        = "default"
    dynamodb_table = "tf-state-locking"
  }

  #required_version = "~> 1.14.1"
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}
