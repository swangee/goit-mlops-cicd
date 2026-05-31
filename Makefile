.DEFAULT_GOAL := help
.PHONY: help init fmt validate plan apply apply-argocd destroy

help: ## Показати доступні команди
	@echo "Цілі:"
	@echo "  init           terraform init"
	@echo "  fmt            terraform fmt -recursive"
	@echo "  validate       terraform validate"
	@echo "  apply-argocd   apply лише встановлення Argo CD — фаза 1 (створює admin-secret)"
	@echo "  plan           terraform plan (повний)"
	@echo "  apply          terraform apply (повний; фаза 2 / звичайні зміни)"
	@echo "  destroy        terraform destroy"
	@echo ""
	@echo "Перший раз з нуля: make init apply-argocd apply"

init: ## terraform init
	terraform init

fmt: ## terraform fmt -recursive
	terraform fmt -recursive

validate: ## terraform validate
	terraform validate

apply-argocd: ## apply лише встановлення Argo CD — фаза 1 (створює admin-secret)
	terraform apply -target=module.argocd

plan: ## terraform plan (повний; потребує встановленого Argo CD)
	terraform plan

apply: ## terraform apply (повний; фаза 2 / подальші зміни)
	terraform apply

destroy: ## terraform destroy
	terraform destroy
