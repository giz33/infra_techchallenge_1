# Tech Challenge 1 - Infraestrutura como Código

## Arquitetura

- **VPC**: VPC personalizada com CIDR 10.0.0.0/16
- **Subnets**: 
  - 1 subnet pública (10.0.1.0/24) para EC2
  - 2 subnets privadas (10.0.2.0/24, 10.0.3.0/24) para RDS
- **EC2**: Instância t3.micro com Python, pip, Docker e Docker Compose pré-instalados
- **RDS**: Instância PostgreSQL 16 (db.t4g.micro, elegível para free tier)
- **Segurança**: 
  - EC2 acessível via SSH (porta 22 de IP específico), HTTP (80), HTTPS (443) e porta de aplicação (5000)
  - RDS acessível apenas do security group EC2 na porta 5432

## Estrutura do Projeto

Este projeto usa uma **estrutura modular do Terraform** para melhor organização, reutilização e manutenibilidade:

```
.
├── main.tf                    # Módulo raiz que orquestra todos os módulos filhos
├── variables.tf               # Variáveis de nível raiz
├── outputs.tf                 # Saídas de nível raiz
├── provider.tf                # Configuração do provedor AWS
├── backend.tf                 # Backend S3 para gerenciamento de estado
├── terraform.tfvars.example   # Arquivo de variáveis de exemplo
├── .github/
│   └── workflows/
│       └── terraform.yml      # Pipeline CI/CD do GitHub Actions
└── modules/                   # Módulos Terraform reutilizáveis
    ├── vpc/                   # VPC, subnets, IGW, tabelas de rota
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/       # Grupos de segurança para EC2 e RDS
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                   # Configuração da instância EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh       # Script de inicialização
    └── rds/                   # Configuração do RDS PostgreSQL
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Benefícios desta estrutura:**
- ✅ **Reutilização**: Módulos podem ser reutilizados para diferentes ambientes (dev, staging, prod)
- ✅ **Manutenibilidade**: Alterações são isoladas em módulos específicos
- ✅ **Escalabilidade**: Fácil adicionar novos ambientes ou componentes
- ✅ **Testabilidade**: Cada módulo pode ser testado independentemente
- ✅ **Organização**: Clara separação de responsabilidades

Consulte [modules/README.md](modules/README.md) para documentação detalhada dos módulos.

## Pré-requisitos

1. **AWS CLI** configurada com credenciais
2. **Terraform** instalado (>= 1.0)
3. **SSH Key Pair** nomeado `keypair-techchallenge1-fiap` deve existir na AWS (crie no console AWS ou via AWS CLI)

### Criar Key Pair (se não existir)

```bash
aws ec2 create-key-pair \
  --key-name keypair-techchallenge1-fiap \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/keypair-techchallenge1-fiap.pem

chmod 400 ~/.ssh/keypair-techchallenge1-fiap.pem
```

## 🚀 CI/CD com GitHub Actions (Recomendado)

Este repositório inclui um workflow completo do GitHub Actions para implantações automáticas do Terraform.

**Configuração Rápida:**
- Consulte [QUICKSTART.md](QUICKSTART.md) para configuração em 5 minutos
- Consulte [GITHUB_SETUP.md](GITHUB_SETUP.md) para documentação detalhada

**O que você precisa:**
1. AWS Access Key ID e Secret Access Key
2. Configurar GitHub Secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)
3. Criar AWS Key Pair (`keypair-techchallenge1-fiap`)
4. Criar bucket S3 para estado do Terraform (opcional mas recomendado)

**Como funciona:**
- **Pull Requests**: Executa `terraform plan` e comenta o plano no PR
- **Merge para Main**: Executa automaticamente `terraform apply` para implantar infraestrutura

Esta é a **abordagem recomendada** para colaboração em equipe e implantações em produção.

## 💻 Implantação Manual (Alternativa)

### Inicializar Terraform

```bash
terraform init
```

### Planejar Infraestrutura

```bash
terraform plan
```

### Aplicar Infraestrutura

```bash
terraform apply
```

Digite `yes` quando solicitado para confirmar.

### Saídas

Após implantação bem-sucedida, você verá:
- IP público e DNS do EC2
- Endpoint do RDS
- Comando de conexão SSH
- URL da aplicação

### Conectar ao EC2

```bash
ssh -i ~/.ssh/keypair-techchallenge1-fiap.pem ec2-user@<EC2_PUBLIC_IP>
```

### Conectar ao RDS a partir do EC2

Uma vez conectado ao EC2:

```bash
psql -h <RDS_ENDPOINT> -U dbadmin -d togglemaster
# Senha: fiaptech34233!
```

Ou usando Python:

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

### Usar Docker Compose com RDS

Se você quiser usar a instância PostgreSQL do RDS com sua aplicação Docker Compose:

1. Atualize suas variáveis de ambiente em `docker-compose.yaml`:

```yaml
environment:
  - DB_HOST=<RDS_ENDPOINT>  # Substitua pelo endpoint RDS real
  - DB_NAME=togglemaster
  - DB_USER=dbadmin
  - DB_PASSWORD=fiaptech34233!
  - DB_PORT=5432
```

2. Comente ou remova o serviço `db` local do docker-compose.yaml já que você está usando RDS

3. Implante sua aplicação:

```bash
docker-compose up -d
```

## Destruir Infraestrutura

Quando terminar, limpe os recursos:

```bash
terraform destroy
```

Digite `yes` quando solicitado para confirmar.

## Configuração

Você pode personalizar variáveis em `variables.tf` ou criar um arquivo `terraform.tfvars`:

```hcl
aws_region         = "us-east-1"
project_name       = "techchallenge1-fiap"
ec2_instance_type  = "t3.micro"
allowed_ssh_ip     = "203.0.113.0/32"  # Substitua pelo seu endereço IP
```

### Obter seu IP Atual

Para restringir SSH ao seu IP atual:

```bash
# Obter seu IP público
curl -s https://checkip.amazonaws.com

# Criar terraform.tfvars com seu IP
echo 'allowed_ssh_ip = "YOUR_IP/32"' > terraform.tfvars
```

## Notas de Segurança

⚠️ **Importante**: 
- A senha do RDS é armazenada em texto simples em `variables.tf`. Para produção, use AWS Secrets Manager ou variáveis de ambiente.
- **Acesso SSH**: Por padrão definido como 0.0.0.0/0. Alterar a variável `allowed_ssh_ip` para o IP específico conforme solicitad no tech challenge.
- **Portas HTTP/HTTPS** (80, 443) estão abertas para 0.0.0.0/0 para acesso web.
- **Porta 5000** está aberta para 0.0.0.0/0 para acesso da aplicação.(Verificar se é necessário)
- **RDS** está em subnet privada e acessível apenas do security group EC2 (melhor prática).

## Custos

Esta infraestrutura usa:
- 1x instância EC2 t3.micro (elegível para free tier)
- 1x RDS PostgreSQL db.t4g.micro (elegível para free tier pelos primeiros 750 horas/mês)
- Custos padrão de rede e armazenamento se aplicam
