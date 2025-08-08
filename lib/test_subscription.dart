import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🔍 Testing subscription data access...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Test fetching subscriptions
    final subscriptionsQuery = await firestore
        .collection('subscriptions')
        .where('is_active', isEqualTo: true)
        .orderBy('price')
        .get();
    
    print('✅ Successfully fetched ${subscriptionsQuery.docs.length} subscriptions:');
    
    for (var doc in subscriptionsQuery.docs) {
      print('  - ${doc.data()['name']} (\$${doc.data()['price']})');
    }
    
  } catch (e) {
    print('❌ Error fetching subscriptions: $e');
  }
  
  print('🏁 Test completed!');
} 
