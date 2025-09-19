provider "aws" {
  region = var.region
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  project  = var.project
}

module "ecr" {
  source  = "./modules/ecr"
  project = var.project
}

module "alb" {
  source   = "./modules/alb"
  project  = var.project
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.public_subnets
}

module "ecs" {
  source                 = "./modules/ecs"
  project                = var.project
  region                 = var.region
  desired_count          = var.desired_count
  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.public_subnets
  alb_target_group_arn   = module.alb.target_group_arn
  ecr_repo_url           = module.ecr.repository_url
}