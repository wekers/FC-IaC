# Infrastructure as Code Lab (Terraform + AWS CDK)

[🇺🇸 English](README.md) | [🇧🇷 Português](README.pt-BR.md)

![Terraform](https://img.shields.io/badge/Terraform-1.8+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=github-actions)
![Python](https://img.shields.io/badge/CDK-Python-blue?logo=python)

Infraestrutura AWS modularizada utilizando Terraform e AWS CDK, explorando práticas modernas de Infrastructure as Code (IaC), automação cloud, testes automatizados e CI/CD.

O projeto cobre cenários reais de provisionamento, troubleshooting, integração contínua e evolução arquitetural utilizando abordagens declarativas (Terraform) e programáticas (AWS CDK).

---

# Objetivo

Este laboratório foi desenvolvido com foco em:

- modularização de infraestrutura
- boas práticas de Terraform
- AWS CDK com Python
- automação CI/CD
- testes automatizados de infraestrutura
- infraestrutura reproduzível
- troubleshooting real
- entendimento de tradeoffs em IaC
- múltiplos ambientes e stacks

---

# Conceitos Explorados

- Infrastructure as Code (IaC)
- Terraform Modules
- AWS CDK
- CloudFormation
- CI/CD
- Terraform Testing
- Auto Scaling
- Load Balancing
- Remote State
- State Locking
- Multi-environment Infrastructure
- Multi-stack CDK
- Declarative vs Imperative IaC

---

# Arquitetura

```text
Internet
    │
    ▼
Application Load Balancer
    │
    ▼
Target Group
    │
    ▼
Auto Scaling Group
    │
    ▼
EC2 Instances (Nginx via user_data)
```

---

# Estrutura do Projeto

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml
│
│
├── aws/
│   ├── environments/
│   ├── modules/
│   │   ├── network/
│   │   └── cluster/
│   └── terraform.tfstate.d/
│
├── basic/
│
└── CDK/
    ├── example/
    └── website/
        ├── website/
        │   └── modules/
        │       ├── network.py
        │       └── cluster.py
        └── tests/
```

---

# Tecnologias Utilizadas

- Terraform
- AWS
- AWS CDK
- CloudFormation
- Python
- GitHub Actions
- S3 Backend
- DynamoDB Locking
- EC2
- Auto Scaling Group
- Application Load Balancer
- Terraform Test Framework

---

# Terraform Infrastructure

O projeto utiliza Terraform para provisionamento declarativo da infraestrutura AWS.

## Recursos Provisionados

- VPC
- Public Subnets
- Internet Gateway
- Route Tables
- Security Groups
- Launch Templates
- Auto Scaling Group
- Application Load Balancer
- Scaling Policies
- CloudWatch Alarms

---

# AWS CDK

O projeto também explora AWS CDK utilizando Python, demonstrando:

- constructs
- CloudFormation synthesis
- múltiplas stacks
- múltiplas contas AWS
- infraestrutura imperativa
- abstrações programáticas
- modularização utilizando Python

## Exemplo de múltiplas stacks

```python
WebsiteStack(
    app,
    "DevWebsiteStack",
    "dev-website-",
    env=cdk.Environment(
        account="ACCOUNT_ID",
        region="us-west-2"
    ),
)

WebsiteStack(
    app,
    "ProdWebsiteStack",
    "prod-website-",
    env=cdk.Environment(
        account="ACCOUNT_ID_PROD",
        region="us-west-2"
    ),
)
```

---

# Remote State

O projeto utiliza backend remoto S3 para compartilhamento de state.

## Benefícios

- state compartilhado entre ambientes
- integração com CI/CD
- persistência centralizada
- colaboração em equipe

## Locking

O DynamoDB é utilizado para lock do state Terraform.

Isso evita:

- race conditions
- corrupção de state
- applies simultâneos

---

## Inicialização do backend

O bucket do backend S3 e a tabela de bloqueio do DynamoDB devem existir antes de executar o comando `terraform init`.

Esse é um requisito comum para a inicialização do Terraform, uma vez que o Terraform não pode provisionar o backend remoto antes de se inicializar.

---

# CI/CD

Pipeline automatizado utilizando GitHub Actions.

## Fluxo atual

```text
checkout
  ↓
terraform init
  ↓
terraform fmt
  ↓
terraform plan
  ↓
terraform apply
```

## Workflows

- `terraform.yml`

### GitHub Actions Pipeline:

![](https://raw.githubusercontent.com/wekers/FC-IaC/refs/heads/main/assets/github-actions-pipeline.png)

## Secrets utilizados

### AWS

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

### Azure (laboratório/estudo)

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

---

# Terraform Tests

O projeto utiliza:

- testes unitários
- testes de integração
- validação HTTP real

## Testes implementados

### Network Module

Valida:

- criação da VPC
- CIDR blocks
- subnets
- tags
- outputs

### Cluster Module

Valida:

- ALB
- ASG
- Launch Template
- bootstrap EC2
- aplicação HTTP funcionando
- health checks

### Terraform Integration Tests

![](https://raw.githubusercontent.com/wekers/FC-IaC/refs/heads/main/assets/terraform-integration-tests.png)

---

# Principais Aprendizados

## `count` vs `for_each`

Inicialmente os recursos utilizavam `count`.

Posteriormente houve migração para `for_each`.

### Benefícios do `for_each`

- maior estabilidade de recursos
- evita recreações inesperadas
- melhor rastreabilidade

### Tradeoff

Recursos deixam de ser listas e passam a ser mapas/objetos.

Exemplo:

```hcl
aws_subnet.subnets["10.0.0.0/24"]
```

ao invés de:

```hcl
aws_subnet.subnets[0]
```

Impactando:

- testes
- outputs
- referências internas

---

# Problemas Reais Encontrados

## Terraform Test + `for_each`

Após migrar de `count` para `for_each`, os testes falharam devido à mudança estrutural dos recursos.

### Solução

Uso de:

```hcl
values(...)
```

e acesso por chave.

---

## Timing de ALB + ASG

Os testes HTTP falhavam inicialmente devido ao tempo necessário para:

- EC2 inicializar
- `user_data` executar
- nginx instalar
- health checks passarem

### Solução

- aumento de retries
- remoção de `yum update -y`
- ajuste de timeouts

---

## Recursos órfãos após `Ctrl+C`

Interrupções durante `terraform test` deixaram recursos órfãos:

- launch templates
- target groups
- load balancers

### Aprendizado

Testes Terraform criam infraestrutura real.

Necessário:

- teardown adequado
- nomes randômicos
- limpeza manual em alguns cenários

---

# Tradeoffs do Terraform Test

## Prós

- valida infraestrutura real
- testes E2E
- detecta regressões
- maior confiança em mudanças

## Contras

- lento
- custo real na cloud
- debugging mais difícil
- timing/eventual consistency
- risco de recursos órfãos

---

# Segurança

## Melhorias futuras planejadas

- OIDC no GitHub Actions
- remoção de secrets estáticos
- IAM least privilege
- roles específicas por ambiente

---

# Melhorias Futuras

- Terratest (Go)
- observabilidade
- métricas e logs
- múltiplos ambientes
- módulos reutilizáveis
- blue/green deployments
- OIDC federation
- testes de drift
- policy as code
- integração com Kubernetes

---

# Como Executar

## Terraform

### Inicializar

```bash
$ terraform init
```

### Validar

```bash
$ terraform validate
```

### Planejar

```bash
$ terraform plan
```

### Aplicar

```bash
$ terraform apply
```

### Executar testes

```bash
$ terraform test
```

---

## AWS CDK

### Instalar e inicializar

```bash
$ npm install -g aws-cdk
$ cdk --version
$ cdk bootstrap aws://User-ID/Region
$ cdk init app --language python
$ pip install -r requirements.txt
```

### Sintetizar template

```bash
$ cdk synth
```

### Deploy

```bash
$ cdk deploy
```

---

# Observações

Este projeto possui finalidade educacional/laboratorial, buscando simular cenários encontrados em ambientes reais de engenharia de plataforma, cloud, DevOps e automação de infraestrutura.

---

# Estudos, Implementação e Expansão

Fernando Gilli

---

# Créditos

## Módulo Infra as Code — MBA Arquitetura Full Cycle

Conteúdo desenvolvido durante o módulo de Infrastructure as Code (IaC).

### Professor/Tutor

Igor Gomes  
https://www.linkedin.com/in/igorgomesoliveira/

O projeto foi expandido progressivamente ao longo do módulo, incluindo:

- testes automatizados com `terraform test`
- CI/CD com GitHub Actions
- validação HTTP E2E
- troubleshooting real de infraestrutura
- documentação de tradeoffs e aprendizados
- modularização avançada
- integração entre módulos Terraform
- múltiplas stacks com AWS CDK
