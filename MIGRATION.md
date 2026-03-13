# Migration Guide: Flat to Modular Structure

## Overview

The infrastructure has been refactored from a flat structure to a **modular structure**. This is a **breaking change** that requires careful migration of existing infrastructure.

## What Changed

### Before (Flat Structure)
```
.
├── vpc.tf
├── security_groups.tf
├── ec2.tf
├── rds.tf
├── user_data.sh
└── ...
```

### After (Modular Structure)
```
.
├── main.tf              # Orchestrates all modules
├── modules/
│   ├── vpc/
│   ├── security_groups/
│   ├── ec2/
│   └── rds/
└── ...
```

## Migration Options

### Option 1: Destroy and Recreate (Recommended for Dev/Test)

**⚠️ WARNING**: This will destroy all existing infrastructure and data!

```bash
# 1. Checkout the old code (before modular refactor)
git checkout <previous-commit>

# 2. Destroy existing infrastructure
terraform destroy

# 3. Checkout the new modular code
git checkout main

# 4. Initialize new modules
terraform init

# 5. Deploy with new structure
terraform apply
```

### Option 2: State Migration (Advanced - For Production)

If you have production data and cannot afford downtime, you'll need to migrate the Terraform state:

```bash
# 1. Backup existing state
terraform state pull > backup-state.json

# 2. Initialize new modular structure
terraform init

# 3. Move resources to new module paths
terraform state mv aws_vpc.main module.vpc.aws_vpc.main
terraform state mv aws_internet_gateway.main module.vpc.aws_internet_gateway.main
terraform state mv aws_subnet.public module.vpc.aws_subnet.public
terraform state mv aws_subnet.private_1 module.vpc.aws_subnet.private_1
terraform state mv aws_subnet.private_2 module.vpc.aws_subnet.private_2
terraform state mv aws_route_table.public module.vpc.aws_route_table.public
terraform state mv aws_route_table_association.public module.vpc.aws_route_table_association.public

terraform state mv aws_security_group.ec2 module.security_groups.aws_security_group.ec2
terraform state mv aws_security_group.rds module.security_groups.aws_security_group.rds

terraform state mv aws_instance.app module.ec2.aws_instance.app

terraform state mv aws_db_subnet_group.main module.rds.aws_db_subnet_group.main
terraform state mv aws_db_instance.postgres module.rds.aws_db_instance.postgres

# 4. Verify no changes needed
terraform plan
# Should show: "No changes. Your infrastructure matches the configuration."
```

### Option 3: Fresh Start (Recommended)

If this is a learning/test environment:

1. Note down any important data from RDS
2. Destroy old infrastructure
3. Deploy new modular infrastructure
4. Restore data if needed

## Benefits of New Structure

✅ **Reusability**: Modules can be reused for different environments
✅ **Maintainability**: Easier to maintain and update
✅ **Scalability**: Simple to create dev, staging, prod environments
✅ **Organization**: Clear separation of concerns
✅ **Best Practices**: Follows Terraform industry standards

## Environment-Specific Deployments

With the new structure, you can easily create multiple environments:

```bash
# Create prod environment
cp terraform.tfvars.example terraform.tfvars
# Edit values for production

# Create dev environment (future)
mkdir environments/dev
cp terraform.tfvars.example environments/dev/terraform.tfvars
# Edit for dev settings
```

## Need Help?

- Check [modules/README.md](modules/README.md) for module documentation
- Review [README.md](README.md) for updated deployment instructions
- The CI/CD pipeline in `.github/workflows/terraform.yml` works with the new structure

## Rollback

If you need to rollback to the old structure:

```bash
git checkout <commit-before-modular-refactor>
terraform init
# Then either keep using old structure or plan new migration
```
