output "alb_dns" {
  value = module.alb.alb_dns
}

output "ecr_repo_url" {
  value = module.ecr.repository_url
}