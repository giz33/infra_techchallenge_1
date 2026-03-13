# Quick Start - GitHub Actions CI/CD

## ⚡ Setup Rápido (5 minutos)

### 1. Adicionar Secrets no GitHub

Acesse: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

```
Nome: AWS_ACCESS_KEY_ID
Valor: [Sua Access Key]

Nome: AWS_SECRET_ACCESS_KEY  
Valor: [Sua Secret Key]

Nome: AWS_REGION
Valor: us-east-1
```

### 2. Criar Key Pair na AWS

```bash
aws ec2 create-key-pair \
  --key-name keypair-techchallenge1-fiap \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/keypair-techchallenge1-fiap.pem

chmod 400 ~/.ssh/keypair-techchallenge1-fiap.pem
```

### 3. Criar S3 Bucket para Terraform State (Recomendado)

```bash
# Criar bucket
aws s3api create-bucket \
  --bucket techchallenge1-terraform-state \
  --region us-east-1

# Habilitar versionamento
aws s3api put-bucket-versioning \
  --bucket techchallenge1-terraform-state \
  --versioning-configuration Status=Enabled

# Criar DynamoDB table para lock
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 4. Habilitar Backend S3 (Opcional)

Edite `backend.tf` e descomente o bloco do backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "techchallenge1-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 5. Fazer Deploy

```bash
# Criar branch
git checkout -b feature/primeira-infra

# Commitar mudanças
git add .
git commit -m "feat: setup inicial da infraestrutura"
git push origin feature/primeira-infra

# Criar PR no GitHub
# O pipeline rodará automaticamente e mostrará o plano

# Após revisar e aprovar, merge para main
# O terraform apply rodará automaticamente
```

## 📖 Documentação Completa

Para documentação detalhada, veja: [GITHUB_SETUP.md](GITHUB_SETUP.md)

## 🎯 O que o Pipeline Faz

### Em Pull Requests:
- ✅ Valida formatação do Terraform
- ✅ Valida sintaxe dos arquivos
- ✅ Gera plano de execução
- 💬 Comenta o plano no PR

### Em Push/Merge para Main:
- 🚀 Executa terraform apply
- 📦 Cria/atualiza infraestrutura na AWS
- 📊 Exibe outputs (IPs, endpoints)

## 🛡️ Secrets Necessários

| Secret | Descrição |
|--------|-----------|
| `AWS_ACCESS_KEY_ID` | Access Key da AWS |
| `AWS_SECRET_ACCESS_KEY` | Secret Key da AWS |
| `AWS_REGION` | Região AWS (ex: us-east-1) |
