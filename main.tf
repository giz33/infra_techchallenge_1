# Main Terraform configuration that orchestrates all modules

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  allowed_ssh_ip = var.allowed_ssh_ip
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name      = var.project_name
  instance_type     = var.ec2_instance_type
  key_pair_name     = var.key_pair_name
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security_groups.ec2_security_group_id
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  subnet_ids        = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  security_group_id = module.security_groups.rds_security_group_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}
