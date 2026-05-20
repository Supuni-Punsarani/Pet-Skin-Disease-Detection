"""Cat disease class labels — 6 classes in cat_swin_fusion_model.pth."""

CAT_DISEASE_CLASSES = [
    "Alopecia",       # 0 — 324 train / 65 test
    "Dermatitis",     # 1 — 343 train / 69 test
    "Flea Allergy",   # 2 — 534 train / 107 test
    "Healthy",        # 3 — 245 train / 49 test
    "Ringworm",       # 4 — 687 train / 137 test
    "Scabies",        # 5 — 465 train / 93 test
]

CAT_NUM_CLASSES = len(CAT_DISEASE_CLASSES)

# Symptom encoding for cat model: Q_SIZES = [5,4,6,3,4,3] = 25
CAT_Q_SIZES    = [5, 4, 6, 3, 4, 3]
CAT_Q_DEFAULTS = ["E", "A", "D", "A", "A", "A"]


def get_cat_disease(class_index: int) -> dict:
    if 0 <= class_index < CAT_NUM_CLASSES:
        return {"name": CAT_DISEASE_CLASSES[class_index]}
    return {"name": "Healthy"}
