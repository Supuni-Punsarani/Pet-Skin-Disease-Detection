"""Dog disease class labels — 6 classes in pawscan_swin_final.pth."""

DOG_DISEASE_CLASSES = [
    "Bacterial Dermatosis",       # 0
    "Demodicosis",                # 1
    "Fungal Infections",          # 2
    "Healthy",                    # 3
    "Hypersensitivity Dermatitis",# 4
    "Ringworm",                   # 5
]

DOG_NUM_CLASSES = len(DOG_DISEASE_CLASSES)

# Symptom encoding for dog model: Q_SIZES = [5,4,5,3,5,3] = 25
DOG_Q_SIZES    = [5, 4, 5, 3, 5, 3]
DOG_Q_DEFAULTS = ["E", "A", "D", "A", "A", "A"]


def get_dog_disease(class_index: int) -> dict:
    if 0 <= class_index < DOG_NUM_CLASSES:
        return {"name": DOG_DISEASE_CLASSES[class_index]}
    return {"name": "Healthy"}
