## Архітектура

Один root-стек, один стейт (`eks-vpc-cluster/terraform.tfstate`):

- `vpc/`, `eks/` — мережа та кластер EKS (провайдер `aws`).
- `argocd/` — встановлення Argo CD у кластер через Helm (провайдери `kubernetes`, `helm`).
- `argocd-apps/` — Argo CD-ресурси поверх установленого Argo CD: `argocd_application_set`
  та потенційно інші (провайдер `argocd`).

Провайдер `argocd` підключається до вже працюючого `argocd-server` через **port-forward**
(inline EKS-креди в блоці `kubernetes`, автентифікація admin-паролем із secret'а
`argocd-initial-admin-secret`; `plain_text`, бо сервер запущено з `--insecure`).

Провайдери сконфігуровані в root, модулі їх успадковують.
Порядок розгортання: `vpc → eks → argocd → argocd-apps` (через `depends_on`).

## Передумови

- AWS-креди з доступом до S3-бакета зі стейтом.
- `kubectl`/`kubeconfig` — лише для зручності (`make kubeconfig`). Провайдеру `argocd`
  окремий kubeconfig не потрібен: він ходить inline-кредами + port-forward.

## Запуск (з нуля)

> Провайдери `kubernetes`/`helm`/`argocd` беруть конфіг із кластера, а пароль для
> `argocd` — із secret'а, що зʼявляється лише після встановлення Argo CD. Тому перший
> прогін **трифазний**: кластер → встановлення Argo CD → Argo CD-ресурси.

```bash
make bootstrap       # 0. S3-бакет для стейту (одноразово, якщо ще не створений)
make init            # 1. ініціалізація
make apply-cluster   # 2. фаза 1 — VPC + EKS
make apply-argocd    # 3. фаза 2 — встановлення Argo CD (створює admin-secret)
make apply           # 4. фаза 3 — argocd_application_set
make kubeconfig      # (опційно) доступ kubectl: kubectl get nodes
```

Або послідовним ланцюгом:

```bash
make bootstrap init apply-cluster apply-argocd apply
```

Коли кластер і Argo CD уже існують, подальші зміни застосовуються в один прохід:

```bash
make plan    # переглянути зміни
make apply   # застосувати
```

> Регіон і назву кластера для `make kubeconfig` можна перевизначити:
> `make kubeconfig REGION=eu-north-1 CLUSTER_NAME=mlops-eks`.

## Маніфести застосунків

`argocd-apps` створює `ApplicationSet` із git-генератором каталогів, що читає
`applications/goit-lesson7/namespaces/*` з репозиторію `app_repo_url`
(`https://github.com/swangee/goit-mlops-cicd.git`, гілка `lesson7`). Маніфести
namespace'ів мають лежати саме там — Argo CD розгортає по одному `Application`
на кожен підкаталог.

## Видалення

```bash
# kubeconfig має вказувати на кластер (k8s/helm/argocd-ресурси видаляються першими)
make destroy
```
