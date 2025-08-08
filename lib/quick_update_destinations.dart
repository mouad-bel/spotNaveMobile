import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotnav/firebase_options.dart';

/// Quick script to update existing destinations with isTopToday=true
/// Run: flutter run lib/quick_update_destinations.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🔥 Firebase initialized');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Get some existing destinations
    final querySnapshot = await firestore
        .collection('destinations')
        .limit(10)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      print('❌ No destinations found in Firebase');
      return;
    }
    
    print('📍 Found ${querySnapshot.docs.length} destinations');
    
    // Update first 3 destinations to be today's top spots
    final batch = firestore.batch();
    
    for (int i = 0; i < 3 && i < querySnapshot.docs.length; i++) {
      final doc = querySnapshot.docs[i];
      final data = doc.data();
      final name = data['name'] ?? 'Unknown';
      
      batch.update(doc.reference, {
        'isTopToday': true,
        'virtualTour': i == 0 || i == 2, // First and third get VR
      });
      
      print('✅ Updated "$name" - isTopToday: true, virtualTour: ${i == 0 || i == 2}');
    }
    
    // Reset others to false
    for (int i = 3; i < querySnapshot.docs.length; i++) {
      final doc = querySnapshot.docs[i];
      batch.update(doc.reference, {
        'isTopToday': false,
      });
    }
    
    await batch.commit();
    print('🌟 Successfully updated destinations!');
    print('💡 Now the Today\'s Top Spots section should show data');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}