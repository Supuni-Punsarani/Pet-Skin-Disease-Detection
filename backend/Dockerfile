# ──────────────────────────────────────────────────────────────────────────────
# PetDerm AI — Production Dockerfile
# ──────────────────────────────────────────────────────────────────────────────
# Uses CPU-only PyTorch to keep the image small (~1.5 GB instead of ~6 GB).
# Model weights are downloaded at build time from Hugging Face Hub.

FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies needed by Pillow and torch
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc libjpeg-dev zlib1g-dev curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies (CPU-only torch to save ~4 GB)
COPY requirements-cloud.txt .
RUN pip install --no-cache-dir -r requirements-cloud.txt

# Copy application code
COPY main.py .
COPY model/ model/

# Download model weights from Hugging Face Hub at build time
# ─── IMPORTANT ──────────────────────────────────────────────────────────────
# You MUST upload your .pth files to Hugging Face first. See DEPLOYMENT.md.
# Replace <YOUR_HF_USERNAME> with your actual Hugging Face username.
# ────────────────────────────────────────────────────────────────────────────
RUN python -c "from model.download_weights import download_all; download_all()"

# Expose the port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start the server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
