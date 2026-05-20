import sys
import os
import torch

sys.path.insert(0, os.path.dirname(__file__))
from model.swin_fusion import model_instance

print("Loading model...")
model_instance.load_model()

# Create dummy white image (since the user says it predicts wrong even with images)
from PIL import Image
import io

img = Image.new("RGB", (224, 224), color=(200, 200, 200))
buf = io.BytesIO()
img.save(buf, format="JPEG")
image_bytes = buf.getvalue()

test_cases = {
    "Bacterial": {"q1":"A", "q2":"C", "q3":"A", "q4":"B", "q5":"A", "q6":"A"},
    "Demodicosis": {"q1":"C", "q2":"B", "q3":"B", "q4":"A", "q5":"B", "q6":"A"},
    "Fungal": {"q1":"B", "q2":"C", "q3":"C", "q4":"C", "q5":"C", "q6":"B"},
    "Healthy": {"q1":"E", "q2":"A", "q3":"D", "q4":"A", "q5":"A", "q6":"A"},
    "Hypersensitivity": {"q1":"D", "q2":"D", "q3":"E", "q4":"A", "q5":"E", "q6":"C"}, # Wait Q5 only has 4 options in code size!
    "Ringworm": {"q1":"B", "q2":"B", "q3":"B", "q4":"A", "q5":"D", "q6":"A"},
}

for name, symptoms in test_cases.items():
    print(f"\n--- Testing expected {name} ---")
    print(f"Symptoms: {symptoms}")
    res = model_instance.predict(image_bytes, symptoms)
    print(f"PREDICTED: {res['disease']} ({res['confidence']*100:.1f}%)")
