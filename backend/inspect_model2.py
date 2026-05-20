"""
inspect_model2.py — Extracts full metadata from pawscan_swin_final.pth
"""
import sys
import os

# Force UTF-8 output on Windows
sys.stdout.reconfigure(encoding='utf-8')

import torch

PTH_PATH = os.path.join("model", "pawscan_swin_final.pth")
data = torch.load(PTH_PATH, map_location="cpu", weights_only=False)

print("=== TOP-LEVEL KEYS ===")
for key in data.keys():
    val = data[key]
    print(f"  {key!r:25} -> {type(val).__name__}")

print("\n=== model_type ===")
print(" ", data.get("model_type", "NOT FOUND"))

print("\n=== symptom_dim ===")
print(" ", data.get("symptom_dim", "NOT FOUND"))

print("\n=== val_acc / val_f1 ===")
print("  val_acc:", data.get("val_acc", "NOT FOUND"))
print("  val_f1: ", data.get("val_f1", "NOT FOUND"))

print("\n=== disease_classes ===")
classes = data.get("disease_classes", None)
if classes is None:
    print("  NOT FOUND")
elif isinstance(classes, (list, tuple)):
    for i, c in enumerate(classes):
        print(f"  [{i}] {c}")
else:
    print(" ", classes)

print("\n=== model_state keys (first 10 + last 5) ===")
state = data.get("model_state", {})
keys = list(state.keys())
print(f"  Total parameter tensors: {len(keys)}")
for k in keys[:10]:
    print(f"  {k:60} shape={state[k].shape}")
print("  ...")
for k in keys[-5:]:
    print(f"  {k:60} shape={state[k].shape}")
