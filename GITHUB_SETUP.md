# GitHub Actions Setup Guide - Terraform CI/CD

Este documento descreve como configurar o GitHub Actions para automatizar o deploy da infraestrutura AWS usando Terraform.

## 📋 Pré-requisitos

### 1. Credenciais AWS
Você precisa ter em mãos:
- ✅ AWS Access Key ID
- ✅ AWS Secret Access Key
- ✅ AWS Region (exemplo: `us-east-1`)

### 2. Conta GitHub
- Repositório criado no GitHub
- Permissões de administrador no repositório

### 3. Recursos AWS Adicionais (Opcional mas Recomendado)
Para armazenar o estado do Terraform remotamente (recomendado para produção):
- Bucket S3 para armazenar o Terraform state
- DynamoDB table para lock do state

---

## 🔧 Configuração Passo a Passo

### Etapa 1: Configurar Secrets no GitHub

1. Acesse seu repositório no GitHub
2. Vá em **Settings** → **Secrets and variables** → **Actions**
3. Clique em **New repository secret**
4. Adicione os seguintes secrets:

#### Secrets Obrigatórios:

| Nome do Secret | Valor | Descrição |
|----------------|-------|-----------|
| `AWS_ACCESS_KEY_ID` | Sua Access Key | Credencial AWS para autenticação |
| `AWS_SECRET_ACCESS_KEY` | Sua Secret Key | Credencial secreta AWS |
| `AWS_REGION` | `us-east-1` | Região AWS onde a infra será criada |

#### Como adicionar cada secret:
```
Nome: AWS_ACCESS_KEY_ID
Valor: AKIA... (sua access key)
[Add secret]

Nome: AWS_SECRET_ACCESS_KEY
Valor: wJalr... (sua secret key)
[Add secret]

Nome: AWS_REGION
Valor: us-east-1
[Add secret]
```

### Etapa 2: Configurar Environment (Opcional mas Recomendado)

Para adicionar uma camada extra de proteção:

1. Vá em **Settings** → **Environments**
2. Clique em **New environment**
3. Nome: `production`
4. Configure **Environment protection rules**:
   - ☑️ Required reviewers (adicione você ou sua equipe)
   - ☑️ Wait timer (opcional, ex: 5 minutos)
5. Clique em **Save protection rules**

### Etapa 3: Configurar Terraform Backend Remoto (Recomendado)

Para ambientes de produção, é altamente recomendado usar um backend remoto S3.

#### 3.1. Criar Bucket S3 para Terraform State

Via AWS Console ou AWS CLI:

```bash
# Criar bucket S3
aws s3api create-bucket \
  --bucket techchallenge1-terraform-state \
  --region us-east-1

# Habilitar versionamento
aws s3api put-bucket-versioning \
  --bucket techchallenge1-terraform-state \
  --versioning-configuration Status=Enabled

# Habilitar criptografia
aws s3api put-bucket-encryption \
  --bucket techchallenge1-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Bloquear acesso público
aws s3api put-public-access-block \
  --bucket techchallenge1-terraform-state \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

#### 3.2. Criar DynamoDB Table para State Locking

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

#### 3.3. Criar arquivo `backend.tf`

Crie um arquivo `backend.tf` no diretório do Terraform:

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

### Etapa 4: Configurar SSH Key Pair na AWS

O Terraform espera que a key pair `keypair-techchallenge1-fiap` já exista na AWS:

```bash
# Criar key pair
aws ec2 create-key-pair \
  --key-name keypair-techchallenge1-fiap \
  --query 'KeyMaterial' \
  --output text > keypair-techchallenge1-fiap.pem

# Configurar permissões
chmod 400 keypair-techchallenge1-fiap.pem

# Mover para diretório SSH
mv keypair-techchallenge1-fiap.pem ~/.ssh/
```

### Etapa 5: Configurar Variáveis (Opcional)

Se você quiser customizar variáveis via GitHub Secrets:

#### Adicionar Secrets Opcionais:

| Nome do Secret | Valor Exemplo | Descrição |
|----------------|---------------|-----------|
| `TF_VAR_allowed_ssh_ip` | `203.0.113.0/32` | Seu IP para acesso SSH |
| `TF_VAR_db_password` | `SuperSecurePass!` | Senha do banco (ao invés de usar hardcoded) |

Depois atualize o workflow para incluir:
```yaml
env:
  TF_VAR_allowed_ssh_ip: ${{ secrets.TF_VAR_allowed_ssh_ip }}
  TF_VAR_db_password: ${{ secrets.TF_VAR_db_password }}
```

---

## 🚀 Como Funciona o Pipeline

### Pull Request (PR)
Quando você criar um PR para a branch `main`:
1. ✅ Terraform Format Check
2. ✅ Terraform Init
3. ✅ Terraform Validate
4. ✅ Terraform Plan (exibe o que será criado/modificado)
5. 💬 Comenta o plano no PR

**Nenhuma infraestrutura é criada/modificada nesta etapa!**

### Merge/Push para Main
Quando você faz merge ou push direto para `main`:
1. ✅ Terraform Format Check
2. ✅ Terraform Init
3. ✅ Terraform Validate
4. ✅ Terraform Plan
5. 🚀 **Terraform Apply** (cria/atualiza a infraestrutura)

---

## 📝 Workflow de Desenvolvimento Recomendado

### 1. Fazer Mudanças em Branch
```bash
# Criar branch de feature
git checkout -b feature/minha-mudanca

# Fazer alterações nos arquivos .tf
vim variables.tf

# Commitar mudanças
git add .
git commit -m "feat: adicionar nova variável"

# Push para GitHub
git push origin feature/minha-mudanca
```

### 2. Criar Pull Request
- Acesse GitHub
- Crie PR de `feature/minha-mudanca` → `main`
- Aguarde o pipeline rodar
- Revise o Terraform Plan no comentário do PR

### 3. Merge para Main
- Se tudo estiver OK, faça merge do PR
- O pipeline automaticamente aplicará as mudanças na AWS

### 4. Verificar Deploy
- Acesse a aba **Actions** no GitHub
- Verifique se o workflow foi executado com sucesso
- Verifique os outputs do Terraform:
  - EC2 Public IP
  - RDS Endpoint
  - etc.

---

## 🔍 Verificar Status do Pipeline

### Via GitHub Actions
1. Acesse seu repositório no GitHub
2. Clique na aba **Actions**
3. Veja a lista de workflows executados
4. Clique em um workflow para ver detalhes

### Via Terraform Cloud (Alternativa)
Se preferir usar Terraform Cloud ao invés de S3:
1. Crie conta em https://app.terraform.io
2. Configure backend type `remote`
3. Use token do Terraform Cloud nos secrets

---

## 🛡️ Melhores Práticas de Segurança

### ✅ Faça:
- Use AWS IAM roles com permissões mínimas necessárias
- Use GitHub Environments com proteção
- Armazene state do Terraform em S3 com criptografia
- Use DynamoDB para state locking
- Revise todos os Terraform Plans antes de aprovar
- Use branches protegidas (require PR reviews)
- Rotacione suas credenciais AWS regularmente

### ❌ Não Faça:
- Não commite credenciais AWS no código
- Não use credenciais de root da AWS
- Não desabilite o Terraform Plan em PRs
- Não faça push direto para main (use PRs)
- Não compartilhe secrets do GitHub

---

## 🐛 Troubleshooting

### Erro: "Error configuring S3 Backend"
- Verifique se o bucket S3 existe
- Confirme que as credenciais AWS têm permissão para acessar o bucket
- Verifique se a região está correta

### Erro: "InvalidKeyPair.NotFound"
- A key pair `keypair-techchallenge1-fiap` não existe na AWS
- Crie a key pair conforme Etapa 4

### Erro: "Error acquiring the state lock"
- Outro processo está usando o Terraform
- Aguarde ou libere o lock manualmente no DynamoDB

### Pipeline falhou em "Terraform Format"
- Execute `terraform fmt` localmente
- Commite as mudanças formatadas

### Secrets não estão funcionando
- Verifique se os nomes dos secrets estão corretos (case-sensitive)
- Confirme que os secrets foram adicionados no repositório correto
- Para troubleshooting, você pode imprimir vars (NUNCA secrets):
  ```yaml
  - name: Debug
    run: echo "Region is ${{ secrets.AWS_REGION }}"
  ```

---

## 📚 Recursos Adicionais

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform Backend S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

---

## ✅ Checklist Final

Antes de fazer o primeiro deploy, confirme:

- [ ] Secrets configurados no GitHub (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)
- [ ] Environment `production` criado (opcional)
- [ ] Bucket S3 criado para Terraform state
- [ ] DynamoDB table criado para state lock
- [ ] Key pair AWS criada (`keypair-techchallenge1-fiap`)
- [ ] Arquivo `.github/workflows/terraform.yml` commitado
- [ ] Arquivo `backend.tf` criado e commitado (se usar S3 backend)
- [ ] Branch `main` protegida (opcional mas recomendado)
- [ ] Primeiro PR criado para testar o pipeline

---

## 🎯 Próximos Passos

Após configurar tudo:

1. Faça o primeiro deploy via PR
2. Monitore os recursos criados no AWS Console
3. Teste a conexão SSH com a EC2
4. Verifique se o RDS foi criado corretamente
5. Configure monitoring/alertas (CloudWatch)
6. Configure backup automático
7. Documente os outputs finais (IPs, endpoints, etc.)

Boa sorte! 🚀
