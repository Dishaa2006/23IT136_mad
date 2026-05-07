# Smart Study Planner & Exam Preparation Tracker

A robust offline-first Flutter application to help students organize study schedules, track topic progress, and prioritize subjects intelligently.

## Features
- **Subject & Topic Management**: Organize your syllabus.
- **Study Scheduling**: Calendar-based scheduling.
- **Progress Tracking**: Automatic percentage calculation.
- **Offline First**: All data stored locally using `Hive`.
- **Firebase Sync**: Automatically syncs with cloud when internet is available.
- **Local Notifications**: Daily study reminders.
- **Clean Architecture & Modular Structure**.

## Folder Structure
```
lib/
├── core/                  # Core configurations, theme, router
├── features/              # Feature modules (Riverpod Providers & UI)
│   ├── dashboard/         # Dashboard screen
│   ├── scheduling/        # Scheduling screens and logic
│   ├── subjects/          # Subject management
│   ├── topics/            # Topic management
├── models/                # Hive data models
├── services/              # External services (Firebase, Notifications)
└── main.dart              # App entry point
```

## Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Hive Adapters**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run App**
   ```bash
   flutter run
   ```

## GitHub Commit Plan

Follow this logical sequence when committing your code:

1. **`chore: Project Initialization & Structure`**
   - Flutter create, pubspec dependencies, folder structure setup.
2. **`feat: Core Models & Hive Setup`**
   - Created Subject, Topic, and Schedule models, and generated Hive adapters.
3. **`feat: Theme & Routing Setup`**
   - Configured Material 3 themes and GoRouter paths.
4. **`feat: State Management with Riverpod`**
   - Implemented providers for subjects, topics, and scheduling.
5. **`feat: Dashboard Implementation`**
   - Built the summary UI and recommendations logic.
6. **`feat: Subject & Topic Management Screens`**
   - Created screens for CRUD operations on subjects and topics.
7. **`feat: Offline-First & Firebase Sync`**
   - Implemented FirebaseSyncService with connectivity checks.
8. **`feat: Local Notifications Support`**
   - Added scheduling reminders.
9. **`fix: Final Enhancements & Bug Fixes`**
   - Polished UI, added empty states, ensured responsive design.
