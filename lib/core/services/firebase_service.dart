import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/firebase_options.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_auth_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_session_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_destination_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_saved_destination_data_source.dart';

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

  // Create data source instances
  FirebaseAuthDataSource createAuthDataSource() {
    return FirebaseAuthDataSourceImpl(
      firebaseAuth: _auth,
      firestore: _firestore,
    );
  }

  FirebaseSessionDataSource createSessionDataSource() {
    return FirebaseSessionDataSourceImpl(
      firebaseAuth: _auth,
      firestore: _firestore,
    );
  }

  FirebaseDestinationDataSource createDestinationDataSource() {
    return FirebaseDestinationDataSourceImpl(
      firestore: _firestore,
      firebaseAuth: _auth,
    );
  }

  FirebaseSavedDestinationDataSource createSavedDestinationDataSource() {
    return FirebaseSavedDestinationDataSourceImpl(
      firestore: _firestore,
      firebaseAuth: _auth,
    );
  }
} 
