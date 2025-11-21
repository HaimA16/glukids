# GluKids

**A Flutter app for managing children with Type 1 diabetes – glucose logs, treatments, insulin calculator and school assistant tools.**

---

## 📋 Overview

GluKids is a comprehensive mobile application designed to help school assistants, teachers, and caregivers manage the daily care of children with Type 1 diabetes in educational settings. The app provides a structured, user-friendly platform for logging glucose readings, tracking insulin treatments, calculating insulin doses, and monitoring trends over time.

**Problem Statement:**  
Children with Type 1 diabetes require careful monitoring throughout the school day. School assistants and teachers need a simple, reliable tool to:
- Log blood glucose readings with context (before/after meals)
- Record insulin doses and treatments
- Calculate appropriate insulin doses based on individual child parameters
- Track patterns and identify hypo/hyper episodes
- Maintain a clear daily log for parents and medical professionals

**Note:** The application UI is currently in **Hebrew (RTL)** to serve the target audience, while this documentation is in English for broader accessibility.

---

## ✨ Key Features

### 🔐 Authentication & User Management
- **Firebase Authentication** with email/password
- Secure assistant/caregiver registration and login
- Profile management (full name, school, phone)

### 👶 Children Management
- Add and manage multiple children per assistant
- Store child-specific information (name, grade, parent contact)
- Configure individual glucose target ranges
- Set insulin calculation parameters per child:
  - **Insulin-to-Carb Ratio (ICR)** – units per 10g carbs
  - **Correction Factor** – mg/dL lowered per unit
  - **Target Range** – min/max glucose values

### 📊 Glucose Readings Log
- Record blood glucose readings with timestamps
- Context tagging (before meal, after meal, other)
- Optional notes for each reading
- Automatic hypo/hyper detection based on child's thresholds
- Visual indicators (color-coded cards) for abnormal readings

### 💉 Treatments & Insulin Log
- Record insulin injections and pump boluses
- Track insulin units and timing
- Add treatment notes
- Link treatments to specific children

### 🧮 Insulin Calculator (Bolus)
- **Smart dose calculation** based on:
  - Current blood glucose reading
  - Planned carbohydrate intake
  - Child-specific ICR and correction factor
  - Target glucose range
- **Calculation breakdown:**
  - Carb bolus = (carbs ÷ 10) × ICR
  - Correction bolus = (current BG - target) ÷ correction factor
  - Total dose rounded to nearest 0.5 units
- **Safety features:**
  - Prominent medical disclaimer
  - Decision-support tool only (not medical advice)
  - Save calculated dose directly to treatment log

### 📈 Hypo/Hyper Tracking & Statistics
- **24-hour statistics card** showing:
  - Total readings count
  - Low readings (below threshold)
  - High readings (above threshold)
  - Normal readings (within range)
- **Visual indicators:**
  - Red borders and warnings for hypo readings
  - Orange borders and warnings for hyper readings
  - Green indicators for normal range
- Real-time updates via StreamProvider

### 📅 Daily Log
- Chronological view of readings and treatments for any day
- Merge and sort by timestamp
- Easy date navigation (previous/next day)
- Empty state messages

### 🎨 Modern UI/UX
- **Material 3** design system
- Clean, professional healthcare aesthetics
- Soft color palette (medical blue, success green)
- Rounded corners, subtle shadows, proper spacing
- RTL support for Hebrew interface
- Responsive card-based layouts
- Smooth animations and transitions

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Backend:**
  - Firebase Authentication (email/password)
  - Cloud Firestore (NoSQL database)
  - Firebase Core
- **Platforms:**
  - Android (primary)
  - iOS (structure ready)
- **Architecture:** Clean Architecture with repository pattern
  - Abstract repository interfaces
  - Firebase implementations
  - Separation of concerns (UI ↔ Services ↔ Repositories ↔ Models)

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase initialization
├── app.dart                     # Root MaterialApp, theme, routing, auth state
├── firebase_options.dart        # Generated Firebase platform config
│
├── core/
│   ├── app_router.dart          # Route definitions and navigation
│   └── snackbar_helper.dart     # UI helper functions
│
├── models/
│   ├── assistant.dart           # Assistant/caregiver model
│   ├── child.dart               # Child model (with insulin parameters)
│   ├── glucose_reading.dart     # Glucose reading model
│   └── treatment.dart           # Treatment/insulin model
│
├── repositories/
│   ├── *_repository.dart        # Abstract repository interfaces
│   └── firebase_*_repository.dart  # Firebase implementations
│
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper
│   └── insulin_calculator_service.dart  # Bolus calculation logic
│
├── screens/
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_child_screen.dart
│   ├── child_detail_screen.dart
│   ├── add_reading_screen.dart
│   ├── add_treatment_screen.dart
│   ├── daily_log_screen.dart
│   └── insulin_calculator_screen.dart
│
└── widgets/
    ├── primary_button.dart
    ├── app_text_field.dart
    ├── child_card.dart
    ├── reading_tile.dart
    ├── treatment_tile.dart
    └── glucose_stats_card.dart
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (latest stable version)
- **Dart SDK** (bundled with Flutter)
- **Android Studio** / Android SDK (for Android development)
- **Firebase account** (free tier is sufficient)
- **Firebase CLI** (for configuration)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/HaimA16/glukids.git
   cd glukids
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   
   a. **Create a Firebase project:**
      - Go to [Firebase Console](https://console.firebase.google.com/)
      - Create a new project (e.g., `glukids`)
      - Enable **Email/Password Authentication**
      - Create a **Cloud Firestore** database (start in test mode)
   
   b. **Install FlutterFire CLI:**
      ```bash
      dart pub global activate flutterfire_cli
      ```
   
   c. **Configure Firebase for Flutter:**
      ```bash
      dart pub global run flutterfire_cli:flutterfire configure
      ```
      This will:
      - Connect to your Firebase project
      - Generate `lib/firebase_options.dart`
      - Prompt you to configure Android/iOS apps
   
   d. **Download Firebase config files** (if not auto-downloaded):
      - **Android:** Download `google-services.json` from Firebase Console
        - Place it in `android/app/google-services.json`
      - **iOS:** Download `GoogleService-Info.plist` from Firebase Console
        - Place it in `ios/Runner/GoogleService-Info.plist`
   
   ⚠️ **Important:** These Firebase config files are **not included in git** for security reasons. Each developer must download their own copies from the Firebase Console after setting up the project.

4. **Run the app:**
   ```bash
   flutter run
   ```

### Firebase Configuration Details

- **Authentication:** Enable "Email/Password" sign-in method
- **Firestore Rules:** Configure appropriate security rules (example for development):
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /children/{childId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == resource.data.assistantUid;
      }
      match /glucose_readings/{readingId} {
        allow read, write: if request.auth != null;
      }
      match /treatments/{treatmentId} {
        allow read, write: if request.auth != null;
      }
      match /assistants/{assistantId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == assistantId;
      }
    }
  }
  ```

---

## 🗺 Roadmap / Future Ideas

- 🔄 **Real-time CGM Integration** – Connect to Dexcom/Libre continuous glucose monitors
- 🔔 **Push Notifications** – Alert assistants for hypo/hyper episodes
- 📊 **Advanced Analytics** – Trends, averages, time-in-range metrics per child
- 🌍 **Multi-language Support** – Hebrew/English toggle
- 📤 **Export Reports** – Generate PDF/CSV reports for doctors and parents
- 👥 **Parent Portal** – Separate app/portal for parents to view daily logs
- 🔍 **Search & Filters** – Advanced filtering for readings and treatments
- 📱 **Offline Support** – Full offline capability with sync when online
- 🎯 **Targets & Goals** – Set and track glucose target goals per child
- 🔐 **Biometric Authentication** – Fingerprint/Face ID for quick access

---

## 🤝 Contributing

This is currently a personal/academic project, but contributions are welcome! Feel free to:

- Open issues for bugs or feature requests
- Submit pull requests for improvements
- Suggest enhancements via GitHub Discussions

Please ensure any contributions maintain the project's architecture (repository pattern, clean code principles) and follow the existing code style.

---

## ⚠️ Medical Disclaimer

> **IMPORTANT:** This application is a **decision-support tool only** and does **NOT** replace professional medical advice. All insulin dose calculations, glucose readings, and treatment decisions must be verified and confirmed by a qualified medical professional before administration. The developers and contributors assume no liability for any medical decisions made using this application.

---

## 📝 License

This project is currently **unlicensed** (all rights reserved). Contact the repository owner for licensing inquiries.

---

## 👤 Contact

- **GitHub:** [@HaimA16](https://github.com/HaimA16)
- **Repository:** [GluKids](https://github.com/HaimA16/glukids)

---

## 📸 Screenshots

_Coming soon – Screenshots of the app interface will be added here._

---

**Built with ❤️ for children with Type 1 diabetes and their caregivers.**
