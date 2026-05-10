import argparse
from pathlib import Path

import torch
from torchvision import models


def export(out="model.pt"):
    m = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.IMAGENET1K_V1)
    m.eval()
    dummy = torch.zeros(1, 3, 224, 224)
    scripted = torch.jit.trace(m, dummy)
    torch.jit.save(scripted, out)
    size = Path(out).stat().st_size / 1024 / 1024
    print(f"saved {out} ({size:.1f} MB)")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", default="model.pt")
    args = ap.parse_args()
    export(args.output)
