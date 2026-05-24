REGION       ?= eu-north-1
CLUSTER_NAME ?= mlops-eks

.DEFAULT_GOAL := help
.PHONY: help init fmt validate plan plan-cluster apply apply-cluster apply-argocd kubeconfig bootstrap destroy

help: ## Показати доступні команди
	@echo "Цілі:"
	@echo "  bootstrap      S3-бакет для стейту (одноразово)"
	@echo "  init           terraform init"
	@echo "  fmt            terraform fmt -recursive"
	@echo "  validate       terraform validate"
	@echo "  plan-cluster   plan лише VPC+EKS (для першого прогону з нуля)"
	@echo "  apply-cluster  apply лише VPC+EKS (фаза 1)"
	@echo "  apply-argocd   apply лише встановлення Argo CD (фаза 2)"
	@echo "  kubeconfig     налаштувати ~/.kube/config (для kubectl)"
	@echo "  plan           terraform plan (повний)"
	@echo "  apply          terraform apply (повний; фаза 3 / звичайні зміни)"
	@echo "  destroy        terraform destroy"
	@echo ""
	@echo "Перший раз з нуля: make bootstrap init apply-cluster apply-argocd apply"

bootstrap: ## S3-бакет для стейту (одноразово)
	cd bootstrap && terraform init && terraform apply

init: ## terraform init
	terraform init

fmt: ## terraform fmt -recursive
	terraform fmt -recursive

validate: ## terraform validate
	terraform validate

plan-cluster: ## plan лише VPC + EKS (тільки aws-провайдер)
	terraform plan -target=module.vpc -target=module.eks

apply-cluster: ## apply лише VPC + EKS — фаза 1
	terraform apply -target=module.vpc -target=module.eks

apply-argocd: ## apply лише встановлення Argo CD — фаза 2 (створює admin-secret)
	terraform apply -target=module.argocd

kubeconfig: ## налаштувати kubeconfig (для kubectl)
	aws eks --region $(REGION) update-kubeconfig --name $(CLUSTER_NAME)

plan: ## terraform plan (повний; потребує наявного кластера + Argo CD)
	terraform plan

apply: ## terraform apply (повний; фаза 3 / подальші зміни)
	terraform apply

destroy: ## terraform destroy
	terraform destroy
