"""
Disease class labels — 6 cat skin disease classes in pawscan_swin_final.pth.
Index order is alphabetical (PyTorch ImageFolder default sort).
"""

DISEASE_CLASSES = [
    "Alopecia",       # 0 — 324 train / 65 test
    "Dermatitis",     # 1 — 343 train / 69 test
    "Flea Allergy",   # 2 — 534 train / 107 test
    "Healthy",        # 3 — 245 train / 49 test
    "Ringworm",       # 4 — 687 train / 137 test
    "Scabies",        # 5 — 465 train / 93 test
]

NUM_CLASSES = len(DISEASE_CLASSES)


def get_disease(class_index: int) -> dict:
    """Return disease name dict for fallback use. Actual metadata lives in swin_fusion.py."""
    if 0 <= class_index < NUM_CLASSES:
        return {"name": DISEASE_CLASSES[class_index]}
    return {"name": "Healthy"}
