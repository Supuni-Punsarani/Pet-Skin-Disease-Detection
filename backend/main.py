"""
PetDerm AI — FastAPI Backend
=============================
Serves two SwinFusion models for cat and dog skin disease diagnosis.

Run with:
    uvicorn main:app --reload --host 0.0.0.0 --port 8000

The --host 0.0.0.0 flag makes the server accessible from your phone/emulator on the same network.
"""

import json
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from model.swin_fusion import cat_model_instance, dog_model_instance, predict_for_pet

# ─── Logging ──────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)


# ─── Startup / Shutdown ───────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load both models at startup, release resources at shutdown."""
    logger.info("🚀 Starting PetDerm AI backend…")
    cat_model_instance.load_model()
    dog_model_instance.load_model()
    yield
    logger.info("🛑 Shutting down PetDerm AI backend.")


# ─── App ──────────────────────────────────────────────────────────────────────
app = FastAPI(
    title="PetDerm AI API",
    description="AI-powered cat and dog skin disease diagnosis using SwinFusion.",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


# ─── Endpoints ────────────────────────────────────────────────────────────────

@app.get("/health")
async def health_check():
    """Simple health check — confirms both models are loaded."""
    return {
        "status": "ok",
        "cat_model_loaded": cat_model_instance._loaded,
        "dog_model_loaded": dog_model_instance._loaded,
    }


@app.post("/predict")
async def predict(
    image: UploadFile = File(..., description="Pet skin image (JPEG/PNG)"),
    symptoms: str = Form(
        ...,
        description=(
            'JSON string of 6 answer codes, e.g.: '
            '{"q1":"B","q2":"C","q3":"A","q4":"A","q5":"A","q6":"B"}'
        ),
    ),
    pet_type: str = Form(
        default="cat",
        description="Pet type: 'cat' or 'dog'",
    ),
):
    """
    Diagnose pet skin condition from an image + 6 symptom answers.

    **Request** (multipart/form-data):
    - `image`    — JPEG or PNG file
    - `symptoms` — JSON string: `{"q1":"A","q2":"B","q3":"C","q4":"A","q5":"A","q6":"A"}`
    - `pet_type` — `"cat"` or `"dog"` (default: `"cat"`)

    **Response** (JSON):
    ```json
    {
        "disease":          "Ringworm",
        "confidence":       0.87,
        "severity":         "Moderate",
        "urgency":          "See vet within 1 week",
        "description":      "...",
        "treatments":       ["...", "..."],
        "matched_symptoms": ["Duration: 1 to 2 weeks", "Grooming: Mild scratching"]
    }
    ```
    """
    # Validate pet type
    pet_type_lower = pet_type.strip().lower()
    if pet_type_lower not in ("cat", "dog"):
        raise HTTPException(
            status_code=400,
            detail=f"Invalid pet_type '{pet_type}'. Must be 'cat' or 'dog'.",
        )

    # Validate image MIME type
    if image.content_type not in ("image/jpeg", "image/png", "image/jpg", "image/webp"):
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported image type: {image.content_type}. Use JPEG or PNG.",
        )

    # Parse symptoms JSON
    try:
        symptom_codes: dict = json.loads(symptoms)
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=400,
            detail="'symptoms' must be a valid JSON string.",
        )

    # Read image bytes
    image_bytes = await image.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Image file is empty.")

    # Run prediction using the correct model
    try:
        result = predict_for_pet(pet_type_lower, image_bytes, symptom_codes)
    except Exception as exc:
        logger.exception("Prediction failed")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(exc)}")

    logger.info(
        f"[{pet_type_lower}] Predicted: {result['disease']} "
        f"(confidence={result['confidence']:.2%}, severity={result['severity']})"
    )
    return result
