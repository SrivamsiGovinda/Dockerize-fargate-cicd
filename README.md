#Dockerize-fargate-cicd
# ECS Fargate + ECR + CI/CD with GitHub Actions
###  Prerequisites
- AWS account
- Terraform >= 1.2.0
- Docker installed
- GitHub repository (this code)


###  Terraform Deployment
```bash
cd terraform
terraform init
terraform apply -auto-approve
```


Outputs will include:
- **ALB DNS Name** → Public endpoint for your app
- **ECR Repo URL** → For pushing Docker images


###  GitHub Secrets
In your repository settings, add the following secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (e.g., `us-east-1`)


Optional (recommended for OIDC instead of long-lived keys):
- `AWS_ROLE_TO_ASSUME`


###  CI/CD Workflow
- On every push to `main`, GitHub Actions will:
1. Build and push Docker image → ECR
2. Update ECS Task Definition
3. Deploy ECS Service update


---


##   Test Application
Once deployed, get the ALB DNS from Terraform output:
```bash
echo $(terraform output -raw alb_dns)
```
Open in browser:
```
http://<ALB-DNS-NAME>
```
You should see:
```
Hello from ECS Fargate!
```


---


## Cleanup
```bash
cd terraform
terraform destroy -auto-approve
```


