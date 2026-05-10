# Lesson 3 — контейнеризація ML-моделі

## Файли

- `install_dev_tools.sh` — встановлює docker, python і ML залежності
- `export_model.py` — зберігає mobilenet_v2 у `model.pt`
- `inference.py` — топ-3 передбачення для картинки
- `Dockerfile.fat` / `Dockerfile.slim`
- `report.md` — порівняння образів

## Як запустити

Спочатку згенерувати модель:

```bash
uv venv
uv pip install torch torchvision pillow
uv run python export_model.py
```

Зібрати образи:

```bash
docker build -f Dockerfile.fat -t ml-fat .
docker build -f Dockerfile.slim -t ml-slim .
```

Запустити inference:

```bash
docker run --rm -v "$(pwd)":/data ml-slim python /app/inference.py /data/cat.webp
```

Або локально без докера:

```bash
uv run python inference.py cat.webp
uv run python inference.py cat.webp --top 5
```

## Setup-скрипт

```bash
chmod +x install_dev_tools.sh
./install_dev_tools.sh
```