"""
test_model_load.py — Verify the model loads and can run a dummy prediction.
Run from backend/:
    venv\Scripts\activate
    python test_model_load.py
"""
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(__file__))

from model.swin_fusion import model_instance

print("Loading model...")
model_instance.load_model()

if not model_instance._loaded:
    print("ERROR: Model did not load!")
    sys.exit(1)

print(f"Model loaded: {model_instance._loaded}")
print(f"Disease classes: {model_instance._disease_classes}")

# Run a dummy prediction with a blank white image
from PIL import Image
import io

# Create a dummy 224x224 white image
img = Image.new("RGB", (224, 224), color=(200, 200, 200))
buf = io.BytesIO()
img.save(buf, format="JPEG")
image_bytes = buf.getvalue()

dummy_symptoms = {"q1": "B", "q2": "C", "q3": "A", "q4": "B", "q5": "A", "q6": "B"}

print("\nRunning dummy prediction...")
result = model_instance.predict(image_bytes, dummy_symptoms)

print("\n=== Prediction Result ===")
for k, v in result.items():
    if isinstance(v, list):
        print(f"  {k}:")
        for item in v:
            print(f"    - {item}")
    else:
        print(f"  {k}: {v}")

print("\nSUCCESS - Model is working correctly!")
