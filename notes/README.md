# Notes App

A simple and intuitive notes application built with Flutter and Firebase, allowing users to create, edit, and manage their personal notes with secure authentication.

## Features

- **User Authentication** - Secure sign-up and login with Firebase Auth
- **Create Notes** - Add new notes with title and content
- **Edit Notes** - Modify existing notes anytime
- **Delete Notes** - Remove notes you no longer need
- **Cloud Sync** - All notes are stored in Firebase Firestore
- **Cross-Platform** - Works on Android, iOS, Web, and Desktop

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication for user management
  - Cloud Firestore for data storage

## Prerequisites

Before running this app, make sure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.0.0)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project with Authentication and Firestore enabled

## Getting Started

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd notes
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
- Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Enable Authentication (Email/Password sign-in method)
- Enable Cloud Firestore
- Download the configuration files:
  - `google-services.json` for Android (place in `android/app/`)
  - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

### 4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/
│   └── note.dart               # Note data model
├── providers/
│   ├── auth_provider.dart      # Authentication state management
│   └── notes_provider.dart     # Notes state management
└── screens/
    ├── auth_wrapper.dart       # Authentication flow wrapper
    ├── auth_screen.dart        # Login/Register screen
    ├── notes_screen.dart       # Main notes list screen
    └── add_edit_note_screen.dart # Add/Edit note screen
```

## How to Use

1. **Sign Up/Login**: Create a new account or login with existing credentials
2. **View Notes**: See all your notes on the main screen
3. **Add Note**: Tap the '+' button to create a new note
4. **Edit Note**: Tap on any note to edit its content
5. **Delete Note**: Use the delete option to remove notes

## Dependencies

- `firebase_core` - Firebase SDK core
- `firebase_auth` - Authentication services
- `cloud_firestore` - Firestore database
- `provider` - State management
- `flutter` - UI framework

