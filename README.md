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
make kubeconfig      # (опційно) доступ kubectl: kubectl get nodes
make apply-argocd    # 3. фаза 2 — встановлення Argo CD (створює admin-secret)
make apply           # 4. фаза 3 — argocd_application_set
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

## Маніфести застосунків (Де зберігаються applications)

Застосунки для розкатки через ArgoCD зберігаються в директорії:
`applications/namespaces/`

Модуль `argocd-apps` створює `ApplicationSet` із git-генератором каталогів, що читає
шлях `applications/namespaces/*` з репозиторію `app_repo_url`
(`https://github.com/swangee/goit-mlops-cicd.git`, гілка `lesson9`). Argo CD створює
по одному `Application` (`ns-<папка>`) на кожен підкаталог і деплоїть його вміст у
namespace з тією ж назвою (`CreateNamespace=true`, `recurse`).

Розкладка по namespace (модель «централізований hub»):

| namespace | Що там | Як зʼявляється |
|-----------|--------|----------------|
| `argocd` | ArgoCD + усі `Application`-обʼєкти (App-of-Apps) | Terraform (ns + Helm) |
| `infra-tools` | MinIO, PostgreSQL (спільне сховище/БД) | `CreateNamespace=true` |
| `monitoring` | kube-prometheus-stack, Pushgateway | `CreateNamespace=true` |
| `mlflow` | MLflow Tracking Server | `CreateNamespace=true` |
| `application` | demo-nginx | `ns.yaml` у папці |

Важливо: ArgoCD стежить за `Application`-обʼєктами **лише у власному ns (`argocd`)**
(apps-in-any-namespace вимкнено). Тому `Application`-CRD інфри лежать у папці
`applications/namespaces/argocd/` (щоб потрапити в ns `argocd`), а самі сервіси
розводяться по цільових namespace через `destination.namespace`. Сирі маніфести
(як `application/`) деплояться у власний namespace напряму.

Щоб додати новий застосунок: для Helm-сервісу — додати `Application`-CRD у папку
`argocd/` з потрібним `destination.namespace`; для звичайних маніфестів — створити
нову папку-namespace з YAML-ресурсами.

## Підключення до Nginx Service

Щоб підключитися до розгорнутого сервісу Nginx локально, використайте `kubectl port-forward`:

```bash
kubectl port-forward svc/nginx-service -n application 8081:80
```

Після цього Nginx буде доступний за адресою [http://localhost:8081](http://localhost:8081).

## Підключення до ArgoCD

Щоб отримати початковий пароль адміністратора (користувач `admin`), виконайте команду:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Щоб підключитися до веб-інтерфейсу ArgoCD локально, використайте `kubectl port-forward`:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Після цього ArgoCD буде доступний за адресою [http://localhost:8080](http://localhost:8080).

## Видалення

```bash
# kubeconfig має вказувати на кластер (k8s/helm/argocd-ресурси видаляються першими)
make destroy
```
