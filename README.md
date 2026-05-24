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
`applications/goit-lesson7/namespaces/`

Кожен підкаталог у цій папці (наприклад, `application` або `infra-tools`) містить YAML-маніфести ресурсів (Deployment, Service, Namespace тощо) для окремого застосунку.

Модуль `argocd-apps` створює `ApplicationSet` із git-генератором каталогів, що читає
шлях `applications/goit-lesson7/namespaces/*` з репозиторію `app_repo_url`
(`https://github.com/swangee/goit-mlops-cicd.git`, гілка `lesson7`).

Argo CD автоматично знаходить ці папки та розгортає по одному `Application` на кожен підкаталог. Щоб додати новий застосунок для розкатки, достатньо створити нову папку з маніфестами в цій директорії та зберегти зміни в Git.

## Підключення до Nginx Service

Щоб підключитися до розгорнутого сервісу Nginx локально, використайте `kubectl port-forward`:

```bash
kubectl port-forward svc/nginx-service -n application 8081:80
```

Після цього Nginx буде доступний за адресою [http://localhost:8081](http://localhost:8081).

## Підключення до ArgoCD

Щоб отримати початковий пароль адміністратора (користувач `admin`), виконайте команду:

```bash
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Щоб підключитися до веб-інтерфейсу ArgoCD локально, використайте `kubectl port-forward`:

```bash
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```

Після цього ArgoCD буде доступний за адресою [http://localhost:8080](http://localhost:8080).

## Видалення

```bash
# kubeconfig має вказувати на кластер (k8s/helm/argocd-ресурси видаляються першими)
make destroy
```
