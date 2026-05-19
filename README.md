# Infrastructure as Code Lab (Terraform + AWS CDK)

[🇺🇸 English](README.md) | [🇧🇷 Português](README.pt-BR.md)

![Terraform](https://img.shields.io/badge/Terraform-1.8+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=github-actions)
![Python](https://img.shields.io/badge/CDK-Python-blue?logo=python)

Modular AWS infrastructure using Terraform and AWS CDK, exploring modern Infrastructure as Code (IaC), cloud automation, automated testing, and CI/CD practices.

This project covers real-world provisioning scenarios, troubleshooting, continuous integration, and architectural evolution using both declarative (Terraform) and programmatic (AWS CDK) approaches.

---

# Purpose

This lab was developed focusing on:

- infrastructure modularization
- Terraform best practices
- AWS CDK with Python
- CI/CD automation
- automated infrastructure testing
- reproducible infrastructure
- real-world troubleshooting
- understanding IaC tradeoffs
- multiple environments and stacks

---

# Explored Concepts

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

# Architecture

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

# Project Structure

```text
.
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       └── terraform-destroy.yml
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

# Technologies Used

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

The project uses Terraform for declarative AWS infrastructure provisioning.

## Provisioned Resources

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

The project also explores AWS CDK using Python, demonstrating:

- constructs
- CloudFormation synthesis
- multiple stacks
- multiple AWS accounts
- imperative infrastructure
- programmatic abstractions
- Python-based modularization

## Example of multiple stacks

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

The project uses an S3 backend for Terraform remote state sharing.

## Benefits

- shared state between environments
- CI/CD integration
- centralized persistence
- team collaboration

## Locking

DynamoDB is used for Terraform state locking.

This prevents:

- race conditions
- state corruption
- simultaneous applies

---

## Backend Bootstrap

The S3 backend bucket and DynamoDB locking table must exist before running `terraform init`.

This is a common Terraform bootstrap requirement, since Terraform cannot provision the remote backend before initializing itself.

---

# CI/CD

Automated pipeline using GitHub Actions.

## Current Flow

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

### GitHub Actions Pipeline

![](https://raw.githubusercontent.com/wekers/FC-IaC/refs/heads/main/assets/github-actions-pipeline.png)

## Secrets used

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

The project uses:

- unit tests
- integration tests
- real HTTP validation

## Tests implemented

### Network Module

Check:

- VPC creation
- CIDR blocks
- subnets
- tags
- outputs

### Cluster Module

Check:

- ALB
- ASG
- Launch Template
- bootstrap EC2
- HTTP application working
- health checks

### Terraform Integration Tests

![](https://raw.githubusercontent.com/wekers/FC-IaC/refs/heads/main/assets/terraform-integration-tests.png)

---

# Main Learnings

## `count` vs `for_each`

Initially, the resources used `count`.

Later, they were migrated to `for_each`.

### Benefits of `for_each`

- greater resource stability
- avoids unexpected recreations
- improved traceability

### Tradeoff

Resources stop being lists and become maps/objects.

---

# Real Problems Encountered

## Terraform Test + `for_each`

After migrating from `count` to `for_each`, tests failed due to structural changes in the resources.

## ALB + ASG Timing

HTTP tests initially failed due to:

- EC2 initialization
- `user_data` execution
- nginx installation
- health checks timing

## Orphan Resources After `Ctrl+C`

Interrupting `terraform test` left orphan resources behind:

- launch templates
- target groups
- load balancers

---

# Tradeoffs of Terraform Testing

## Pros

- validates actual infrastructure
- end-to-end testing
- detects regressions
- greater confidence in changes

## Cons

- slow
- actual cloud costs
- more difficult debugging
- timing/eventual consistency
- risk of orphaned resources

---

# Security

## Planned future improvements

- OIDC in GitHub Actions
- Removal of static secrets
- IAM least privilege
- Environment-specific roles

---

# Global Future Improvements

- Terratest (Go)
- observability
- metrics and logs
- reusable modules
- OIDC federation
- Kubernetes integration

---

# How to Run

## Terraform

```bash
$ terraform init
$ terraform validate
$ terraform plan
$ terraform apply
$ terraform test
```

## AWS CDK

```bash
$ npm install -g aws-cdk
$ cdk --version
$ cdk bootstrap aws://User-ID/Region
$ cdk init app --language python
$ pip install -r requirements.txt
$ cdk synth
$ cdk deploy
```

---

# Notes

This project has an educational/laboratory purpose while aiming to simulate real-world platform engineering, cloud, DevOps, and infrastructure automation scenarios.

---

# Studies, Implementation and Expansion

Fernando Gilli

---

# Credits

## Infrastructure as Code Module — Full Cycle Architecture MBA

### Professor / Tutor

Igor Gomes  
https://www.linkedin.com/in/igorgomesoliveira/

The project was progressively expanded throughout the module, including:

- automated testing with `terraform test`
- CI/CD with GitHub Actions
- end-to-end (E2E) HTTP validation
- real-world infrastructure troubleshooting
- documentation of trade-offs and lessons learned
- advanced modularization
- integration between Terraform modules
- multiple stacks with AWS CDK
