viberoll-infra

Terraform Infrastructure for Viberoll Backend

This repository contains the Terraform configurations and GitHub Actions workflows necessary to provision, deploy, and manage the infrastructure for the Viberoll backend application on AWS.

Overview

The infrastructure setup includes:

AWS Services: ECS (Fargate), ECR, RDS (PostgreSQL), VPC, Subnets, Security Groups, IAM Roles, Secrets Manager.

CI/CD Pipelines: Automated workflows for building Docker images, pushing to ECR, deploying to ECS, and destroying resources.

Modular Terraform Code: Organized modules for reusability and clarity.

📁 Repository Structure

viberoll-infra/
├── backend.tf
├── destroy.sh
├── main.tf
├── modules
│   ├── alb
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── cloudwatch
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ecr
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ecs
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── elasticache
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── secrets
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── vpc
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── waf
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf

27 directories, 78 files
celestn@CN001:/viberoll-project/viberoll-infra/$



Prerequisites

Terraform: v1.6.6 or later

AWS CLI: Configured with appropriate credentials

GitHub Personal Access Token (PAT): With repo and workflow scopes

Secrets Configuration: Set the following secrets in your GitHub repository:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

TF_PROJECT_NAME

TF_ECR_REPO_NAME

TF_CONTAINER_IMAGE

TF_DB_USERNAME

TF_DB_PASSWORD

TF_DB_NAME

TF_VPC_CIDR

TF_AZ1

TF_AZ2

TF_HOST

TF_PORT

TF_NODE_ENV

TF_SALT_ROUNDS

TF_RPC_URL

TF_WALLET_PRIVATE_KEY

TF_NFT_CONTRACT_ADDRESS

TF_OPENAI_API_ENDPOINT

TF_OPENAI_API_KEY

TF_JWT_SECRET

TF_JWT_REFRESH_SECRET

TF_JWT_ACCESS_TOKEN_EXPIRATION

TF_JWT_REFRESH_TOKEN_EXPIRATION

TF_ADMIN_EMAIL

TF_ADMIN_PASSWORD

TF_ADMIN_USERNAME

PAT_TOKEN


Deployment Workflow

Trigger: A push to the main branch of the viberoll-backend repository triggers the docker-publish.yml workflow.

Docker Build & Push: The workflow builds the Docker image and pushes it to ECR.

Repository Dispatch: Upon successful push, a repository_dispatch event is sent to this repository.

Deploy Workflow: The deploy.yml workflow is triggered, which:

Initializes Terraform

Validates and plans the infrastructure changes

Applies the changes to provision/update resources


Destroy Workflow

To tear down the infrastructure:

Manual Trigger: The destroy.yml workflow is manually triggered via the GitHub Actions tab.

Execution:

Terraform is initialized

A destroy plan is created and applied

AWS Secrets Manager entries related to the project are deleted

The ECR repository specified by TF_ECR_REPO_NAME is forcefully deleted

Note: The current configuration deletes only the specified ECR repository. To delete all ECR repositories tagged with the project name, additional scripting is required.


🔄 Rollback & Preview Environments (Planned Enhancements)

Immutable Image Digests: Transition from using :latest tags to immutable image digests to ensure consistent deployments.

Rollback Support: Maintain a history of successful deployments to facilitate rollbacks in case of failures.

Preview Environments: Automatically deploy feature branches to isolated environments for testing and validation.



📄 License

This project is licensed under the MIT License.

For any issues or contributions, please open an issue or submit a pull request.
