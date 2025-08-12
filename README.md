# SpotNav - Flutter Travel App 🌍

A beautiful Flutter travel application with Firebase integration, featuring destination discovery, notifications, maps, and user authentication.

## Features ✨

- 🗺️ **Interactive Maps** - Discover nearby destinations with real-time location
- 🔔 **Smart Notifications** - Get notified about new destinations and updates
- 🏞️ **Beautiful Destinations** - Explore curated travel destinations with detailed information
- 👤 **User Profiles** - Complete user management with profile editing
- 💾 **Save Favorites** - Save and manage your favorite destinations
- 🔍 **Smart Search** - Find destinations by name, location, or category
- 📱 **Modern UI** - Beautiful, responsive design following Material Design principles

## Prerequisites 📋

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.19.0 or higher)
  - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter plugins
- **Git**

## Firebase Setup 🔥

This app uses Firebase for backend services. You'll need to set up your own Firebase project:

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Follow the setup wizard

### 2. Enable Firebase Services
Enable the following services in your Firebase project:
- **Authentication** (Email/Password)
- **Firestore Database**
- **Storage**

### 3. Configure Firebase for Flutter
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. Run: `flutterfire configure`
4. Select your Firebase project
5. Choose platforms (iOS, Android, Web)

### 4. Authentication Setup
In Firebase Console > Authentication > Sign-in method:
- Enable **Email/Password** provider

### 5. Firestore Database Setup
1. Create a Firestore database in production mode
2. Update security rules (see `firestore.rules` in project)

### 6. Storage Setup
1. Enable Firebase Storage
2. Update security rules (see `storage.rules` in project)

## Installation & Setup 🚀

### 1. Clone the Repository
```bash
git clone https://github.com/mouad-bel/spotNaveMobile.git
cd spotNaveMobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Platform Files
Since platform files are gitignored, generate them:
```bash
# For Android
flutter create --platforms android .

# For iOS (macOS only)
flutter create --platforms ios .

# For Web
flutter create --platforms web .

# For all platforms
flutter create --platforms android,ios,web .
```

### 4. Firebase Configuration
After running `flutterfire configure`, you should have:
- `lib/firebase_options.dart` (generated automatically)
- Platform-specific configuration files

### 5. Add Google Services Files
- **Android**: Add `google-services.json` to `android/app/`
- **iOS**: Add `GoogleService-Info.plist` to `ios/Runner/`

## Running the App 📱

### For Development
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device_id>

# Run in debug mode with hot reload
flutter run --debug
```

### For Production
```bash
# Build APK (Android)
flutter build apk --release

# Build iOS (requires macOS and Xcode)
flutter build ios --release

# Build for web
flutter build web --release
```

## Project Structure 📁

```
lib/
├── common/           # Shared widgets, colors, constants
├── core/            # App router, dependency injection
├── data/            # Data sources, models, repositories
├── presentation/    # UI screens and widgets
└── main.dart        # App entry point
```

## Firebase Collections Structure 📊

### Users Collection
```javascript
users/{userId} {
  id: string,
  name: string,
  email: string,
  profileImage?: string,
  createdAt: timestamp
}
```

### Destinations Collection
```javascript
destinations/{destinationId} {
  id: string,
  name: string,
  description: string,
  cover: string,
  rating: number,
  category: string[],
  location: {
    latitude: number,
    longitude: number,
    address: string,
    city: string,
    country: string
  },
  // ... other fields
}
```

### Notifications Collection
```javascript
notifications/{notificationId} {
  id: string,
  title: string,
  body: string,
  userId: string,
  isRead: boolean,
  timestamp: timestamp,
  type: string
}
```

## Environment Variables 🔐

Create a `.env` file (optional) for additional configuration:
```
MAPS_API_KEY=your_google_maps_api_key
```

## Troubleshooting 🔧

### Common Issues

1. **Build errors after cloning**
   - Run `flutter clean && flutter pub get`
   - Regenerate platform files with `flutter create`

2. **Firebase connection issues**
   - Verify `google-services.json` is in correct location
   - Check Firebase project configuration
   - Ensure all required services are enabled

3. **Permission issues**
   - Check location permissions in device settings
   - Verify camera/storage permissions for profile images

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Support 💬

If you encounter any issues or have questions:
1. Check the troubleshooting section above
2. Search existing GitHub issues
3. Create a new issue with detailed description

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase for backend services
- Contributors and testers

---

**Happy coding! 🚀**