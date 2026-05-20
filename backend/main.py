"""
PetDerm AI — FastAPI Backend
=============================
Serves the SwinFusion model for pet skin disease diagnosis.

Run with:
    uvicorn main:app --reload --host 0.0.0.0 --port 8000

The --host 0.0.0.0 flag makes the server accessible from your phone/emulator on the same network.
"""

import json
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from model.swin_fusion import model_instance

# ─── Logging ──────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)


# ─── Startup / Shutdown ───────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load the model once at startup, release resources at shutdown."""
    logger.info("🚀 Starting PetDerm AI backend…")
    model_instance.load_model()
    yield
    logger.info("🛑 Shutting down PetDerm AI backend.")


# ─── App ──────────────────────────────────────────────────────────────────────
app = FastAPI(
    title="PetDerm AI API",
    description="AI-powered pet skin disease diagnosis using SwinFusion.",
    version="1.0.0",
    lifespan=lifespan,
)

# Allow Flutter app to reach this server (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten this in production
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


# ─── Endpoints ────────────────────────────────────────────────────────────────

@app.get("/health")
async def health_check():
    """
    Simple health check. The Flutter app calls this first to confirm the
    backend is reachable before sending the full image + symptoms.
    """
    return {
        "status": "ok",
        "model_loaded": model_instance._loaded,
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
):
    """
    Diagnose pet skin condition from an image + 6 symptom answers.

    **Request** (multipart/form-data):
    - `image`    — JPEG or PNG file
    - `symptoms` — JSON string: `{"q1":"A","q2":"B","q3":"C","q4":"A","q5":"A","q6":"A"}`

    **Response** (JSON):
    ```json
    {
        "disease":          "Mange (Sarcoptic)",
        "confidence":       0.87,
        "severity":         "Severe",
        "urgency":          "See vet within 48 hours",
        "description":      "...",
        "treatments":       ["...", "..."],
        "matched_symptoms": ["Duration: 1–2 weeks", "Scratching: Intense"]
    }
    ```
    """
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
            detail="'symptoms' must be a valid JSON string, e.g. {\"q1\":\"A\",\"q2\":\"B\",...}",
        )

    # Read image bytes
    image_bytes = await image.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Image file is empty.")

    # Run prediction
    try:
        result = model_instance.predict(image_bytes, symptom_codes)
    except Exception as exc:
        logger.exception("Prediction failed")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(exc)}")

    logger.info(
        f"Predicted: {result['disease']} "
        f"(confidence={result['confidence']:.2%}, severity={result['severity']})"
    )
    return result
