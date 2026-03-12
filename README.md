# Tech Challenge 1 - Infrastructure as Code

This Terraform configuration creates AWS infrastructure for Tech Challenge 1 FIAP.

## Architecture

- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Subnets**: 
  - 1 Public subnet (10.0.1.0/24) for EC2
  - 2 Private subnets (10.0.2.0/24, 10.0.3.0/24) for RDS
- **EC2**: t3.micro instance with Python and pip pre-installed
- **RDS**: MariaDB instance (db.t3.micro, free tier eligible)
- **Security**: 
  - EC2 accessible via SSH (port 22 from specific IP), HTTP (80), HTTPS (443), and application port (5000)
  - RDS accessible only from EC2 security group on port 3306

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

## Usage

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
mysql -h <RDS_ENDPOINT> -u admin -p
# Password: fiaptech34233@
```

Or using Python:

```python
import pymysql

connection = pymysql.connect(
    host='<RDS_ENDPOINT>',
    user='admin',
    password='fiaptech34233@',
    database='techchallenge'
)
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
- 1x db.t3.micro RDS MariaDB (free tier eligible for first 750 hours/month)
- Standard networking and storage costs apply

Always monitor your AWS costs and destroy resources when not needed.
