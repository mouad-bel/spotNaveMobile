import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/firebase_options.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_auth_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_session_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_destination_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_saved_destination_data_source.dart';
import 'package:spotnav/core/di_firebase.dart' as di;

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  // Create data source instances using DI
  FirebaseAuthDataSource createAuthDataSource() {
    return di.sl<FirebaseAuthDataSource>();
  }

  FirebaseSessionDataSource createSessionDataSource() {
    return di.sl<FirebaseSessionDataSource>();
  }

  FirebaseDestinationDataSource createDestinationDataSource() {
    return di.sl<FirebaseDestinationDataSource>();
  }

  FirebaseSavedDestinationDataSource createSavedDestinationDataSource() {
    return di.sl<FirebaseSavedDestinationDataSource>();
  }
} 
