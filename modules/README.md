# Terraform Modules

This directory contains reusable Terraform modules for infrastructure components.

## Module Structure

### VPC Module (`modules/vpc/`)
Creates VPC infrastructure including:
- VPC with DNS support
- Internet Gateway
- Public subnet (10.0.1.0/24)
- Two private subnets (10.0.2.0/24, 10.0.3.0/24)
- Route tables and associations

**Inputs:**
- `project_name` - Project name for tagging
- `vpc_cidr` - CIDR block for VPC

**Outputs:**
- `vpc_id` - VPC ID
- `public_subnet_id` - Public subnet ID
- `private_subnet_1_id` - Private subnet 1 ID
- `private_subnet_2_id` - Private subnet 2 ID

### Security Groups Module (`modules/security_groups/`)
Creates security groups for:
- EC2 instance (SSH, HTTP, HTTPS, port 5000)
- RDS instance (PostgreSQL port 5432)

**Inputs:**
- `project_name` - Project name for tagging
- `vpc_id` - VPC ID
- `allowed_ssh_ip` - IP address allowed for SSH

**Outputs:**
- `ec2_security_group_id` - EC2 security group ID
- `rds_security_group_id` - RDS security group ID

### EC2 Module (`modules/ec2/`)
Creates EC2 instance with:
- Amazon Linux 2023 AMI
- Python 3, pip, Docker, Docker Compose
- 30GB gp3 root volume

**Inputs:**
- `project_name` - Project name for tagging
- `instance_type` - EC2 instance type
- `key_pair_name` - SSH key pair name
- `subnet_id` - Subnet ID for EC2
- `security_group_id` - Security group ID

**Outputs:**
- `instance_id` - EC2 instance ID
- `public_ip` - Public IP address
- `public_dns` - Public DNS name

### RDS Module (`modules/rds/`)
Creates RDS PostgreSQL instance with:
- PostgreSQL 16
- db.t4g.micro instance
- 20GB gp2 storage
- Private subnet deployment

**Inputs:**
- `project_name` - Project name for tagging
- `subnet_ids` - List of subnet IDs for RDS subnet group
- `security_group_id` - Security group ID
- `db_name` - Database name
- `db_username` - Database username
- `db_password` - Database password (sensitive)
- `engine_version` - PostgreSQL version (default: "16")
- `instance_class` - RDS instance class (default: "db.t4g.micro")
- `allocated_storage` - Storage in GB (default: 20)

**Outputs:**
- `endpoint` - RDS endpoint
- `address` - RDS address
- `port` - RDS port
- `database_name` - Database name

## Usage

Modules are called from the root `main.tf` file. Each module is independent and can be reused across different environments (dev, staging, prod).

Example:
```hcl
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}
```

## Benefits of Modular Structure

1. **Reusability**: Modules can be reused across different environments
2. **Maintainability**: Changes to a component are isolated to its module
3. **Testability**: Each module can be tested independently
4. **Scalability**: Easy to add new environments or components
5. **Organization**: Clear separation of concerns
