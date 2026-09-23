# Curio Academy 🎓✨

**Curio Academy** (`com.curio.academy`) is an interactive, gamified learning application designed to help children from **Kindergarten (LKG & UKG) to Class 8** master **Mathematics** and **English** foundational concepts.

---

## 🌟 Key Features

- 📚 **Comprehensive Curriculum (LKG – Class 8)**: Tailored chapters covering foundational numeracy, algebra, geometry, phonics, grammar, and reading comprehension.
- 🫧 **Interactive Kindergarten Games**: Pre-readers in LKG and UKG learn via voice-narrated, tactile **Bubble Pop** mini-games (shapes, counting, colors, phonics, opposites, rhyming words).
- 🧠 **Dynamic Question Generator Engine**: Algorithmic and procedural generation producing hundreds of authentic, grade-appropriate practice questions with step-by-step scaffolding and hints.
- 🎙️ **Multi-Voice Audio & TTS**: Native text-to-speech audio guidance with custom pitch, speech rate, and child-friendly voice selection.
- 🔒 **100% Kid-Safe & Offline**: Fully compliant with **COPPA** and **Google Play Families Policy**. Zero tracking, zero third-party ads, zero cloud personal data storage.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Dart 3.x)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Local Storage**: `shared_preferences` (offline persistence for student mastery, progress, and stars)
- **Audio & Speech**: `flutter_tts` & `audioplayers`
- **Platforms**: Android (Google Play App Bundle & APK), iOS

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.13.3` or higher
- Android Studio / VS Code with Flutter extension
- Java JDK 17+ (for Android builds)

### Installation
```bash
# Clone the repository
git clone https://github.com/<username>/<repo-name>.git
cd curio-academy

# Install dependencies
flutter pub get

# Run test suite
flutter test

# Run app on connected device / emulator
flutter run
```

---

## 📦 Building for Production

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
```

### Release APK
```bash
flutter build apk --release
```

---

## 📄 License & Privacy
- **Privacy Policy**: Compliant with COPPA & Google Play Families Policy. See `store_listing/PRIVACY_POLICY.md`.
