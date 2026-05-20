import sys
import os
import torch
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
from model.swin_fusion import model_instance
from model.disease_labels import DISEASE_CLASSES

print("Loading model...")
model_instance.load_model()

# Create dummy white image (since the user says it predicts wrong even with images)
from PIL import Image
import io

img = Image.new("RGB", (224, 224), color=(200, 200, 200))
buf = io.BytesIO()
img.save(buf, format="JPEG")
image_bytes = buf.getvalue()

# Ground truth from user's mapping:
# 1. Bacterial: Less than 1 week (A), Frequent (C), Red patches (A), Mild odor (B), Outdoor (A), Normal (A)
# 2. Demodicosis: More than 2 weeks (C), Mild (B), Hair loss (B), No smell (A), Indoor (B), Normal (A)
# 3. Fungal: 1-2 weeks (B), Frequent (C), Flaky/greasy (C), Strong musty (C), Damp areas (C), Restless (B)
# 4. Healthy: No problem (E), Normal (A), Clean (D), No smell (A), Normal (A), Normal (A)
# 5. Hypersensitivity: Seasonal (D), Intense (D), Red+bumps (E), No smell (A), Allergens (E), Uncomfortable (C)
# 6. Ringworm: 1-2 weeks (B), Mild (B), Hair loss (B), No smell (A), Other animals (D), Normal (A)

test_cases = {
    "Bacterial Dermatosis": {"q1":"A", "q2":"C", "q3":"A", "q4":"B", "q5":"A", "q6":"A"},
    "Demodicosis": {"q1":"C", "q2":"B", "q3":"B", "q4":"A", "q5":"B", "q6":"A"},
    "Fungal Infections": {"q1":"B", "q2":"C", "q3":"C", "q4":"C", "q5":"C", "q6":"B"},
    "Healthy": {"q1":"E", "q2":"A", "q3":"D", "q4":"A", "q5":"A", "q6":"A"},
    "Hypersensitivity Dermatitis": {"q1":"D", "q2":"D", "q3":"E", "q4":"A", "q5":"E", "q6":"C"}, 
    "Ringworm": {"q1":"B", "q2":"B", "q3":"B", "q4":"A", "q5":"D", "q6":"A"},
}

print("\n--- Discovering correct argmax mapping ---")
correct_mapping = {}

for ground_truth_name, symptoms in test_cases.items():
    image_tensor = model_instance.preprocess_image(image_bytes)
    symptom_tensor = model_instance.extract_symptoms(symptoms)
    
    with torch.no_grad():
        logits = model_instance.net(image_tensor, symptom_tensor)
        probs = torch.softmax(logits, dim=1)[0]
        class_index = int(probs.argmax().item())
        confidence = float(probs[class_index].item())
        
    correct_mapping[class_index] = ground_truth_name
    print(f"Ground Truth: {ground_truth_name.ljust(30)} -> Argmax Index: {class_index} (Confidence: {confidence*100:.1f}%)")

print("\n--- Generated DISEASE_CLASSES array ---")
ordered_classes = [correct_mapping.get(i, f"Unknown_{i}") for i in range(6)]
print(ordered_classes)
