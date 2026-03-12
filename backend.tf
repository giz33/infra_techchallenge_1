# Terraform Backend Configuration
# 
# This configures Terraform to store state in S3 with DynamoDB locking
# Uncomment this block after creating the S3 bucket and DynamoDB table
# 
# To create resources:
# 1. See GITHUB_SETUP.md for detailed instructions
# 2. Create S3 bucket: techchallenge1-terraform-state
# 3. Create DynamoDB table: terraform-state-lock
# 4. Uncomment the code below
# 5. Run: terraform init -migrate-state

terraform {
  backend "s3" {
    bucket         = "techchallenge1-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
