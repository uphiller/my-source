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

module "eb" {
  source = "./modules/eb"
  vpc_id = module.network.vpc_id
  subnet_private_1 = module.network.subnet_private_1_id
  subnet_private_2 = module.network.subnet_private_2_id
  subnet_public_1 = module.network.subnet_public_1_id
  subnet_public_2 = module.network.subnet_public_2_id
}