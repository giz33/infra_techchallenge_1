output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.app.public_dns
}

output "ec2_instance_id" {
  description = "ID of EC2 instance"
  value       = aws_instance.app.id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.mariadb.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.mariadb.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.mariadb.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.mariadb.db_name
}

output "ssh_connection_command" {
  description = "Command to SSH into EC2 instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.app.public_ip}"
}

output "app_url" {
  description = "Application URL (port 5000)"
  value       = "http://${aws_instance.app.public_ip}:5000"
}
