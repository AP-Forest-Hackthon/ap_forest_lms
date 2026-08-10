# 🌿 Forest Academy E-Center
**Smart Digital Learning & Training Management Platform**

*A.P. State Forest Academy, R.F.R. Complex, Lalacheruvu, Rajamahendravaram – 533106, Andhra Pradesh*

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code
- Firebase project (create at [console.firebase.google.com](https://console.firebase.google.com))
- Python 3.9+ (for AI backend)

---

## 📱 Flutter App Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure Firebase

**Option A — FlutterFire CLI (recommended):**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart` automatically.

**Option B — Manual:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Replace `lib/firebase_options.dart` placeholder values with your Firebase config

### 3. Configure environment (`.env`)
```
cp .env.example .env
```
Edit `.env`:
```env
BACKEND_BASE_URL=http://10.0.2.2:8000   # Android emulator → localhost
# or
BACKEND_BASE_URL=http://192.168.x.x:8000 # Physical device → your PC IP
```

### 4. Add academy logo (optional)
Place `academy_logo.png` in `assets/images/`.
A placeholder forest icon is shown if the file is missing.

### 5. Run the app
```bash
flutter run
```

---

## Python AI Backend Setup

The backend handles **PDF text extraction → Groq LLM quiz generation**.

```bash
cd backend
pip install -r requirements.txt
# or use the Windows batch file:
start_server.bat
```

The server starts at **http://localhost:8000**.

**Endpoints:**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Check if server is running |
| `/generate-quiz` | POST | PDF URL → AI MCQ generation |
| `/ai-assistant` | POST | Trainee Q&A assistant |
| `/docs` | GET | Interactive API documentation |

### Backend `.env`:
```env
GROQ_API_KEY=YOUR_GROQ_API_KEY_HERE
GROQ_MODEL=llama-3.3-70b-versatile
PORT=8000
```

---

## Firebase Configuration

### Services to enable:
- **Authentication** → Enable Google Sign-In + Email/Password
- **Firestore Database** → Start in Production mode
- **Storage** → Enable for PDF and image uploads

### Deploy Firestore rules:
```bash
firebase deploy --only firestore:rules
```

### First-time admin setup:
1. Sign in with Google (creates trainee account)
2. Go to Firebase Console → Firestore → `users` collection
3. Change `role` from `trainee` to `admin` for your account
4. Sign out and sign in again
5. You now have admin access to manage faculty and settings

---

## Architecture

```
Forest Academy E-Center
├── lib/
│   ├── main.dart                    # Entry point
│   ├── firebase_options.dart        # Firebase config
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── theme/                   # Colors + Theme
│   │   ├── routes/                  # GoRouter + Route names
│   │   └── services/               # Auth, Storage, PDF-Quiz, Location
│   ├── models/                      # Firestore data models
│   ├── repositories/               # Firestore CRUD layer
│   ├── providers/                  # State management (Provider)
│   └── features/
│       ├── auth/                    # Splash + Login
│       ├── trainee/                 # Trainee portal
│       ├── faculty/                 # Faculty portal + AI Quiz Generator
│       └── admin/                  # Admin management
└── backend/                        # Python FastAPI AI backend
    ├── main.py
    ├── services/
    │   ├── pdf_extractor.py        # PyMuPDF + pdfplumber
    │   ├── groq_service.py         # Groq LLM integration
    │   └── quiz_validator.py       # AI response validation
    └── requirements.txt
```

---

## User Roles

| Role | Login Method | Capabilities |
|------|-------------|--------------|
| **Trainee** | Google Sign-In | View courses, take quizzes, access library, AI assistant |
| **Faculty** | Email + Password | Upload PDFs, generate AI quizzes, manage courses |
| **Admin** | Email + Password | Manage users, settings, announcements, analytics |

---

## AI Quiz Generation Flow

1. Faculty uploads PDF → Firebase Storage
2. Flutter calls Python backend with PDF URL
3. Backend downloads PDF → extracts text (PyMuPDF)
4. Text sent to Groq (llama-3.3-70b-versatile)
5. AI generates MCQs with options, correct answer, explanation
6. Draft quiz saved to Firestore with `status: ai_review`
7. Faculty reviews → edits questions, adds/removes
8. Faculty publishes → `status: published`
9. Trainees see and attempt the quiz

---

## Firestore Data Model

```
users/{uid}
courses/{courseId}
  └── modules/{moduleId}
quizzes/{quizId}
  └── questions/{questionId}
quizAttempts/{attemptId}
resources/{resourceId}
categories/{categoryId}
announcements/{announcementId}
timetable/{entryId}
progress/{traineeId_courseId}
bookmarks/{bookmarkId}
academySettings/location
academySettings/info
```
