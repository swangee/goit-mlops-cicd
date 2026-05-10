import argparse
import json
import urllib.request
from pathlib import Path

import torch
from PIL import Image
from torchvision import transforms

LABELS_URL = "https://raw.githubusercontent.com/anishathalye/imagenet-simple-labels/master/imagenet-simple-labels.json"
LABELS_FILE = Path(__file__).parent / "imagenet_labels.json"

preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])


def get_labels():
    if LABELS_FILE.exists():
        return json.loads(LABELS_FILE.read_text())
    try:
        with urllib.request.urlopen(LABELS_URL, timeout=10) as r:
            data = json.loads(r.read())
        LABELS_FILE.write_text(json.dumps(data))
        return data
    except Exception:
        return [str(i) for i in range(1000)]


def predict(model, image_path, top_k=3):
    img = Image.open(image_path).convert("RGB")
    x = preprocess(img).unsqueeze(0)
    with torch.no_grad():
        logits = model(x)
    probs = torch.softmax(logits, dim=1)[0]
    top_probs, top_ids = probs.topk(top_k)
    labels = get_labels()
    return [(i, labels[i] if i < len(labels) else str(i), p)
            for p, i in zip(top_probs.tolist(), top_ids.tolist())]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("--model", default="model.pt")
    ap.add_argument("--top", type=int, default=3)
    args = ap.parse_args()

    if not Path(args.model).exists():
        raise SystemExit(f"model not found: {args.model}. run export_model.py first")

    model = torch.jit.load(args.model, map_location="cpu")
    model.eval()

    print(f"predicting on {args.image}")
    for rank, (idx, label, prob) in enumerate(predict(model, args.image, args.top), 1):
        print(f"  {rank}. [{idx}] {label}  {prob*100:.2f}%")


if __name__ == "__main__":
    main()
