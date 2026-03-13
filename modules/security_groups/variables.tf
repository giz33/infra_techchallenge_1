variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "IP address allowed to SSH into EC2 (CIDR format)"
  type        = string
}
