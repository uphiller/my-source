terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "ngrider" {
  source = "./modules/ngrider"
}

module "backend-app" {
  source = "./modules/backend-app"
}