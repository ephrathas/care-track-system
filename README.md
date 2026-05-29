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
