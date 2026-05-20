<div align="center">

# 🐾 PetDerm AI

### *AI-Powered Pet Skin Disease Detection*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.3-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)](https://pytorch.org)

> **Snap. Analyse. Heal.** — Helping pet owners detect skin diseases in dogs and cats using the power of deep learning.

</div>

---

## ✨ What is PetDerm AI?

PetDerm AI is a cross-platform **Flutter mobile application** backed by a **FastAPI + PyTorch deep learning server** that diagnoses skin diseases in pets. Simply upload a photo of your pet's skin, answer a few quick symptom questions, and receive an instant AI-powered diagnosis with severity assessment, treatment recommendations, and nearby vet locations — all in seconds.

---

## 🚀 Key Features

| Feature | Description |
|---|---|
| 📸 **Image Analysis** | Upload or capture a photo of your pet's skin condition |
| 🧠 **SwinFusion AI Model** | Custom Swin Transformer fusion model trained on pet skin disease datasets |
| 📋 **Symptom Questionnaire** | 6-step guided symptom checker for more accurate diagnosis |
| 📊 **Confidence Scoring** | Diagnosis comes with a confidence percentage and severity level |
| 💊 **Treatment Advice** | Tailored treatment recommendations based on the detected disease |
| 📍 **Vet Locator** | Find nearby veterinary clinics using GPS geolocation |
| 🔐 **Firebase Auth** | Secure login with Email/Password or Google Sign-In |
| 📂 **History Tracking** | All past diagnoses saved to your personal history via Firestore |
| 🐕🐈 **Multi-Pet Support** | Supports both **Dogs** and **Cats** |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│           Flutter Mobile App            │
│  ┌──────────┐  ┌──────────────────────┐ │
│  │  Firebase │  │   FastAPI Backend    │ │
│  │  Auth     │  │  ┌────────────────┐ │ │
│  │  Firestore│  │  │ SwinFusion AI  │ │ │
│  │  Storage  │  │  │    Model       │ │ │
│  └──────────┘  │  └────────────────┘ │ │
│                └──────────────────────┘ │
└─────────────────────────────────────────┘
```

```
Mobile App (Flutter)
    │
    ├── 📱 Screens       — Splash, Auth, Home, Upload, Diagnosis, Results, History, Settings
    ├── 🔄 Providers     — AuthProvider, DiagnosisProvider (state management)
    ├── 🌐 Services      — ApiService, FirebaseService, FirestoreService, StorageService
    ├── 🎨 Theme         — AppTheme (custom dark/light theme)
    └── 📦 Models        — DiseaseResult, SymptomAnswer

Python Backend (FastAPI)
    │
    ├── 🚀 main.py       — FastAPI app, /health & /predict endpoints
    └── 🧠 model/
            ├── swin_fusion.py     — SwinFusion model architecture & inference
            └── disease_labels.py  — Disease label mappings
```

---

## 🖥️ Tech Stack

### 📱 Mobile App
- **Flutter 3.x** — Cross-platform UI framework
- **Provider** — Lightweight state management
- **Firebase Auth** — User authentication (Email + Google)
- **Cloud Firestore** — Diagnosis history storage
- **Firebase Storage** — Pet image uploads
- **Google Fonts** — Beautiful typography
- **flutter_animate** — Smooth animations
- **Geolocator** — GPS-based vet finder

### ⚙️ Backend
- **FastAPI** — High-performance async REST API
- **PyTorch 2.3** — Deep learning inference engine
- **SwinFusion** — Custom Swin Transformer model for fusion of image + symptom data
- **timm** — PyTorch image model library
- **Pillow** — Image preprocessing
- **Uvicorn** — ASGI server

---

## 📂 Project Structure

```
Pet-Skin-Disease-Detection/
│
├── 📁 backend/                  # Python FastAPI backend
│   ├── main.py                  # API entrypoints (/health, /predict)
│   ├── requirements.txt         # Python dependencies
│   └── model/
│       ├── swin_fusion.py       # SwinFusion model definition & inference
│       └── disease_labels.py    # Disease class mappings
│
├── 📁 pet_skin_app/             # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── screens/             # All UI screens
│   │   ├── providers/           # State management
│   │   ├── services/            # API & Firebase services
│   │   ├── models/              # Data models
│   │   ├── data/                # Disease & vet data
│   │   ├── widgets/             # Reusable UI components
│   │   └── theme/               # App theme
│   ├── assets/images/           # App assets
│   └── pubspec.yaml             # Flutter dependencies
│
└── README.md
```

---

## ⚡ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.0.0
- [Python](https://python.org) ≥ 3.10
- [Firebase Project](https://console.firebase.google.com) with Auth, Firestore & Storage enabled

---

### 🐍 Backend Setup

```bash
# 1. Navigate to backend directory
cd backend

# 2. Create & activate virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS/Linux

# 3. Install dependencies
pip install -r requirements.txt

# 4. Start the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be live at `http://localhost:8000`
Swagger docs available at `http://localhost:8000/docs` 📖

---

### 📱 Flutter App Setup

```bash
# 1. Navigate to the Flutter app
cd pet_skin_app

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
#    - Add google-services.json → android/app/
#    - Add GoogleService-Info.plist → ios/Runner/

# 4. Update API base URL in lib/services/api_service.dart
#    (point to your backend server IP)

# 5. Run the app
flutter run
```

---

## 🌐 API Reference

### `GET /health`
Check if the backend server and model are ready.
```json
{ "status": "ok", "model_loaded": true }
```

### `POST /predict`
Submit a pet image + symptom answers for diagnosis.

**Request** (multipart/form-data):
| Field | Type | Description |
|---|---|---|
| `image` | File | JPEG or PNG pet skin photo |
| `symptoms` | String | JSON: `{"q1":"A","q2":"B","q3":"C","q4":"A","q5":"A","q6":"B"}` |

**Response:**
```json
{
  "disease":          "Mange (Sarcoptic)",
  "confidence":       0.87,
  "severity":         "Severe",
  "urgency":          "See vet within 48 hours",
  "description":      "Sarcoptic mange is caused by...",
  "treatments":       ["Medicated shampoo", "Antiparasitic medication"],
  "matched_symptoms": ["Duration: 1–2 weeks", "Scratching: Intense"]
}
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- 🐛 Report bugs via [Issues](https://github.com/Supuni-Punsarani/Pet-Skin-Disease-Detection/issues)
- 💡 Suggest features
- 🔧 Submit pull requests

---

## 👩‍💻 Author

**Supuni Punsarani**
[![GitHub](https://img.shields.io/badge/GitHub-Supuni--Punsarani-181717?style=flat&logo=github)](https://github.com/Supuni-Punsarani)

---

<div align="center">

Made with ❤️ for pets everywhere 🐾

*If this project helped you, please consider giving it a ⭐*

</div>
