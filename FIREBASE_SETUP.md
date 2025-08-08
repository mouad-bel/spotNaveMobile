# Firebase Database Implementation

This document provides instructions for setting up Firebase to replace the local and remote storage in your Flutter application.

## Overview

The Firebase implementation includes:
- **Firebase Authentication** for user management
- **Cloud Firestore** for data storage
- **Firebase Storage** for file storage (if needed)

## Prerequisites

1. **Firebase Project**: Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. **FlutterFire CLI**: Install the FlutterFire CLI for easy configuration

## Setup Instructions

### 1. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase

Run the following command in your project root:

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Configure Firebase for all platforms (Android, iOS, Web)
- Generate the `firebase_options.dart` file with proper configuration

### 3. Update Dependencies

The Firebase dependencies have been added to `pubspec.yaml`:

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.3
firebase_storage: ^12.3.3
```

Run:
```bash
flutter pub get
```

### 4. Initialize Firebase in Your App

Update your `main.dart` to initialize Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:fdelux_source_neytrip/core/di/firebase_di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase DI
  await FirebaseDI.initialize();
  
  runApp(MyApp());
}
```

## Firebase Data Sources

### 1. Firebase Auth Data Source (`firebase_auth_data_source.dart`)
- Handles user authentication (login, register, logout)
- Integrates with Firebase Authentication
- Stores user data in Firestore

### 2. Firebase Session Data Source (`firebase_session_data_source.dart`)
- Manages user sessions and tokens
- Replaces local SharedPreferences storage
- Stores session data in Firestore

### 3. Firebase Destination Data Source (`firebase_destination_data_source.dart`)
- Handles destination data operations
- Implements geolocation queries for nearby destinations
- Supports search functionality

### 4. Firebase Saved Destination Data Source (`firebase_saved_destination_data_source.dart`)
- Manages user's saved destinations
- Replaces local storage for saved destinations
- Stores data per user in Firestore

## Firebase Repositories

### 1. Firebase Auth Repository (`firebase_auth_repository.dart`)
- Implements the same interface as the original auth repository
- Uses Firebase Authentication and Firestore
- Handles error mapping and network checks

### 2. Firebase Destination Repository (`firebase_destination_repository.dart`)
- Implements destination operations with Firebase
- Supports popular destinations, nearby search, and individual destination lookup

### 3. Firebase Saved Destination Repository (`firebase_saved_destination_repository.dart`)
- Manages saved destinations with Firebase
- Implements the same interface as the original saved destination repository

## Firestore Database Structure

### Collections

#### 1. `users`
- Stores user profile information
- Document ID: Firebase Auth UID
- Fields: id, name, email, phoneNumber, city, address, postalCode, photoUrl

#### 2. `users/{userId}/tokens`
- Stores user authentication tokens
- Document ID: 'current'
- Fields: accessToken, refreshToken, type, expiresIn

#### 3. `users/{userId}/savedDestinations`
- Stores user's saved destinations
- Document ID: destination ID
- Fields: id, name, cover

#### 4. `destinations`
- Stores destination information
- Document ID: destination ID
- Fields: id, name, location, cover, rating, category, description, popularScore, gallery, reviewCount, bestTimeToVisit, activities, imageSources

## Security Rules

Set up Firestore security rules:

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

## Migration from Local/Remote Storage

### 1. Update Dependency Injection

Replace the existing data sources with Firebase ones:

```dart
// Instead of:
// AuthRemoteDataSource
// SessionLocalDataSource
// DestinationRemoteDataSource
// SavedDestinationLocalDataSource

// Use:
// FirebaseAuthDataSource
// FirebaseSessionDataSource
// FirebaseDestinationDataSource
// FirebaseSavedDestinationDataSource
```

### 2. Update Repositories

Replace repository implementations:

```dart
// Instead of:
// AuthRepositoryImpl
// DestinationRepositoryImpl
// SavedDestinationRepositoryImpl

// Use:
// FirebaseAuthRepositoryImpl
// FirebaseDestinationRepositoryImpl
// FirebaseSavedDestinationRepositoryImpl
```

### 3. Update BLoCs/Use Cases

The BLoCs and use cases can remain the same since the repository interfaces are unchanged.

## Testing

### 1. Unit Tests
- Test Firebase data sources with mocked Firebase instances
- Test repositories with mocked data sources
- Test error handling and edge cases

### 2. Integration Tests
- Test Firebase integration with real Firebase project
- Test authentication flows
- Test data persistence and retrieval

## Error Handling

The Firebase implementation includes comprehensive error handling:

- **Authentication Errors**: Invalid credentials, user not found, etc.
- **Network Errors**: Connection issues, timeouts
- **Permission Errors**: Unauthorized access attempts
- **Data Errors**: Invalid data formats, missing fields

## Performance Considerations

### 1. Offline Support
- Firestore provides offline persistence by default
- Data is cached locally and synced when online
- Configure offline persistence settings as needed

### 2. Query Optimization
- Use compound indexes for complex queries
- Limit query results to prevent large data transfers
- Use pagination for large datasets

### 3. Caching
- Firestore automatically caches data
- Configure cache settings based on your needs
- Consider implementing additional caching strategies

## Monitoring and Analytics

### 1. Firebase Analytics
- Track user behavior and app usage
- Monitor authentication events
- Analyze user engagement

### 2. Firebase Performance
- Monitor app performance
- Track network requests
- Identify bottlenecks

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `Firebase.initializeApp()` is called before using Firebase services
   - Check that `firebase_options.dart` is properly configured

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

## Next Steps

1. **Configure Firebase Project**: Set up your Firebase project and enable required services
2. **Update Configuration**: Run `flutterfire configure` to generate proper configuration
3. **Test Implementation**: Test all Firebase functionality with your data
4. **Deploy**: Deploy your app with Firebase backend
5. **Monitor**: Set up monitoring and analytics for production use

## Support

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

For app-specific issues:
- Check the error logs and Firebase Console
- Review the implementation code
- Test with different scenarios and edge cases 