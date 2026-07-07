"""
Model Weight Downloader — Hugging Face Hub
============================================
Downloads cat and dog SwinFusion model weights from Hugging Face.

Usage:
    python -m model.download_weights          # Downloads both models
    python -c "from model.download_weights import download_all; download_all()"

── SETUP ──────────────────────────────────────────────────────────────────────
1. Create a free account at https://huggingface.co
2. Create a new model repo (e.g., "your-username/petderm-ai-weights")
3. Upload your .pth files:
       pip install huggingface_hub
       huggingface-cli login
       huggingface-cli upload your-username/petderm-ai-weights pawscan_swin_final.pth
       huggingface-cli upload your-username/petderm-ai-weights cat_swin_fusion_model.pth
4. Update HF_REPO_ID below with your repo name
────────────────────────────────────────────────────────────────────────────────
"""

import os
import logging

logger = logging.getLogger(__name__)

# ─── CHANGE THIS to your Hugging Face repo ───────────────────────────────────
HF_REPO_ID = "supunipunsarani/petderm-ai-weights"
# ─────────────────────────────────────────────────────────────────────────────

_DIR = os.path.dirname(__file__)

WEIGHT_FILES = {
    "pawscan_swin_final.pth": os.path.join(_DIR, "pawscan_swin_final.pth"),
    "cat_swin_fusion_model.pth": os.path.join(_DIR, "cat_swin_fusion_model.pth"),
}


def download_all():
    """Download all model weight files from Hugging Face Hub."""
    from huggingface_hub import hf_hub_download

    for filename, local_path in WEIGHT_FILES.items():
        if os.path.exists(local_path):
            logger.info(f"✅ {filename} already exists, skipping download.")
            continue

        logger.info(f"⬇  Downloading {filename} from {HF_REPO_ID} ...")
        downloaded_path = hf_hub_download(
            repo_id=HF_REPO_ID,
            filename=filename,
            local_dir=_DIR,
            local_dir_use_symlinks=False,
        )
        logger.info(f"✅ Downloaded {filename} → {downloaded_path}")

    logger.info("✅ All model weights are ready.")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    download_all()
"""
"""
