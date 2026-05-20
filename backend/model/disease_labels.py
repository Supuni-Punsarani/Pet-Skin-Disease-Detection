"""
Disease class labels — matches the 6 classes in pawscan_swin_final.pth exactly.
Index order matches the 'disease_classes' list embedded in the checkpoint.
"""

DISEASE_CLASSES = [
    "Bacterial Dermatosis",         # 0
    "Demodicosis",                  # 1
    "Fungal Infections",            # 2
    "Healthy",                      # 3
    "Hypersensitivity Dermatitis",  # 4
    "Ringworm",                     # 5
]

NUM_CLASSES = len(DISEASE_CLASSES)


def get_disease(class_index: int) -> dict:
    """Return disease name dict for fallback use. Actual metadata lives in swin_fusion.py."""
    if 0 <= class_index < NUM_CLASSES:
        return {"name": DISEASE_CLASSES[class_index]}
    return {"name": "Healthy"}
