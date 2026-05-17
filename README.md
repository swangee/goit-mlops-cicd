## Запуск

```bash
# 0. S3-бакет для стейту (одноразово, якщо ще не створений)
cd bootstrap && terraform init && terraform apply && cd ..

# 1. Розгортання VPC + EKS
terraform init
terraform apply

# 2. Доступ до кластера
aws eks --region eu-north-1 update-kubeconfig --name mlops-eks
kubectl get nodes
```

## Видалення

```bash
terraform destroy
```