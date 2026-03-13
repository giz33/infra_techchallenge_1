variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "techchallenge1-fiap"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "keypair-techchallenge1-fiap"
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  default     = "fiaptech34233!"
  sensitive   = true
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "togglemaster"
}

variable "allowed_ssh_ip" {
  description = "IP address allowed to SSH into EC2 (CIDR format, e.g., 203.0.113.0/32)"
  type        = string
  default     = "0.0.0.0/0" # Change this to your specific IP for security
}
