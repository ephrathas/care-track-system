# 🧒 KidCare – Child Care & Tracking System

A cross-platform Flutter application that helps **parents** and **teachers** manage children's profiles, track attendance, monitor health records, and stay connected — all in one place.

---

## 📱 About the App

**Problem:** Parents and teachers struggle to manage children's daily activities, health records, and attendance across fragmented tools or paper-based systems.

**Solution:** KidCare provides a centralized platform where parents can view child profiles, academic performance, health records, and upcoming events — while teachers can manage attendance and student data.

---

## ✨ Features (Current)

### Parent Dashboard
- Overview stats: children enrolled, average attendance, average performance, pending payments
- Children cards with attendance & performance progress bars, status badges, and recent activity
- Upcoming events list
- Recent notifications feed

### My Children Tab
- Detailed child profile cards with mini stat chips
- Attendance and performance tracking per child

### Academic Progress Tab
- Per-child subject grades with color-coded grade badges (A/B/C)
- Overall performance summary card
- Subject-by-subject progress bars

### Health Records Tab
- Medical records list with status badges (Completed / Pending / Upcoming)
- Health summary card per child
- Quick actions: Add Record, Schedule, Export

### Navigation
- Side drawer with all app sections (Dashboard, My Children, Academic Progress, Health Records, Marketplace, Reports, Billing, Messages)
- Animated bottom navigation bar
- Firebase Auth logout

### Auth Flow
- Login screen
- Role-based registration (Parent / Teacher / Healthcare / Child)
- Role selection screen

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth + Firestore + Storage) |
| State Management | Provider |
| Fonts | Google Fonts (Poppins) |
| Platform | Android, iOS, Web |

### Dependencies

```yaml
flutter_sdk: "^3.5.0"
google_fonts: ^6.3.0
firebase_core: ^4.7.0
firebase_auth: ^6.4.0
cloud_firestore: ^6.3.0
firebase_storage: ^13.3.0
provider: ^6.1.5+1
intl: ^0.20.2
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── routes.dart
│   │   ├── app_texts.dart
│   │   └── colors.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
├── models/
│   ├── child_model.dart
│   └── user_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── child_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── role_selection_screen.dart
│   └── parent/
│       ├── parent_dashboard.dart
│       └── add_child_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── firebase_auth_service.dart
│   └── firestore_service.dart
└── widgets/
    └── app_drawer.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.5.0`
- Dart SDK `>=3.5.0`
- Firebase project with Auth + Firestore + Storage enabled
- Android Studio or VS Code with Flutter extension

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/care-track-system.git
cd care-track-system

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Enable **Cloud Firestore** database
4. Enable **Firebase Storage**
5. Download `google-services.json` → place in `android/app/`
6. Download `GoogleService-Info.plist` → place in `ios/Runner/`
7. Run `flutterfire configure` to regenerate `firebase_options.dart`

> ⚠️ **Note:** The `google-services.json` and `firebase_options.dart` in this repo are for development only. Replace them with your own Firebase config before deploying.

---

## 🌿 Branching Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, reviewed code |
| `feature/parent-dashboard-ui` | Current UI redesign work |
| `feature/teacher-dashboard` | Upcoming teacher screens |
| `feature/attendance-tracking` | Attendance module |
| `feature/health-records` | Health records module |

### How to push your branch

```bash
# Create and switch to your feature branch
git checkout -b feature/your-feature-name

# Stage your changes
git add .

# Commit
git commit -m "feat: describe what you did"

# Push to remote
git push origin feature/your-feature-name
```

Then open a **Pull Request** into `main` on GitHub.

---

## 🗺️ Roadmap

- [x] Authentication (Login / Register / Role Selection)
- [x] Add Child screen with Firestore integration
- [x] Parent Dashboard UI (KidCare design)
- [x] My Children tab
- [x] Academic Progress tab
- [x] Health Records tab
- [ ] Wire dashboard to real Firestore data
- [ ] Teacher Dashboard
- [ ] Attendance tracking module
- [ ] Notifications (Firebase Cloud Messaging)
- [ ] Messaging between parents and teachers
- [ ] Marketplace screen
- [ ] Reports & Billing screens

---

## 👥 Team

| Role | Name |
|---|---|
| Project Lead | _(your name)_ |
| Flutter Developer | _(your name)_ |

---

## 📄 License

This project is for educational purposes as part of a university/college project.
