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

module "global" {
  source = "./modules/global"
}

module "network" {
  source = "./modules/network"
}

module "opensearch" {
  source = "./modules/opensearch"
}
