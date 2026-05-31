import os
import shutil
from dotenv import load_dotenv
load_dotenv()

import optuna
import mlflow
from sklearn.datasets import load_iris
from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, log_loss

from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

experiment_name = "Iris Classification"
best_model_dir = os.path.join(os.path.dirname(__file__), "best_model")
n_trials = 10

mlflow.set_tracking_uri(os.environ["MLFLOW_TRACKING_URI"])
pushgateway_url = os.environ["PUSHGATEWAY_URL"]

experiment = mlflow.get_experiment_by_name(experiment_name)
if experiment is None:
    experiment_id = mlflow.create_experiment(experiment_name)
    print(f"✅ Створено експеримент '{experiment_name}' (ID={experiment_id})")
else:
    experiment_id = experiment.experiment_id
    print(f"ℹ️ Використовується існуючий експеримент '{experiment_name}' (ID={experiment_id})")

# Датасет завантажуємо один раз — спліт фіксований, щоб порівняння було чесним
X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)


def objective(trial):
    learning_rate = trial.suggest_float("learning_rate", 1e-3, 0.5, log=True)
    epochs = trial.suggest_int("epochs", 50, 300)

    with mlflow.start_run(experiment_id=experiment_id) as run:
        run_id = run.info.run_id

        trial.set_user_attr("run_id", run_id)

        mlflow.log_param("learning_rate", learning_rate)
        mlflow.log_param("epochs", epochs)

        model = SGDClassifier(
            loss="log_loss",
            learning_rate="constant",
            eta0=learning_rate,
            max_iter=epochs,
            random_state=42,
        )
        model.fit(X_train, y_train)

        y_pred = model.predict(X_test)
        y_proba = model.predict_proba(X_test)

        acc = accuracy_score(y_test, y_pred)
        loss = log_loss(y_test, y_proba, labels=model.classes_)

        # Логуємо метрики та зберігаємо модель як артефакт у MLflow
        mlflow.log_metric("accuracy", acc)
        mlflow.log_metric("loss", loss)
        mlflow.sklearn.log_model(model, "model")


        registry = CollectorRegistry()
        Gauge("model_accuracy", "Accuracy на тестовій вибірці", registry=registry).set(acc)
        Gauge("model_loss", "Log loss на тестовій вибірці", registry=registry).set(loss)
        push_to_gateway(
            pushgateway_url,
            job="train_and_push",
            grouping_key={"run_id": run_id},
            registry=registry,
        )

        print(
            f"▶️ trial #{trial.number} run_id={run_id} "
            f"lr={learning_rate:.4f} epochs={epochs} "
            f"→ accuracy={acc:.4f} loss={loss:.4f} (запушено в PushGateway)"
        )

    return acc


study = optuna.create_study(direction="maximize", study_name=experiment_name)
study.optimize(objective, n_trials=n_trials)

best_trial = study.best_trial
best_run_id = best_trial.user_attrs["run_id"]

print(
    f"\n🏆 Найкращий trial #{best_trial.number}: run_id={best_run_id} "
    f"accuracy={best_trial.value:.4f} params={best_trial.params}"
)

local_model_path = mlflow.artifacts.download_artifacts(
    run_id=best_run_id, artifact_path="model"
)

if os.path.exists(best_model_dir):
    shutil.rmtree(best_model_dir)

shutil.copytree(local_model_path, best_model_dir)

print(f"📂 Модель найкращого запуску скопійовано в {best_model_dir}")
