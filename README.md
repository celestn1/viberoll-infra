# 📦 VibeRoll Infra

Infrastructure as Code (IaC) for the **VibeRoll** application — a modern, AI-powered video sharing platform. This repo provisions all AWS infrastructure components using **Terraform** and handles **CI/CD** via **GitHub Actions**.

---

## 🚀 What’s Inside?

### 🔧 Infrastructure Managed
- **VPC** with public/private subnets
- **ALB** (Application Load Balancer)
- **ECS Fargate** for containerized app hosting
- **RDS (PostgreSQL)** for relational storage
- **ElastiCache (Redis)** for caching
- **Secrets Manager** for environment secrets
- **ECR** for Docker image storage
- **WAF** for web firewall protection
- **CloudWatch** for logging & metrics

### ⚙️ CI/CD Pipelines
- **viberoll-backend** repo builds Docker images on push to `main` and pushes to ECR.
- On successful image push, it dispatches a `deploy-trigger` to this repo.
- This repo listens and automatically deploys infra with latest image.

---

## 📁 Repo Structure

viberoll-infra/
├── modules/
│ ├── alb/
│ ├── cloudwatch/
│ ├── ecr/
│ ├── ecs/
│ ├── elasticache/
│ ├── rds/
│ ├── secrets/
│ ├── vpc/
│ └── waf/
├── main.tf
├── variables.tf
├── outputs.tf
└── .github/
└── workflows/
├── deploy.yml
└── destroy.yml



---

## 🔐 Environment Variables (Secrets)

All required secrets are stored in **GitHub Actions** > `Settings > Secrets and Variables`.

Here are some examples:

| Name                      | Description                    |
|---------------------------|--------------------------------|
| `TF_PROJECT_NAME`         | Project name prefix            |
| `TF_DB_USERNAME`          | DB user for RDS                |
| `TF_DB_PASSWORD`          | DB password                    |
| `TF_ECR_REPO_NAME`        | Name of Docker ECR repo        |
| `TF_CONTAINER_IMAGE`      | Full ECR image URL             |
| `TF_JWT_SECRET`           | Auth token signing key         |
| `TF_NODE_ENV`             | Environment name (prod/dev)    |
| `TF_AZ1`, `TF_AZ2`        | Availability Zones             |

---

## 🚀 Deployment Workflow

Triggered on:
- Push to `main` branch in `viberoll-infra`
- OR `repository_dispatch` from `viberoll-backend`

### Steps:
1. Validates required secrets
2. Writes a `secrets.auto.tfvars.json`
3. Executes `terraform plan` and `apply`
4. Provisions ECR, ECS, ALB, RDS, ElastiCache, etc.
5. Uploads secrets to AWS Secrets Manager

See: `.github/workflows/deploy.yml`

---

## 💣 Destroy Workflow

Manually triggered via GitHub Actions → **Run workflow**

### What it does:
- Generates same secrets file
- Runs `terraform plan -destroy` + `apply`
- Cleans up:
  - AWS resources
  - AWS Secrets in Secrets Manager
  - ECR repo (with `--force`)

See: `.github/workflows/destroy.yml`

---

## 🧠 Best Practices Followed

✅ Modular Terraform  
✅ GitHub Actions secrets validation  
✅ Remote backend (S3)  
✅ State locking with DynamoDB  
✅ Secrets never committed  
✅ Clean destroy pipeline  
✅ `prevent_destroy = false` where needed  

---

## 🧩 Future Enhancements

- ✅ Docker image digests instead of `:latest`
- ✅ Trigger deploy only on successful image build
- ✅ Rollback support with tagged images
- ✅ Previews per pull request using dynamic environments
- ⏳ Sync secrets to SSM Parameter Store for EC2-based compatibility
- ⏳ Slack notifications on deploy

---

## 🧪 Testing Your Setup

**To test the deployed app:**

```bash
curl -X POST \
  https://<alb-dns>/api-docs/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@demo.com","username":"demo","password":"123456"}'
🤝 Contributing
We love PRs! Feel free to fork, improve, and open a pull request.

📜 License
MIT License. See LICENSE file.
