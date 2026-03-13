# Tech Challenge 1 - Infrastructure as Code

## Architecture

- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Subnets**: 
  - 1 Public subnet (10.0.1.0/24) for EC2
  - 2 Private subnets (10.0.2.0/24, 10.0.3.0/24) for RDS
- **EC2**: t3.micro instance with Python, pip, Docker, and Docker Compose pre-installed
- **RDS**: PostgreSQL 16 instance (db.t4g.micro, free tier eligible)
- **Security**: 
  - EC2 accessible via SSH (port 22 from specific IP), HTTP (80), HTTPS (443), and application port (5000)
  - RDS accessible only from EC2 security group on port 5432

## Project Structure

This project uses a **modular Terraform structure** for better organization, reusability, and maintainability:

```
.
├── main.tf                    # Root module that orchestrates all child modules
├── variables.tf               # Root-level variables
├── outputs.tf                 # Root-level outputs
├── provider.tf                # AWS provider configuration
├── backend.tf                 # S3 backend for state management
├── terraform.tfvars.example   # Example variables file
├── .github/
│   └── workflows/
│       └── terraform.yml      # GitHub Actions CI/CD pipeline
└── modules/                   # Reusable Terraform modules
    ├── vpc/                   # VPC, subnets, IGW, route tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/       # Security groups for EC2 and RDS
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                   # EC2 instance configuration
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh       # Bootstrap script
    └── rds/                   # RDS PostgreSQL configuration
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Benefits of this structure:**
- ✅ **Reusability**: Modules can be reused for different environments (dev, staging, prod)
- ✅ **Maintainability**: Changes are isolated to specific modules
- ✅ **Scalability**: Easy to add new environments or components
- ✅ **Testability**: Each module can be tested independently
- ✅ **Organization**: Clear separation of concerns

See [modules/README.md](modules/README.md) for detailed module documentation.

## Prerequisites

1. **AWS CLI** configured with credentials
2. **Terraform** installed (>= 1.0)
3. **SSH Key Pair** named `keypair-techchallenge1-fiap` must exist in AWS (create it in the AWS console or via AWS CLI)

### Create Key Pair (if not exists)

```bash
aws ec2 create-key-pair \
  --key-name keypair-techchallenge1-fiap \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/keypair-techchallenge1-fiap.pem

chmod 400 ~/.ssh/keypair-techchallenge1-fiap.pem
```

## 🚀 CI/CD with GitHub Actions (Recommended)

This repository includes a complete GitHub Actions workflow for automated Terraform deployments.

**Quick Setup:**
- See [QUICKSTART.md](QUICKSTART.md) for 5-minute setup
- See [GITHUB_SETUP.md](GITHUB_SETUP.md) for detailed documentation

**What you need:**
1. AWS Access Key ID and Secret Access Key
2. Configure GitHub Secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)
3. Create AWS Key Pair (`keypair-techchallenge1-fiap`)
4. Create S3 bucket for Terraform state (optional but recommended)

**How it works:**
- **Pull Requests**: Runs `terraform plan` and comments the plan on PR
- **Merge to Main**: Automatically runs `terraform apply` to deploy infrastructure

This is the **recommended approach** for team collaboration and production deployments.

## 💻 Manual Deployment (Alternative)

### Initialize Terraform

```bash
terraform init
```

### Plan Infrastructure

```bash
terraform plan
```

### Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Outputs

After successful deployment, you'll see:
- EC2 public IP and DNS
- RDS endpoint
- SSH connection command
- Application URL

### Connect to EC2

```bash
ssh -i ~/.ssh/keypair-techchallenge1-fiap.pem ec2-user@<EC2_PUBLIC_IP>
```

### Connect to RDS from EC2

Once connected to EC2:

```bash
psql -h <RDS_ENDPOINT> -U dbadmin -d togglemaster
# Password: fiaptech34233!
```

Or using Python:

```python
import psycopg2

connection = psycopg2.connect(
    host='<RDS_ENDPOINT>',
    user='dbadmin',
    password='fiaptech34233!',
    database='togglemaster',
    port=5432
)
```

### Using Docker Compose with RDS

If you want to use the RDS PostgreSQL instance with your Docker Compose application:

1. Update your `docker-compose.yaml` environment variables:

```yaml
environment:
  - DB_HOST=<RDS_ENDPOINT>  # Replace with actual RDS endpoint
  - DB_NAME=togglemaster
  - DB_USER=dbadmin
  - DB_PASSWORD=fiaptech34233!
  - DB_PORT=5432
```

2. Comment out or remove the local `db` service from docker-compose.yaml since you're using RDS

3. Deploy your application:

```bash
docker-compose up -d
```

## Destroy Infrastructure

When you're done, clean up resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm.

## Configuration

You can customize variables in `variables.tf` or create a `terraform.tfvars` file:

```hcl
aws_region         = "us-east-1"
project_name       = "techchallenge1-fiap"
ec2_instance_type  = "t3.micro"
allowed_ssh_ip     = "203.0.113.0/32"  # Replace with your IP address
```

### Get Your Current IP

To restrict SSH to your current IP:

```bash
# Get your public IP
curl -s https://checkip.amazonaws.com

# Create terraform.tfvars with your IP
echo 'allowed_ssh_ip = "YOUR_IP/32"' > terraform.tfvars
```

## Security Notes

⚠️ **Important**: 
- The RDS password is stored in plain text in `variables.tf`. For production, use AWS Secrets Manager or environment variables.
- **SSH access**: By default set to 0.0.0.0/0. Strongly recommended to change `allowed_ssh_ip` variable to your specific IP address.
- **HTTP/HTTPS ports** (80, 443) are open to 0.0.0.0/0 for web access.
- **Port 5000** is open to 0.0.0.0/0 for application access.
- **RDS** is in private subnet and only accessible from EC2 security group (best practice).

## Costs

This infrastructure uses:
- 1x t3.micro EC2 instance (free tier eligible)
- 1x db.t4g.micro RDS PostgreSQL (free tier eligible for first 750 hours/month)
- Standard networking and storage costs apply

Always monitor your AWS costs and destroy resources when not needed.
