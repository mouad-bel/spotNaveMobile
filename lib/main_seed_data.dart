import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spotnav/firebase_options.dart';
import 'firebase_data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 Starting Firebase data seeding...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase initialized successfully');
    
    // Run the seeder
    await FirebaseDataSeeder.runSeeder();
    
    print('🎉 Firebase data seeding completed successfully!');
    print('');
    print('📋 Test Account Details:');
    print('📧 Email: test@example.com');
    print('🔑 Password: test123456');
    print('');
    print('Use these credentials to log in to the app and see the destinations!');
    
    // Exit after seeding
    print('✅ Seeding complete. You can now run the main app.');
  } catch (e) {
    print('❌ Error during Firebase seeding: $e');
  }
} 
