# Порівняння fat vs slim образу

## Розміри

```
$ docker image ls --format '{{.Repository}} {{.Size}}' ml-fat ml-slim
ml-fat   1.15GB
ml-slim  300MB
```

Slim менший приблизно у 4 рази. Основну вагу в обох образах дає сам PyTorch CPU wheel.

## Шари

```
$ docker image inspect ml-fat  --format '{{len .RootFS.Layers}}'
13
$ docker image inspect ml-slim --format '{{len .RootFS.Layers}}'
8
```

## Що ще можна зробити

- Замість `python:3.9-slim` взяти `python:3.9-alpine` або distroless — мінус ~100-200MB
- Замінити PyTorch на ONNX Runtime — wheel менший на ~700MB
- Викинути torchvision у runtime, лишити тільки torch (моделі вже у TorchScript)
- Використати `pip install --no-deps` і вручну прописати реальні залежності
