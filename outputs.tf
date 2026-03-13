output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = module.ec2.public_dns
}

output "ec2_instance_id" {
  description = "ID of EC2 instance"
  value       = module.ec2.instance_id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = module.rds.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.database_name
}

output "ssh_connection_command" {
  description = "Command to SSH into EC2 instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${module.ec2.public_ip}"
}

output "app_url" {
  description = "Application URL (port 5000)"
  value       = "http://${module.ec2.public_ip}:5000"
}
