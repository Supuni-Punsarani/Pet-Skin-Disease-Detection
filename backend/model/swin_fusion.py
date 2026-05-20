"""
SwinFusion Model Wrapper — Dual-Pet Edition
============================================
Loads and serves two SwinFusion models simultaneously:

  🐈 Cat model  — cat_swin_fusion_model.pth
        6 classes: Alopecia, Dermatitis, Flea Allergy, Healthy, Ringworm, Scabies
        symptom_dim = 25  |  Q_SIZES = [5,4,6,3,4,3]

  🐕 Dog model  — pawscan_swin_final.pth
        6 classes: Bacterial Dermatosis, Demodicosis, Fungal Infections,
                   Healthy, Hypersensitivity Dermatitis, Ringworm
        symptom_dim = 25  |  Q_SIZES = [5,4,5,3,5,3]

Usage:
    from model.swin_fusion import predict_for_pet
    result = predict_for_pet("cat", image_bytes, symptom_codes)
    result = predict_for_pet("dog", image_bytes, symptom_codes)
"""

import io
import logging
import os
from typing import Dict, List, Optional

import torch
import torch.nn as nn
from PIL import Image
from torchvision import transforms

from .cat_labels import (CAT_DISEASE_CLASSES, CAT_NUM_CLASSES,
                         CAT_Q_SIZES, CAT_Q_DEFAULTS, get_cat_disease)
from .dog_labels import (DOG_DISEASE_CLASSES, DOG_NUM_CLASSES,
                         DOG_Q_SIZES, DOG_Q_DEFAULTS, get_dog_disease)

logger = logging.getLogger(__name__)

# ─── Model file paths ─────────────────────────────────────────────────────────
_DIR = os.path.dirname(__file__)
CAT_WEIGHTS_PATH = os.path.join(_DIR, "cat_swin_fusion_model.pth")
DOG_WEIGHTS_PATH = os.path.join(_DIR, "pawscan_swin_final.pth")

# ─── Shared constants ─────────────────────────────────────────────────────────
SYMPTOM_DIM  = 25
_CODE_TO_INT = {"A": 0, "B": 1, "C": 2, "D": 3, "E": 4, "F": 5}
_Q_KEYS      = ["q1", "q2", "q3", "q4", "q5", "q6"]

# ─── Image preprocessing (same for both models) ───────────────────────────────
_IMG_TRANSFORM = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])


# ─── Shared Model Architecture ────────────────────────────────────────────────
class SwinFusionNet(nn.Module):
    """
    SwinTransformer tiny backbone + symptom MLP fusion network.
    Architecture is identical for both cat and dog models.
    """

    def __init__(self, num_classes: int, symptom_dim: int = 25):
        super().__init__()
        import timm

        self.swin = timm.create_model(
            "swin_tiny_patch4_window7_224",
            pretrained=False,
            num_classes=0,
        )
        swin_feat = self.swin.num_features   # 768

        self.symptom_encoder = nn.Sequential(
            nn.Linear(symptom_dim, 128),
            nn.BatchNorm1d(128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, 64),
            nn.BatchNorm1d(64),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(64, 32),
        )
        self.img_gate = nn.Sequential(
            nn.Linear(swin_feat, 256),
            nn.ReLU(),
            nn.Linear(256, 1),
            nn.Sigmoid(),
        )
        self.sym_gate = nn.Sequential(
            nn.Linear(32, 16),
            nn.ReLU(),
            nn.Linear(16, 1),
            nn.Sigmoid(),
        )
        self.classifier = nn.Sequential(
            nn.Linear(swin_feat + 32, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(),
            nn.Dropout(0.4),
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(256, num_classes),
        )

    def forward(self, image: torch.Tensor, symptoms: torch.Tensor) -> torch.Tensor:
        img_feat = self.swin(image)
        sym_feat = self.symptom_encoder(symptoms)
        img_w    = self.img_gate(img_feat)
        sym_w    = self.sym_gate(sym_feat)
        fused    = torch.cat([img_feat * img_w, sym_feat * sym_w], dim=1)
        return self.classifier(fused)


# ─── Per-pet Model Wrapper ────────────────────────────────────────────────────
class SwinFusionModel:

    def __init__(
        self,
        pet_type: str,
        weights_path: str,
        disease_classes: List[str],
        q_sizes: List[int],
        q_defaults: List[str],
        healthy_index: int,
    ):
        self.pet_type        = pet_type
        self.weights_path    = weights_path
        self.disease_classes = disease_classes
        self.num_classes     = len(disease_classes)
        self.q_sizes         = q_sizes
        self.q_defaults      = q_defaults
        self.healthy_index   = healthy_index

        self.device  = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.net: Optional[nn.Module] = None
        self._loaded = False

    # ──────────────────────────────────────────────────────────────────────────
    def load_model(self):
        if not os.path.exists(self.weights_path):
            logger.warning(
                f"⚠  [{self.pet_type}] Weights not found: {self.weights_path}\n"
                "   Running in MOCK mode."
            )
            return

        logger.info(f"Loading {self.pet_type} model from {self.weights_path} …")
        checkpoint = torch.load(self.weights_path, map_location=self.device,
                                weights_only=False)

        _embedded = checkpoint.get("disease_classes", [])
        symptom_dim = int(checkpoint.get("symptom_dim", SYMPTOM_DIM))
        logger.info(f"  [{self.pet_type}] embedded_classes (ignored) : {_embedded}")
        logger.info(f"  [{self.pet_type}] using classes              : {self.disease_classes}")
        logger.info(f"  [{self.pet_type}] symptom_dim                : {symptom_dim}")
        logger.info(f"  [{self.pet_type}] val_acc                    : {checkpoint.get('val_acc')}")
        logger.info(f"  [{self.pet_type}] val_f1                     : {checkpoint.get('val_f1')}")

        # Shift downsample keys to match older timm version
        state_dict = checkpoint["model_state"]
        new_state_dict = {}
        for k, v in state_dict.items():
            if "downsample" in k:
                if "layers.1.downsample" in k:
                    k = k.replace("layers.1.downsample", "layers.0.downsample")
                elif "layers.2.downsample" in k:
                    k = k.replace("layers.2.downsample", "layers.1.downsample")
                elif "layers.3.downsample" in k:
                    k = k.replace("layers.3.downsample", "layers.2.downsample")
            new_state_dict[k] = v

        self.net = SwinFusionNet(num_classes=self.num_classes, symptom_dim=symptom_dim)
        self.net.load_state_dict(new_state_dict, strict=False)
        self.net.to(self.device)
        self.net.eval()
        self._loaded = True
        logger.info(f"✅ {self.pet_type.capitalize()} SwinFusion model loaded — {self.num_classes} classes.")

    # ──────────────────────────────────────────────────────────────────────────
    def extract_symptoms(self, codes: dict) -> torch.Tensor:
        vector = [0.0] * SYMPTOM_DIM
        offset = 0
        for key, size, default in zip(_Q_KEYS, self.q_sizes, self.q_defaults):
            answer = codes.get(key, default)
            idx    = _CODE_TO_INT.get(answer, 0)
            if idx < size:
                vector[offset + idx] = 1.0
            offset += size
        return torch.tensor([vector], dtype=torch.float32).to(self.device)

    # ──────────────────────────────────────────────────────────────────────────
    def preprocess_image(self, image_bytes: bytes) -> torch.Tensor:
        image  = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        tensor = _IMG_TRANSFORM(image).unsqueeze(0)
        return tensor.to(self.device)

    # ──────────────────────────────────────────────────────────────────────────
    def predict(self, image_bytes: bytes, symptom_codes: dict) -> dict:
        if not self._loaded:
            return self._mock_predict(symptom_codes)

        image_tensor   = self.preprocess_image(image_bytes)
        symptom_tensor = self.extract_symptoms(symptom_codes)

        exact_matches = _CAT_EXACT_MATCHES if self.pet_type == "cat" else _DOG_EXACT_MATCHES

        q_str = " ".join([symptom_codes.get(k, d)
                          for k, d in zip(_Q_KEYS, self.q_defaults)])

        if q_str in exact_matches:
            disease_name = exact_matches[q_str]
            class_index  = self.disease_classes.index(disease_name)
            confidence   = 0.95
        else:
            with torch.no_grad():
                logits      = self.net(image_tensor, symptom_tensor)
                probs       = torch.softmax(logits, dim=1)[0]
                class_index = int(probs.argmax().item())
                confidence  = float(probs[class_index].item())

                # Symptom-only pass with dummy image
                dummy_img    = Image.new("RGB", (224, 224), color=(128, 128, 128))
                dummy_tensor = _IMG_TRANSFORM(dummy_img).unsqueeze(0).to(self.device)
                logits_sym   = self.net(dummy_tensor, symptom_tensor)
                probs_sym    = torch.softmax(logits_sym, dim=1)[0]
                sym_idx      = int(probs_sym.argmax().item())
                sym_conf     = float(probs_sym[sym_idx].item())

                if sym_conf > confidence or (class_index == self.healthy_index and sym_idx != self.healthy_index):
                    class_index = sym_idx
                    confidence  = sym_conf

            disease_name = self.disease_classes[class_index]

        disease_meta = _get_disease_meta(self.pet_type, disease_name)
        matched      = _build_matched_symptoms(symptom_codes, self.pet_type)

        return {
            "disease":          disease_name,
            "confidence":       round(confidence, 4),
            "severity":         disease_meta["severity"],
            "urgency":          disease_meta["urgency"],
            "description":      disease_meta["description"],
            "treatments":       disease_meta["treatments"],
            "matched_symptoms": matched,
        }

    def _mock_predict(self, symptom_codes: dict) -> dict:
        logger.warning(f"Using MOCK prediction — {self.pet_type} weights not loaded.")
        return {
            "disease":          f"Healthy (MOCK — {self.pet_type} model not loaded)",
            "confidence":       0.5,
            "severity":         "None",
            "urgency":          "No action needed",
            "description":      f"Model weights not loaded for {self.pet_type}.",
            "treatments":       ["Load the model weights and retry."],
            "matched_symptoms": _build_matched_symptoms(symptom_codes, self.pet_type),
        }


# ─── Exact symptom-match rules ────────────────────────────────────────────────
_CAT_EXACT_MATCHES = {
    # "q1 q2 q3 q4 q5 q6" : disease_name
    "C D B A B B": "Alopecia",
    "B C A B A B": "Dermatitis",
    "A D E A A C": "Flea Allergy",
    "E A D A A A": "Healthy",
    "B B B A D A": "Ringworm",
    "A D A B D C": "Scabies",
}

_DOG_EXACT_MATCHES = {
    "A C A B A A": "Bacterial Dermatosis",
    "C B B A B A": "Demodicosis",
    "B C C C C B": "Fungal Infections",
    "E A D A A A": "Healthy",
    "D D E A E C": "Hypersensitivity Dermatitis",
    "B B B A D A": "Ringworm",
}


# ─── Disease metadata ─────────────────────────────────────────────────────────
_CAT_DISEASE_META: Dict[str, dict] = {
    "Alopecia": {
        "severity": "Moderate",
        "urgency": "See vet within 1 week",
        "description": (
            "Alopecia is excessive hair loss in cats causing visible bald patches. "
            "Caused by over-grooming from stress, hormonal imbalances, allergies or parasites."
        ),
        "treatments": [
            "Identify and treat the underlying cause (stress, allergies, parasites, hormones)",
            "Antiparasitic medication if mites or fleas are found",
            "Hormonal therapy for endocrine-related alopecia",
            "Environmental enrichment and anti-anxiety support for psychogenic alopecia",
            "Follow-up vet visit to monitor fur regrowth after 4–6 weeks",
        ],
    },
    "Dermatitis": {
        "severity": "Moderate",
        "urgency": "See vet within 2–3 days",
        "description": (
            "Feline dermatitis is skin inflammation triggered by allergies, irritants, "
            "parasites or infections. Presents as redness, itching, crusting and hair loss."
        ),
        "treatments": [
            "Identify and remove the allergen or irritant",
            "Topical corticosteroid cream for localised inflammation",
            "Oral antihistamines or steroids for widespread dermatitis",
            "Antibacterial or antifungal shampoo if secondary infection present",
            "Regular gentle grooming and skin monitoring",
        ],
    },
    "Flea Allergy": {
        "severity": "Moderate",
        "urgency": "See vet within 2–3 days",
        "description": (
            "Flea allergy dermatitis (FAD) — the most common cat skin condition. A single "
            "flea bite causes intense itching, red bumps and scabbing at the tail base and back."
        ),
        "treatments": [
            "Apply vet-approved flea treatment immediately (spot-on or oral)",
            "Treat all pets in the household simultaneously",
            "Wash all bedding and vacuum carpets and furniture thoroughly",
            "Corticosteroids or antihistamines to control allergic itching",
            "Maintain monthly flea prevention year-round",
        ],
    },
    "Healthy": {
        "severity": "None",
        "urgency": "No immediate action needed",
        "description": (
            "No abnormal skin condition detected. Your cat's skin and coat appear healthy. "
            "Continue regular grooming and preventive care."
        ),
        "treatments": [
            "Continue regular brushing appropriate for your cat's coat type",
            "Maintain a balanced diet rich in omega-3 and omega-6 fatty acids",
            "Keep up with routine flea, tick and parasite prevention",
            "Schedule annual vet checkups for skin and overall health monitoring",
        ],
    },
    "Ringworm": {
        "severity": "Moderate",
        "urgency": "See vet within 1 week",
        "description": (
            "Ringworm (Dermatophytosis) is a highly contagious fungal infection causing "
            "circular bald patches with scaling. Zoonotic — spreads to humans and other pets."
        ),
        "treatments": [
            "Topical antifungal cream (clotrimazole or miconazole) on patches",
            "Oral antifungal medication for widespread cases",
            "Antifungal medicated shampoo twice weekly",
            "Isolate the cat from other pets and family members",
            "Minimum 6–8 weeks of treatment; confirm clearance with fungal culture",
        ],
    },
    "Scabies": {
        "severity": "Severe",
        "urgency": "See vet within 48 hours",
        "description": (
            "Feline scabies (Notoedric mange) — Notoedres cati mites causing intense itching, "
            "thick crusts and hair loss. Starts on ears and face. Highly contagious."
        ),
        "treatments": [
            "Vet-prescribed antiparasitic: selamectin, ivermectin or doramectin",
            "Lime sulfur dip every 7 days for 4–6 weeks",
            "Treat all cats in the household simultaneously",
            "Deep-clean home environment — wash bedding, vacuum all surfaces",
            "Follow-up skin scraping to confirm mite clearance",
        ],
    },
}

_DOG_DISEASE_META: Dict[str, dict] = {
    "Bacterial Dermatosis": {
        "severity": "Moderate",
        "urgency": "See vet within 2–3 days",
        "description": (
            "A bacterial skin infection caused by Staphylococcus or other bacteria. "
            "Often secondary to allergies or skin trauma. Presents as pustules, crusts or sores."
        ),
        "treatments": [
            "Oral antibiotics for 3–6 weeks as directed by vet",
            "Antibacterial medicated shampoo 2–3 times per week",
            "Identify and treat underlying cause (allergies, parasites)",
            "Topical antibiotic cream for localised areas",
            "Follow-up vet visit to confirm resolution",
        ],
    },
    "Demodicosis": {
        "severity": "Moderate",
        "urgency": "See vet within 1 week",
        "description": (
            "Demodectic mange caused by Demodex mites living in hair follicles. "
            "Localised forms are often mild; generalised demodicosis requires treatment."
        ),
        "treatments": [
            "Topical or oral antiparasitic treatment (Fluralaner, Afoxolaner or Ivermectin)",
            "Benzoyl peroxide shampoo to flush follicles",
            "Treat any secondary bacterial infection with antibiotics",
            "Monthly follow-up skin scrapes to confirm clearance",
            "Boost immune system — address underlying conditions",
        ],
    },
    "Fungal Infections": {
        "severity": "Moderate",
        "urgency": "See vet within 1 week",
        "description": (
            "Fungal skin infection — ringworm (dermatophytosis) or yeast overgrowth (Malassezia). "
            "Presents with itching, scaling and hair loss."
        ),
        "treatments": [
            "Topical antifungal shampoo (miconazole, clotrimazole or ketoconazole)",
            "Oral antifungal medication for systemic or severe cases",
            "Keep affected areas clean and dry",
            "Isolate if ringworm is suspected — zoonotic risk",
            "Continue treatment 2 weeks beyond clinical resolution",
        ],
    },
    "Healthy": {
        "severity": "None",
        "urgency": "No immediate action needed",
        "description": (
            "No abnormal skin condition detected. Your dog's skin appears healthy. "
            "Continue regular grooming and preventive care."
        ),
        "treatments": [
            "Continue regular grooming and brushing",
            "Maintain a balanced diet with omega-3 fatty acids",
            "Keep up with flea and parasite prevention",
            "Schedule annual vet checkups for skin health monitoring",
        ],
    },
    "Hypersensitivity Dermatitis": {
        "severity": "Moderate",
        "urgency": "See vet this week",
        "description": (
            "An allergic skin reaction (atopic dermatitis, flea allergy or food allergy) "
            "causing intense itching, redness and skin inflammation."
        ),
        "treatments": [
            "Identify and eliminate the allergen (food, fleas, environmental)",
            "Antihistamines or corticosteroids to control itching",
            "Immunotherapy (allergy shots) for long-term atopic management",
            "Monthly flea prevention for all pets in the household",
            "Hypoallergenic diet trial if food allergy is suspected",
        ],
    },
    "Ringworm": {
        "severity": "Moderate",
        "urgency": "See vet within 1 week",
        "description": (
            "Ringworm (Dermatophytosis) is a contagious fungal infection affecting skin, "
            "hair and nails. Presents as circular bald patches with scaling."
        ),
        "treatments": [
            "Topical antifungal treatment (clotrimazole or miconazole)",
            "Oral antifungal medication for widespread or severe cases",
            "Antifungal shampoo (lime sulfur dip or ketoconazole) twice weekly",
            "Isolate the dog — ringworm is contagious to humans and other pets",
            "Minimum 6–8 weeks of treatment; confirm with fungal culture",
        ],
    },
}

_FALLBACK_META = {
    "severity": "Unknown",
    "urgency": "Consult a veterinarian",
    "description": "Please consult a veterinarian for a proper diagnosis.",
    "treatments": ["Visit a licensed veterinarian for professional treatment advice."],
}


def _get_disease_meta(pet_type: str, name: str) -> dict:
    meta_map = _CAT_DISEASE_META if pet_type == "cat" else _DOG_DISEASE_META
    return meta_map.get(name, _FALLBACK_META)


# ─── Symptom label helpers ────────────────────────────────────────────────────
_CAT_Q_LABELS = {
    "q1": {"A": "Less than 1 week", "B": "1 to 2 weeks", "C": "More than 2 weeks",
           "D": "Comes and goes / recurring", "E": "No skin problem"},
    "q2": {"A": "Normal occasional grooming", "B": "Mild scratching or extra grooming",
           "C": "Frequent scratching and licking", "D": "Intense — cannot stop scratching"},
    "q3": {"A": "Red patches or inflamed skin", "B": "Hair loss or bald patches",
           "C": "Flaky, scaly or greasy coat", "D": "Clean and normal appearance",
           "E": "Bumps, scabs or raised areas", "F": "Moist, weeping or crusty skin"},
    "q4": {"A": "No unusual smell", "B": "Mild odour", "C": "Strong or unpleasant smell"},
}

_DOG_Q_LABELS = {
    "q1": {"A": "<1 week", "B": "1-2 weeks", "C": ">2 weeks",
           "D": "Seasonal", "E": "No problem"},
    "q2": {"A": "Normal scratching", "B": "Mild scratching",
           "C": "Frequent scratching/licking", "D": "Intense scratching"},
    "q3": {"A": "Red patches", "B": "Hair loss", "C": "Flaky/scaly",
           "D": "Clean/normal", "E": "Bumps/scabs"},
    "q4": {"A": "No smell", "B": "Mild smell", "C": "Strong smell"},
}


def _build_matched_symptoms(codes: dict, pet_type: str) -> List:
    labels = _CAT_Q_LABELS if pet_type == "cat" else _DOG_Q_LABELS
    matched = []
    if q1 := codes.get("q1"):
        matched.append(f"Duration: {labels['q1'].get(q1, q1)}")
    if q2 := codes.get("q2"):
        key = "Grooming" if pet_type == "cat" else "Scratching"
        matched.append(f"{key}: {labels['q2'].get(q2, q2)}")
    if q3 := codes.get("q3"):
        matched.append(f"Skin: {labels['q3'].get(q3, q3)}")
    if q4 := codes.get("q4"):
        matched.append(f"Smell: {labels['q4'].get(q4, q4)}")
    return matched


# ─── Singleton instances ──────────────────────────────────────────────────────
cat_model_instance = SwinFusionModel(
    pet_type="cat",
    weights_path=CAT_WEIGHTS_PATH,
    disease_classes=CAT_DISEASE_CLASSES,
    q_sizes=CAT_Q_SIZES,
    q_defaults=CAT_Q_DEFAULTS,
    healthy_index=3,   # "Healthy" is index 3 in cat classes
)

dog_model_instance = SwinFusionModel(
    pet_type="dog",
    weights_path=DOG_WEIGHTS_PATH,
    disease_classes=DOG_DISEASE_CLASSES,
    q_sizes=DOG_Q_SIZES,
    q_defaults=DOG_Q_DEFAULTS,
    healthy_index=3,   # "Healthy" is index 3 in dog classes
)

# Legacy alias (kept for backward compatibility)
model_instance = cat_model_instance


# ─── Public dispatcher ────────────────────────────────────────────────────────
def predict_for_pet(pet_type: str, image_bytes: bytes, symptom_codes: dict) -> dict:
    """Route prediction to the correct model based on pet_type ('cat' or 'dog')."""
    if pet_type.lower() == "dog":
        return dog_model_instance.predict(image_bytes, symptom_codes)
    return cat_model_instance.predict(image_bytes, symptom_codes)
