# 🛡️ Raksha - Mobile Medical Triage App

Raksha is a high-fidelity, pixel-perfect mobile medical triage application built with Flutter, designed to assist healthcare workers in rural India. It captures patient registration info, processes vital readings (Stethoscope, ECG, Blood Pressure, SpO2 & Temp, Urine analysis), performs clinical risk scoring, and syncs data to the cloud.

---

## 👨‍💻 Key Contributions by Arnav Semwal

Arnav Semwal has driven the core full-stack, DevOps, and ML orchestration architecture of this project:

### 1. ⚙️ End-to-End Local Simulation Blueprint
- Conceived, designed, and implemented the local multi-tiered monorepo environment: **Flutter App ➔ Backend API ➔ AI Engine (raksha-sim)**.
- Mapped out separate uvicorn ports (8000 for Backend, 8001 for ML Engine) to run the full pipeline locally with SQLite persistence.

### 2. 🧠 AI & ML Engine Orchestration
- Created backend endpoints allowing Python ML inference scripts to accept vital metrics, evaluate MEWS (Modified Early Warning Score) clinical thresholds, and return real-time prediction and risk alerts.
- Configured backend routing to transparently forward `/vitals` payloads to the ML engine and append risk outputs to patient records.

### 3. 🌐 Permissive CORS Integration
- Integrated custom `CORSMiddleware` in FastAPI servers to allow cross-origin requests from Flutter Web, Mobile, and Android Emulators during dry run testing, bypassing browser sandbox restrictions.

### 4. 📝 Patient Registration State Binding
- Replaced non-functional dummy visual controls in the Registration UI with a functional `DropdownButtonFormField` for Gender selection ('Male', 'Female', 'Other').
- Bound values directly to `TriageProvider` patient state to flow seamlessly into API payloads.

### 5. 💾 Safely-Isolated Offline Caching (Sync Fail-Safe)
- Integrated `shared_preferences` to persist un-synced patient data locally in case of network failures or server outages.
- Upgraded HTTP catches to write directly to offline cache without modifying successful inline execution paths, guaranteeing zero patient data loss.

---

## 🚀 Setup & Execution Runbook

To run the local simulation stack, open three terminal windows:

### 1. Launch the AI / ML Engine (Port 8001)
```powershell
cd raksha-sim
python -m uvicorn ml_engine:app --host 127.0.0.1 --port 8001 --reload
```

### 2. Launch the Backend API Gateway (Port 8000)
```powershell
cd raksha-sim
python -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

### 3. Launch the Flutter App
```powershell
cd raksha_app
flutter run -d chrome
```

---

## 📡 Backend API Specs

- **`POST /vitals`**: Persists metrics and queries local ML Engine for risk assessment.
- **`POST /triage`**: Persists overall patient triage status.
- **`GET /patients`**: Returns the list of all registered patients.
