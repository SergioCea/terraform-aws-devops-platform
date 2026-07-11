terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = ">= 1.15.6"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}