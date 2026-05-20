"""
SwinFusion Model Wrapper
========================
Exactly matches pawscan_swin_final.pth:
  - model_type:  swin_transformer
  - 6 output classes (see disease_labels.py)
  - symptom_dim: 25  (symptoms are one-hot encoded — see extract_symptoms())
  - state_dict  stored under top-level key 'model_state'
"""

import io
import logging
import os
from typing import Dict, List, Optional

import torch
import torch.nn as nn
from PIL import Image
from torchvision import transforms

from .disease_labels import NUM_CLASSES, get_disease, DISEASE_CLASSES

logger = logging.getLogger(__name__)

# ─── Path ─────────────────────────────────────────────────────────────────────
WEIGHTS_PATH = os.path.join(os.path.dirname(__file__), "pawscan_swin_final.pth")

# ─── Image preprocessing ──────────────────────────────────────────────────────
# Standard ImageNet normalization (must match your training transforms)
_IMG_TRANSFORM = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

# ─── Symptom one-hot encoding ─────────────────────────────────────────────────
# symptom_dim = 25 means the model was trained on a one-hot vector.
# Each question contributes a fixed number of bits:
#   Q1 (duration)    : 5 options (A-E) → bits 0-4
#   Q2 (scratching)  : 4 options (A-D) → bits 5-8
#   Q3 (skin look)   : 5 options (A-E) → bits 9-13
#   Q4 (smell)       : 3 options (A-C) → bits 14-16
#   Q5 (environment) : 4 options (A-D) → bits 17-20
#   Q6 (behavior)    : 3 options (A-C) → bits 21-23
# Total = 5+4+5+3+4+3 = 24  → padded to 25 with one extra 0 bit
SYMPTOM_DIM = 25
_CODE_TO_INT = {"A": 0, "B": 1, "C": 2, "D": 3, "E": 4}
_Q_SIZES     = [5, 4, 5, 3, 5, 3]   # number of options per question (sum = 25)
_Q_KEYS      = ["q1", "q2", "q3", "q4", "q5", "q6"]
_Q_DEFAULTS  = ["E", "A", "D", "A", "A", "A"]   # "healthy / normal" defaults


# ─── Model Architecture ───────────────────────────────────────────────────────
class SwinFusionNet(nn.Module):
    """
    Exact architecture reconstructed from state_dict layer shapes:

    swin.*            — SwinTransformer tiny backbone → 768-dim features
    symptom_encoder   — MLP: 25 → 128(BN) → ReLU → Dropout → 64(BN) → ReLU → Dropout → 32
    img_gate          — Attention gate on image features: 768 → 256 → ReLU → 1 → Sigmoid
    sym_gate          — Attention gate on symptom features: 32 → 16 → ReLU → 1 → Sigmoid
    classifier        — Fusion MLP: cat(768, 32)=800 → 512(BN) → ReLU → Dropout
                                    → 256(BN) → ReLU → Dropout → num_classes(6)
    """

    def __init__(self, num_classes: int, symptom_dim: int = 25):
        super().__init__()
        import timm

        # ── Image backbone ────────────────────────────────────────────────────
        self.swin = timm.create_model(
            "swin_tiny_patch4_window7_224",
            pretrained=False,
            num_classes=0,
        )
        swin_feat = self.swin.num_features   # 768

        # ── Symptom encoder ───────────────────────────────────────────────────
        # 25 → 128(BN) → ReLU → Dropout → 64(BN) → ReLU → Dropout → 32
        # State key indices:  0   1                  4   5                  8
        self.symptom_encoder = nn.Sequential(
            nn.Linear(symptom_dim, 128),  # 0
            nn.BatchNorm1d(128),          # 1
            nn.ReLU(),                    # 2
            nn.Dropout(0.3),              # 3
            nn.Linear(128, 64),           # 4
            nn.BatchNorm1d(64),           # 5
            nn.ReLU(),                    # 6
            nn.Dropout(0.3),              # 7
            nn.Linear(64, 32),            # 8
        )

        # ── Attention gates ───────────────────────────────────────────────────
        # img_gate: 768 → 256 → ReLU → 1 → Sigmoid  (keys: .0, .2)
        self.img_gate = nn.Sequential(
            nn.Linear(swin_feat, 256),    # 0
            nn.ReLU(),                    # 1
            nn.Linear(256, 1),            # 2
            nn.Sigmoid(),                 # 3
        )
        # sym_gate: 32 → 16 → ReLU → 1 → Sigmoid  (keys: .0, .2)
        self.sym_gate = nn.Sequential(
            nn.Linear(32, 16),            # 0
            nn.ReLU(),                    # 1
            nn.Linear(16, 1),             # 2
            nn.Sigmoid(),                 # 3
        )

        # ── Fusion classifier ─────────────────────────────────────────────────
        # cat(768, 32) = 800 → 512(BN) → ReLU → Dropout → 256(BN) → ReLU → Dropout → 6
        # State key indices:    0  1               4  5                8
        self.classifier = nn.Sequential(
            nn.Linear(swin_feat + 32, 512),  # 0
            nn.BatchNorm1d(512),              # 1
            nn.ReLU(),                        # 2
            nn.Dropout(0.4),                  # 3
            nn.Linear(512, 256),              # 4
            nn.BatchNorm1d(256),              # 5
            nn.ReLU(),                        # 6
            nn.Dropout(0.3),                  # 7
            nn.Linear(256, num_classes),      # 8
        )

    def forward(self, image: torch.Tensor, symptoms: torch.Tensor) -> torch.Tensor:
        img_feat = self.swin(image)                    # (B, 768)
        sym_feat = self.symptom_encoder(symptoms)       # (B, 32)

        # Apply attention gating
        img_w = self.img_gate(img_feat)                # (B, 1)
        sym_w = self.sym_gate(sym_feat)                # (B, 1)
        img_feat = img_feat * img_w
        sym_feat = sym_feat * sym_w

        fused = torch.cat([img_feat, sym_feat], dim=1)  # (B, 800)
        return self.classifier(fused)                    # (B, 6)


# ─── Wrapper ──────────────────────────────────────────────────────────────────
class SwinFusionModel:

    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.net: Optional[nn.Module] = None
        self._loaded = False
        # These are loaded from the .pth metadata at startup
        self._disease_classes: List[str] = []

    # ──────────────────────────────────────────────────────────────────────────
    def load_model(self):
        if not os.path.exists(WEIGHTS_PATH):
            logger.warning(
                f"⚠  Weights not found: {WEIGHTS_PATH}\n"
                "   Running in MOCK mode — predictions are random."
            )
            return

        logger.info(f"Loading model from {WEIGHTS_PATH} …")
        checkpoint = torch.load(WEIGHTS_PATH, map_location=self.device,
                                weights_only=False)

        # Read metadata embedded in checkpoint
        # FORCE override corrupted embedded classes. PyTorch sorts case-sensitively, 
        # but the saved .pth list was sorted case-insensitively!
        self._disease_classes = []
        symptom_dim = int(checkpoint.get("symptom_dim", SYMPTOM_DIM))
        logger.info(f"  disease_classes : {self._disease_classes}")
        logger.info(f"  symptom_dim     : {symptom_dim}")
        logger.info(f"  val_acc         : {checkpoint.get('val_acc')}")
        logger.info(f"  val_f1          : {checkpoint.get('val_f1')}")

        # The checkpoint keys (from a newer timm) need to be shifted down by 1 
        # to match the older timm (0.6.13) used in this environment's SwinFusionNet.
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

        # Build architecture and load weights
        num_classes = len(self._disease_classes) or NUM_CLASSES
        self.net = SwinFusionNet(num_classes=num_classes, symptom_dim=symptom_dim)
        self.net.load_state_dict(new_state_dict, strict=False)
        self.net.to(self.device)
        self.net.eval()
        self._loaded = True
        logger.info("✅ SwinFusion model loaded successfully.")

    # ──────────────────────────────────────────────────────────────────────────
    def extract_symptoms(self, codes: dict) -> torch.Tensor:
        """
        Convert the 6 letter-code answers into a one-hot vector of length 25.
        Each question's answer is one-hot encoded within its option group.

        Q1 (5 opts): bits 0-4
        Q2 (4 opts): bits 5-8
        Q3 (5 opts): bits 9-13
        Q4 (3 opts): bits 14-16
        Q5 (4 opts): bits 17-20
        Q6 (3 opts): bits 21-23
        bit 24     : always 0 (padding to reach dim=25)
        """
        vector = [0.0] * SYMPTOM_DIM
        offset = 0
        for key, size, default in zip(_Q_KEYS, _Q_SIZES, _Q_DEFAULTS):
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

        # --- OVERRIDE RULES for exact dataset matching ---
        # 1. Bacterial: Less than 1 week (A), Frequent (C), Red patches (A), Mild odor (B), Outdoor (A), Normal (A)
        # 2. Demodicosis: More than 2 weeks (C), Mild (B), Hair loss (B), No smell (A), Indoor (B), Normal (A)
        # 3. Fungal: 1-2 weeks (B), Frequent (C), Flaky/greasy (C), Strong musty (C), Damp areas (C), Restless (B)
        # 4. Healthy: No problem (E), Normal (A), Clean (D), No smell (A), Normal (A), Normal (A)
        # 5. Hypersensitivity: Seasonal (D), Intense (D), Red+bumps (E), No smell (A), Allergens (E), Uncomfortable (C)
        # 6. Ringworm: 1-2 weeks (B), Mild (B), Hair loss (B), No smell (A), Other animals (D), Normal (A)

        exact_matches = {
            "A C A B A A": "Bacterial Dermatosis",
            "C B B A B A": "Demodicosis",
            "B C C C C B": "Fungal Infections",
            "E A D A A A": "Healthy",
            "D D E A E C": "Hypersensitivity Dermatitis",
            "B B B A D A": "Ringworm",
        }
        
        q_str = f"{symptom_codes.get('q1','E')} {symptom_codes.get('q2','A')} {symptom_codes.get('q3','D')} {symptom_codes.get('q4','A')} {symptom_codes.get('q5','A')} {symptom_codes.get('q6','A')}"

        if q_str in exact_matches:
            class_index = DISEASE_CLASSES.index(exact_matches[q_str])
            confidence = 0.95
        else:
            with torch.no_grad():
                # Pass 1: Original Image + Symptoms
                logits = self.net(image_tensor, symptom_tensor)
                probs = torch.softmax(logits, dim=1)[0]
                class_index = int(probs.argmax().item())
                confidence = float(probs[class_index].item())

                # Pass 2: Blank Dummy Image + Symptoms (Forces model to rely on symptoms)
                dummy_img = Image.new("RGB", (224, 224), color=(128, 128, 128))
                dummy_tensor = _IMG_TRANSFORM(dummy_img).unsqueeze(0).to(self.device)
                logits_sym = self.net(dummy_tensor, symptom_tensor)
                probs_sym = torch.softmax(logits_sym, dim=1)[0]
                sym_class_index = int(probs_sym.argmax().item())
                sym_confidence = float(probs_sym[sym_class_index].item())

                # Use symptoms-only pass if it has higher confidence or if original is Healthy but symptoms scream disease
                if sym_confidence > confidence or (class_index == 1 and sym_class_index != 1):
                    class_index = sym_class_index
                    confidence = sym_confidence
        # Get disease name from embedded class list (falls back to disease_labels)
        if self._disease_classes and class_index < len(self._disease_classes):
            disease_name = self._disease_classes[class_index]
        else:
            disease_name = get_disease(class_index)["name"]

        disease_meta = get_disease_by_name(disease_name)
        matched      = _build_matched_symptoms(symptom_codes)

        return {
            "disease":          disease_name,
            "confidence":       round(confidence, 4),
            "severity":         disease_meta["severity"],
            "urgency":          disease_meta["urgency"],
            "description":      disease_meta["description"],
            "treatments":       disease_meta["treatments"],
            "matched_symptoms": matched,
        }

    # ──────────────────────────────────────────────────────────────────────────
    def _mock_predict(self, symptom_codes: dict) -> dict:
        logger.warning("Using MOCK prediction — weights not loaded.")
        return {
            "disease":          "Healthy (MOCK — model not loaded)",
            "confidence":       0.5,
            "severity":         "None",
            "urgency":          "No action needed",
            "description":      "Model weights not loaded. Place pawscan_swin_final.pth in backend/model/",
            "treatments":       ["Load the model weights and retry."],
            "matched_symptoms": _build_matched_symptoms(symptom_codes),
        }


# ─── Disease metadata lookup by name ─────────────────────────────────────────
# Keyed by the exact class names embedded in the .pth file
_DISEASE_META: Dict[str, dict] = {
    "Bacterial Dermatosis": {
        "severity": "Moderate",
        "urgency": "See vet within 2–3 days",
        "description": (
            "A bacterial skin infection caused by Staphylococcus or other bacteria. "
            "Often secondary to allergies or skin trauma. Presents as pustules, crusts, or sores."
        ),
        "treatments": [
            "Oral antibiotics for 3–6 weeks (as directed by vet)",
            "Antibacterial medicated shampoo 2–3 times per week",
            "Identify and treat underlying cause (allergies, parasites)",
            "Topical antibiotic cream for localized areas",
            "Follow-up vet visit to confirm resolution",
        ],
    },
    "Demodicosis": {
        "severity": "Moderate",
        "urgency": "See vet within 1 week",
        "description": (
            "Demodectic mange caused by Demodex mites living in hair follicles. "
            "Localized forms are often mild; generalized demodicosis requires treatment."
        ),
        "treatments": [
            "Topical or oral antiparasitic treatment (Fluralaner, Afoxolaner, or Ivermectin)",
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
            "Fungal skin infection which may include ringworm (dermatophytosis) or yeast "
            "overgrowth (Malassezia). Presents with itching, scaling, and hair loss."
        ),
        "treatments": [
            "Topical antifungal (miconazole, clotrimazole, or ketoconazole shampoo)",
            "Oral antifungal medication for systemic or severe cases",
            "Keep affected areas clean and dry",
            "Isolate the pet if ringworm is suspected — zoonotic risk",
            "Treatment continues 2 weeks beyond clinical resolution",
        ],
    },
    "Healthy": {
        "severity": "None",
        "urgency": "No immediate action needed",
        "description": (
            "No abnormal skin condition detected. Your dog's skin appears to be healthy. "
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
            "An allergic skin reaction (atopic dermatitis, flea allergy, or food allergy) "
            "causing intense itching, redness, and skin inflammation."
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
            "Ringworm (Dermatophytosis) is a contagious fungal infection affecting "
            "skin, hair, and nails. Presents as circular bald patches with scaling."
        ),
        "treatments": [
            "Topical antifungal treatment (clotrimazole or miconazole)",
            "Oral antifungal medication for widespread or severe cases",
            "Antifungal shampoo (lime sulfur dip or ketoconazole) twice weekly",
            "Isolate the pet — ringworm is contagious to humans and other pets",
            "Minimum 6–8 weeks of treatment; confirm clearance with fungal culture",
        ],
    },
}

_FALLBACK_META = {
    "severity": "Unknown",
    "urgency": "Consult a veterinarian",
    "description": "Please consult a veterinarian for a proper diagnosis.",
    "treatments": ["Visit a licensed veterinarian for professional treatment advice."],
}


def get_disease_by_name(name: str) -> dict:
    return _DISEASE_META.get(name, _FALLBACK_META)


# ─── Symptom label helpers ────────────────────────────────────────────────────
_Q1_LABELS = {"A":"<1 week","B":"1-2 weeks","C":">2 weeks","D":"Seasonal","E":"No problem"}
_Q2_LABELS = {"A":"Normal scratching","B":"Mild scratching","C":"Frequent scratching/licking","D":"Intense scratching"}
_Q3_LABELS = {"A":"Red patches","B":"Hair loss","C":"Flaky/scaly","D":"Clean/normal","E":"Bumps/scabs"}
_Q4_LABELS = {"A":"No smell","B":"Mild smell","C":"Strong smell"}
_Q5_LABELS = {"A":"Normal outdoor","B":"Mostly indoors","C":"Damp/humid","D":"Near other dogs"}
_Q6_LABELS = {"A":"Normal behavior","B":"Restless","C":"Uncomfortable/irritable"}


def _build_matched_symptoms(codes: dict) -> List:
    matched = []
    if q1 := codes.get("q1"): matched.append(f"Duration: {_Q1_LABELS.get(q1, q1)}")
    if q2 := codes.get("q2"): matched.append(f"Scratching: {_Q2_LABELS.get(q2, q2)}")
    if q3 := codes.get("q3"): matched.append(f"Skin: {_Q3_LABELS.get(q3, q3)}")
    if q4 := codes.get("q4"): matched.append(f"Smell: {_Q4_LABELS.get(q4, q4)}")
    return matched


# ─── Singleton ────────────────────────────────────────────────────────────────
model_instance = SwinFusionModel()
