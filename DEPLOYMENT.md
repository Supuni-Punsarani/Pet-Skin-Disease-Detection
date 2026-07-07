# PetDerm AI — Deployment Guide 🚀

This guide explains how to make the PetDerm AI app accessible to **all users** (not just your WiFi), completely **free of charge**, without the Play Store.

---

## Overview

| What | Where | Cost |
|------|-------|------|
| **Backend (AI Server)** | Render.com | ✅ Free |
| **Model Weights** | Hugging Face Hub | ✅ Free |
| **App Distribution** | GitHub Releases / Google Drive | ✅ Free |

---

## Step 1 — Upload Model Weights to Hugging Face Hub

Your model files (`pawscan_swin_final.pth` + `cat_swin_fusion_model.pth`) are ~226 MB total — too large for GitHub (100 MB limit). Store them on Hugging Face Hub for free.

### 1.1 Create a Hugging Face Account
1. Go to [https://huggingface.co/join](https://huggingface.co/join) and sign up (free)
2. Note your username (e.g., `supuni-punsarani`)

### 1.2 Install Hugging Face CLI
```bash
pip install huggingface_hub
```

### 1.3 Login
```bash
huggingface-cli login
```
It will ask for a token → create one at [https://huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) (select "Write" access)

### 1.4 Create a New Model Repository
```bash
huggingface-cli repo create petderm-ai-weights --type model
```

### 1.5 Upload the Model Files
Navigate to your backend/model directory, then:
```bash
cd "d:\research\Mobile App\backend\model"
huggingface-cli upload YOUR_HF_USERNAME/petderm-ai-weights pawscan_swin_final.pth
huggingface-cli upload YOUR_HF_USERNAME/petderm-ai-weights cat_swin_fusion_model.pth
```
> Replace `YOUR_HF_USERNAME` with your actual Hugging Face username.

### 1.6 Update the Download Script
Open `backend/model/download_weights.py` and replace:
```python
HF_REPO_ID = "YOUR_HF_USERNAME/petderm-ai-weights"
```
with your actual username, e.g.:
```python
HF_REPO_ID = "supuni-punsarani/petderm-ai-weights"
```

---

## Step 2 — Push Backend Code to GitHub

### 2.1 Create a GitHub Repository
1. Go to [https://github.com/new](https://github.com/new)
2. Name it `petderm-ai-backend` (or any name you like)
3. Set it to **Public** (Render needs to access it for free tier)

### 2.2 Push the Backend Folder
```bash
cd "d:\research\Mobile App\backend"
git init
git add .
git commit -m "Initial commit: PetDerm AI backend"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/petderm-ai-backend.git
git push -u origin main
```
> The `.gitignore` will automatically exclude the `.pth` files (they're on Hugging Face).

---

## Step 3 — Deploy Backend to Render.com (Free)

### 3.1 Sign Up
1. Go to [https://render.com](https://render.com) and sign up with your GitHub account (free)

### 3.2 Create a New Web Service
1. Click **"New"** → **"Web Service"**
2. Connect your GitHub repo (`petderm-ai-backend`)
3. Configure:

| Setting | Value |
|---------|-------|
| **Name** | `petderm-ai` |
| **Environment** | `Docker` |
| **Instance Type** | `Free` |
| **Region** | Choose the closest to your users |

4. Click **"Create Web Service"**

### 3.3 Wait for Build
- First build takes **10–15 minutes** (downloading PyTorch + model weights)
- Once done, Render gives you a URL like: `https://petderm-ai.onrender.com`

### 3.4 Test the Server
Open this URL in your browser:
```
https://petderm-ai.onrender.com/health
```
You should see:
```json
{
    "status": "ok",
    "cat_model_loaded": true,
    "dog_model_loaded": true
}
```

> ⚠️ **Important**: Render free tier sleeps after 15 minutes of inactivity.
> The first request after sleep takes ~30–60 seconds to wake up.
> This is normal for free hosting.

---

## Step 4 — Update the Flutter App

### 4.1 Set the Cloud URL
Open `pet_skin_app/lib/services/api_service.dart` and update the URL:
```dart
const String _kBackendBaseUrl = 'https://petderm-ai.onrender.com';
```
> ✅ This has already been updated for you. Just replace `petderm-ai` with your actual Render app name.

### 4.2 Build the Release APK
```bash
cd "d:\research\Mobile App\pet_skin_app"
flutter build apk --release
```
The APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## Step 5 — Distribute the App (Free — No Play Store Needed!)

### Option A: Google Drive (Easiest)
1. Upload `app-release.apk` to Google Drive
2. Set sharing to **"Anyone with the link"**
3. Share the link with users

### Option B: GitHub Releases (Most Professional)
1. Go to your GitHub repo → **"Releases"** → **"Create a new release"**
2. Tag it as `v1.0.0`
3. Upload the `app-release.apk` as an asset
4. Publish the release
5. Share the download link

### Option C: Firebase App Distribution (Best for Beta Testing)
1. Set up Firebase App Distribution in your project
2. Upload APK via the Firebase console
3. Invite testers by email — they get an install link

### How Users Install the APK
1. Download the `.apk` file on their Android phone
2. Open it → Android will ask to **"Install from unknown sources"**
3. Go to **Settings → Apps → Special Access → Install Unknown Apps** → Allow
4. Tap the APK to install

---

## Quick Reference: Full Deployment Checklist

```
✅ Step 1: Upload .pth weights to Hugging Face Hub
✅ Step 2: Push backend code to GitHub
✅ Step 3: Deploy to Render.com → get public URL
✅ Step 4: Update _kBackendBaseUrl in api_service.dart
✅ Step 5: Build release APK: flutter build apk --release
✅ Step 6: Share APK via Google Drive / GitHub Releases
```

---

## Troubleshooting

### "Cannot connect to server"
- Make sure your Render service is running (check the dashboard)
- First request after inactivity takes 30–60s (free tier cold start)
- Check the URL is correct: `https://your-app-name.onrender.com`

### "Model not loaded"
- Check Render build logs for errors
- Verify the Hugging Face repo ID is correct in `download_weights.py`
- Make sure the .pth files were uploaded to Hugging Face successfully

### Build fails on Render
- Check that `requirements-cloud.txt` has the correct versions
- The free tier has 512 MB RAM — PyTorch + both models may be tight
- Consider using Render's **Starter plan** ($7/month) for 1 GB RAM if needed

### APK won't install
- User needs to enable "Install from unknown sources" in Android settings
- Make sure you built with `flutter build apk --release`
