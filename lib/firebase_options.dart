// This file needs to be generated using flutterfire configure
// Run: dart pub global activate flutterfire_cli
// Then: flutterfire configure
//
// This will create the proper Firebase configuration for your project

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with your actual Firebase configuration
  // You need to run 'flutterfire configure' to generate these values

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0YMcgq-RYRUL_gb0ia1fBMw5XjUczq6A',
    appId: '1:869071247901:web:3849ffe88fe5863b4944f4',
    messagingSenderId: '869071247901',
    projectId: 'spotnave',
    authDomain: 'spotnave.firebaseapp.com',
    storageBucket: 'spotnave.firebasestorage.app',
    measurementId: 'G-2WEPRPC4DB',
  );

  // For now, using a test configuration - replace with your actual values

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRflvWufgYId8etygIXE_13mTYd7qeCfc',
    appId: '1:869071247901:android:cae38dcd134167ba4944f4',
    messagingSenderId: '869071247901',
    projectId: 'spotnave',
    storageBucket: 'spotnave.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2kgQifnz35fAnh-2uc8uH_MJhnYIbQ9o',
    appId: '1:869071247901:ios:0b36a80a639b703b4944f4',
    messagingSenderId: '869071247901',
    projectId: 'spotnave',
    storageBucket: 'spotnave.firebasestorage.app',
    iosBundleId: 'com.fdelux.neytrip',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2kgQifnz35fAnh-2uc8uH_MJhnYIbQ9o',
    appId: '1:869071247901:ios:0b36a80a639b703b4944f4',
    messagingSenderId: '869071247901',
    projectId: 'spotnave',
    storageBucket: 'spotnave.firebasestorage.app',
    iosBundleId: 'com.fdelux.neytrip',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0YMcgq-RYRUL_gb0ia1fBMw5XjUczq6A',
    appId: '1:869071247901:web:468322df84c884c04944f4',
    messagingSenderId: '869071247901',
    projectId: 'spotnave',
    authDomain: 'spotnave.firebaseapp.com',
    storageBucket: 'spotnave.firebasestorage.app',
    measurementId: 'G-YEL6C7Y43C',
  );

} 
