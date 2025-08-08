# Firebase Quick Start Guide

This guide will help you quickly set up and use Firebase in your Flutter project.

## 🚀 Quick Setup

### 1. Dependencies Already Added ✅
The Firebase dependencies have been added to `pubspec.yaml`:
- `firebase_core: ^3.6.0`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.4.3`
- `firebase_storage: ^12.3.3`

### 2. Firebase CLI Installed ✅
Firebase CLI has been installed and is ready to use.

## 🔧 Next Steps

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter a project name (e.g., "fdelux-travel-app")
4. Follow the setup wizard
5. Enable Authentication and Firestore

### Step 2: Configure Firebase for Your App

1. In Firebase Console, click "Add app" and select "Flutter"
2. Register your app with your package name
3. Download the configuration files

### Step 3: Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase project configuration:

```dart
// Replace these with your actual Firebase project values
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'YOUR_ACTUAL_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
);
```

### Step 4: Test Firebase Setup

Run the Firebase test to verify everything is working:

```bash
flutter run -t lib/firebase_test.dart
```

### Step 5: Use Firebase in Your App

To use Firebase instead of local/remote storage, change your main.dart:

```dart
// Instead of:
import 'package:fdelux_source_neytrip/core/di.dart' as di;
await di.init();

// Use:
import 'package:fdelux_source_neytrip/core/di_firebase.dart' as di;
await di.initFirebase();
```

Or simply rename `lib/main_firebase.dart` to `lib/main.dart` to use Firebase.

## 📁 Files Created

### Firebase Data Sources
- `lib/data/data_sources/firebase/firebase_auth_data_source.dart`
- `lib/data/data_sources/firebase/firebase_session_data_source.dart`
- `lib/data/data_sources/firebase/firebase_destination_data_source.dart`
- `lib/data/data_sources/firebase/firebase_saved_destination_data_source.dart`

### Firebase Repositories
- `lib/data/repositories/firebase_auth_repository.dart`
- `lib/data/repositories/firebase_destination_repository.dart`
- `lib/data/repositories/firebase_saved_destination_repository.dart`

### Adapters (for compatibility)
- `lib/data/repositories/firebase_repository_adapters.dart`

### Configuration Files
- `lib/core/di_firebase.dart` - Firebase dependency injection
- `lib/main_firebase.dart` - Firebase-enabled main.dart
- `lib/firebase_test.dart` - Firebase test app

## 🔥 Firebase Features

### Authentication
- Email/password authentication
- User registration and login
- Session management
- Automatic token refresh

### Firestore Database
- Real-time data synchronization
- Offline support
- Complex queries with geolocation
- User-specific data storage

### Data Structure
```
users/{userId}/
├── tokens/current
└── savedDestinations/{destinationId}

destinations/{destinationId}
```

## 🧪 Testing

### Test Firebase Setup
```bash
flutter run -t lib/firebase_test.dart
```

### Test Firebase Integration
```bash
flutter run -t lib/main_firebase_example.dart
```

### Test Full App with Firebase
```bash
flutter run -t lib/main_firebase.dart
```

## 🔒 Security Rules

Set up these Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow access to subcollections
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Destinations are readable by authenticated users
    match /destinations/{destinationId} {
      allow read: if request.auth != null;
    }
  }
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `Firebase.initializeApp()` is called before using Firebase services
   - Check that `firebase_options.dart` has correct configuration

2. **Authentication errors**
   - Verify Firebase project settings
   - Check authentication methods are enabled in Firebase Console
   - Ensure proper security rules are set

3. **Permission denied errors**
   - Review Firestore security rules
   - Check user authentication status
   - Verify document paths and permissions

4. **Network connectivity issues**
   - Implement proper offline handling
   - Check network connectivity before making requests
   - Use Firebase offline persistence

### Debug Commands

```bash
# Check Firebase CLI
firebase --version

# Check FlutterFire CLI
flutterfire --version

# Test Firebase connection
flutter run -t lib/firebase_test.dart
```

## 📚 Next Steps

1. **Set up your Firebase project** with real configuration
2. **Test the Firebase integration** using the test files
3. **Migrate your data** from local/remote to Firebase
4. **Deploy your app** with Firebase backend
5. **Monitor and optimize** using Firebase Analytics

## 🆘 Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

The Firebase implementation is ready to use! Just update the configuration with your actual Firebase project details. 