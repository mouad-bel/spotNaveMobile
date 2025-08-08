import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/firebase_options.dart';

class FirebaseDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<void> clearDestinationsData() async {
    try {
      print('🗑️ Clearing existing destinations data...');
      
      // Get all documents in the destinations collection
      final QuerySnapshot querySnapshot = await _firestore.collection('destinations').get();
      
      // Delete each document
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Deleted destination: ${doc.id}');
      }
      
      print('✅ Successfully cleared ${querySnapshot.docs.length} destinations!');
    } catch (e) {
      print('❌ Error clearing destinations: $e');
    }
  }

  static Future<void> createTestUser() async {
    try {
      print('👤 Creating test user...');
      
      const String testEmail = 'test@example.com';
      const String testPassword = 'test123456';
      const String testName = 'Test User';
      
      // Check if user already exists
      try {
        final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        print('✅ Test user already exists: ${userCredential.user?.email}');
        return;
      } catch (e) {
        // User doesn't exist, create it
        print('Creating new test user...');
      }
      
      // Create user in Firebase Auth
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }
      
      // Create user document in Firestore
      final Map<String, dynamic> userData = {
        'id': 999,
        'name': testName,
        'email': testEmail,

        'phone_number': '+1234567890',
        'city': 'Test City',
        'address': '123 Test St',
        'postal_code': '12345',
        'photo_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        'subscription_id': null, // Will be assigned after subscriptions are created
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };
      
      await _firestore.collection('users').doc(user.uid).set(userData);
      
      print('✅ Test user created successfully: ${user.email}');
      print('📧 Email: $testEmail');
      print('🔑 Password: $testPassword');
      
    } catch (e) {
      print('❌ Error creating test user: $e');
    }
  }

  static Future<void> seedDestinationsData() async {
    try {
      print('🌱 Starting to seed destinations data...');

      // Sample destinations data with correct structure
      final List<Map<String, dynamic>> destinationsData = [
        {
          'id': 1,
          'name': 'Eiffel Tower',
          'description': 'Iconic iron lattice tower on the Champ de Mars in Paris, France.',
          'cover': 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800',
          'rating': 4.7,
          'category': ['Landmark', 'Tourist Attraction', 'Architecture'],
          'popular_score': 95,
          'gallery': [
            'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800',
            'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800',
            'https://images.unsplash.com/photo-1502602898536-47ad22581b52?w=800',
            'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          ],
          'review_count': 1250,
          'activities': ['Photography', 'Sightseeing', 'Dining'],
          'image_sources': ['Unsplash', 'Pexels'],
          'location': {
            'address': 'Champ de Mars, 5 Avenue Anatole France',
            'city': 'Paris',
            'country': 'France',
            'latitude': 48.8584,
            'longitude': 2.2945,
          },
          'best_time_to_visit': {
            'season': 'Spring',
            'months': ['March', 'April', 'May'],
            'notes': 'Mild weather and fewer crowds'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 2,
          'name': 'Santorini Sunset',
          'description': 'Breathtaking sunset views from the white-washed buildings of Oia.',
          'cover': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
          'rating': 4.9,
          'category': ['Beach', 'Sunset', 'Island'],
          'popular_score': 98,
          'gallery': [
            'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
            'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          ],
          'review_count': 890,
          'activities': ['Sunset Viewing', 'Photography', 'Wine Tasting'],
          'image_sources': ['Unsplash', 'Pexels'],
          'location': {
            'address': 'Oia, Santorini',
            'city': 'Oia',
            'country': 'Greece',
            'latitude': 36.4619,
            'longitude': 25.3763,
          },
          'best_time_to_visit': {
            'season': 'Summer',
            'months': ['June', 'July', 'August'],
            'notes': 'Perfect weather for sunset viewing'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 3,
          'name': 'Machu Picchu',
          'description': 'Ancient Incan citadel set high in the Andes Mountains.',
          'cover': 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=800',
          'rating': 4.8,
          'category': ['Historical', 'Mountain', 'Archaeological'],
          'popular_score': 92,
          'gallery': [
            'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=800',
            'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          ],
          'review_count': 756,
          'activities': ['Hiking', 'Archaeology', 'Photography'],
          'image_sources': ['Unsplash', 'Pexels'],
          'location': {
            'address': 'Machu Picchu, Peru',
            'city': 'Machu Picchu',
            'country': 'Peru',
            'latitude': -13.1631,
            'longitude': -72.5450,
          },
          'best_time_to_visit': {
            'season': 'Dry Season',
            'months': ['May', 'June', 'July', 'August'],
            'notes': 'Clear skies and comfortable temperatures'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
      ];

      // Add destinations to Firestore
      for (final destinationData in destinationsData) {
        await _firestore.collection('destinations').add(destinationData);
        print('✅ Added destination: ${destinationData['name']}');
      }

      print('🎉 Successfully seeded ${destinationsData.length} destinations!');
    } catch (e) {
      print('❌ Error seeding destinations: $e');
    }
  }

  static Future<void> seedMoroccanDestinations() async {
    try {
      print('🌱 Starting to seed Moroccan destinations data...');

      // Moroccan destinations data
      final List<Map<String, dynamic>> moroccanDestinations = [
        {
          'id': 101,
          'name': 'Jemaa el-Fnaa',
          'description': 'The heart of Marrakech, this bustling square is filled with storytellers, musicians, and street performers.',
          'cover': 'https://images.unsplash.com/photo-1553603228-3f2856bb9c2f?w=800',
          'rating': 4.6,
          'category': ['Cultural', 'Market', 'Historical'],
          'popular_score': 88,
          'gallery': [
            'https://images.unsplash.com/photo-1553603228-3f2856bb9c2f?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          ],
          'review_count': 450,
          'activities': ['Street Food', 'Shopping', 'Cultural Experience'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Jemaa el-Fnaa, Marrakech',
            'city': 'Marrakech',
            'country': 'Morocco',
            'latitude': 31.6258,
            'longitude': -7.9891,
          },
          'best_time_to_visit': {
            'season': 'Spring/Fall',
            'months': ['March', 'April', 'May', 'September', 'October'],
            'notes': 'Pleasant weather, less crowded'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 102,
          'name': 'Chefchaouen Blue City',
          'description': 'Famous for its blue-painted buildings, this charming city in the Rif Mountains offers stunning views and a relaxed atmosphere.',
          'cover': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.8,
          'category': ['Cultural', 'Architecture', 'Mountain'],
          'popular_score': 92,
          'gallery': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          ],
          'review_count': 320,
          'activities': ['Photography', 'Hiking', 'Cultural Tours'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Chefchaouen, Morocco',
            'city': 'Chefchaouen',
            'country': 'Morocco',
            'latitude': 35.1714,
            'longitude': -5.2696,
          },
          'best_time_to_visit': {
            'season': 'Spring/Summer',
            'months': ['April', 'May', 'June', 'July'],
            'notes': 'Beautiful weather and clear skies'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 103,
          'name': 'Fes El Bali Medina',
          'description': 'The world\'s largest car-free urban area, this medieval medina is a UNESCO World Heritage site with narrow alleys and traditional crafts.',
          'cover': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'rating': 4.7,
          'category': ['Historical', 'Cultural', 'UNESCO'],
          'popular_score': 90,
          'gallery': [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          ],
          'review_count': 380,
          'activities': ['Cultural Tours', 'Shopping', 'Historical Exploration'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Fes El Bali, Fes',
            'city': 'Fes',
            'country': 'Morocco',
            'latitude': 34.0181,
            'longitude': -5.0078,
          },
          'best_time_to_visit': {
            'season': 'Spring/Fall',
            'months': ['March', 'April', 'May', 'September', 'October'],
            'notes': 'Comfortable temperatures for walking'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 104,
          'name': 'Sahara Desert Merzouga',
          'description': 'Experience the magic of the Sahara with camel treks, desert camping, and stunning sand dunes.',
          'cover': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          'rating': 4.9,
          'category': ['Desert', 'Adventure', 'Nature'],
          'popular_score': 95,
          'gallery': [
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          ],
          'review_count': 520,
          'activities': ['Camel Trek', 'Desert Camping', 'Stargazing'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Merzouga, Morocco',
            'city': 'Merzouga',
            'country': 'Morocco',
            'latitude': 31.0997,
            'longitude': -4.0125,
          },
          'best_time_to_visit': {
            'season': 'Spring/Fall',
            'months': ['March', 'April', 'May', 'September', 'October'],
            'notes': 'Pleasant temperatures, avoid summer heat'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 105,
          'name': 'Casablanca Hassan II Mosque',
          'description': 'The largest mosque in Africa, featuring stunning Islamic architecture and ocean views.',
          'cover': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.5,
          'category': ['Religious', 'Architecture', 'Coastal'],
          'popular_score': 85,
          'gallery': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          ],
          'review_count': 290,
          'activities': ['Religious Tours', 'Photography', 'Cultural Experience'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Boulevard de la Corniche, Casablanca',
            'city': 'Casablanca',
            'country': 'Morocco',
            'latitude': 33.6089,
            'longitude': -7.6328,
          },
          'best_time_to_visit': {
            'season': 'Year-round',
            'months': ['All year'],
            'notes': 'Indoor attraction, visit anytime'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 106,
          'name': 'Atlas Mountains',
          'description': 'Majestic mountain range offering hiking, traditional Berber villages, and breathtaking landscapes.',
          'cover': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'rating': 4.6,
          'category': ['Mountain', 'Nature', 'Adventure'],
          'popular_score': 87,
          'gallery': [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          ],
          'review_count': 340,
          'activities': ['Hiking', 'Village Tours', 'Photography'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Atlas Mountains, Morocco',
            'city': 'Atlas Mountains',
            'country': 'Morocco',
            'latitude': 31.6595,
            'longitude': -7.9733,
          },
          'best_time_to_visit': {
            'season': 'Spring/Fall',
            'months': ['March', 'April', 'May', 'September', 'October'],
            'notes': 'Best weather for hiking and exploration'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 107,
          'name': 'Essaouira Coastal Town',
          'description': 'Charming coastal town known for its fortified medina, fresh seafood, and artistic community.',
          'cover': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          'rating': 4.4,
          'category': ['Coastal', 'Cultural', 'Artistic'],
          'popular_score': 82,
          'gallery': [
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          ],
          'review_count': 280,
          'activities': ['Beach Activities', 'Art Galleries', 'Seafood Dining'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Essaouira, Morocco',
            'city': 'Essaouira',
            'country': 'Morocco',
            'latitude': 31.5085,
            'longitude': -9.7595,
          },
          'best_time_to_visit': {
            'season': 'Spring/Summer',
            'months': ['April', 'May', 'June', 'July', 'August'],
            'notes': 'Pleasant coastal weather'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 108,
          'name': 'Volubilis Roman Ruins',
          'description': 'Ancient Roman archaeological site featuring well-preserved mosaics and historical ruins.',
          'cover': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.3,
          'category': ['Historical', 'Archaeological', 'UNESCO'],
          'popular_score': 78,
          'gallery': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          ],
          'review_count': 190,
          'activities': ['Historical Tours', 'Archaeology', 'Photography'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Volubilis, Morocco',
            'city': 'Volubilis',
            'country': 'Morocco',
            'latitude': 34.0744,
            'longitude': -5.5557,
          },
          'best_time_to_visit': {
            'season': 'Spring/Fall',
            'months': ['March', 'April', 'May', 'September', 'October'],
            'notes': 'Comfortable weather for outdoor exploration'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 109,
          'name': 'Tangier Kasbah',
          'description': 'Historic fortress and medina offering stunning views of the Mediterranean and Atlantic.',
          'cover': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'rating': 4.2,
          'category': ['Historical', 'Coastal', 'Cultural'],
          'popular_score': 75,
          'gallery': [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          ],
          'review_count': 160,
          'activities': ['Historical Tours', 'Photography', 'Cultural Experience'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Tangier Kasbah, Tangier',
            'city': 'Tangier',
            'country': 'Morocco',
            'latitude': 35.7845,
            'longitude': -5.8127,
          },
          'best_time_to_visit': {
            'season': 'Spring/Summer',
            'months': ['April', 'May', 'June', 'July'],
            'notes': 'Pleasant weather and clear views'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
        {
          'id': 110,
          'name': 'Agadir Beach Resort',
          'description': 'Modern beach resort city with beautiful beaches, water sports, and vibrant nightlife.',
          'cover': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          'rating': 4.1,
          'category': ['Beach', 'Resort', 'Modern'],
          'popular_score': 72,
          'gallery': [
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          ],
          'review_count': 140,
          'activities': ['Beach Activities', 'Water Sports', 'Nightlife'],
          'image_sources': ['Unsplash'],
          'location': {
            'address': 'Agadir, Morocco',
            'city': 'Agadir',
            'country': 'Morocco',
            'latitude': 30.4278,
            'longitude': -9.5981,
          },
          'best_time_to_visit': {
            'season': 'Spring/Summer',
            'months': ['April', 'May', 'June', 'July', 'August'],
            'notes': 'Perfect beach weather'
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin',
          'isActive': true,
          'isFeatured': true,
        },
      ];

      // Add Moroccan destinations to Firestore
      for (final destinationData in moroccanDestinations) {
        await _firestore.collection('destinations').add(destinationData);
        print('✅ Added Moroccan destination: ${destinationData['name']}');
      }

      print('🎉 Successfully seeded ${moroccanDestinations.length} Moroccan destinations!');
    } catch (e) {
      print('❌ Error seeding Moroccan destinations: $e');
    }
  }

  static Future<void> seedSubscriptionsData() async {
    try {
      print('💳 Starting to seed subscriptions data...');

      // Sample subscriptions data
      final List<Map<String, dynamic>> subscriptionsData = [
        {
          'name': 'Free',
          'description': 'Basic access to destinations and features',
          'price': 0.0,
          'type': 'free',
          'features': [
            'Access to 10 destinations',
            'Basic search functionality',
            'Standard support',
          ],
          'is_active': true,
          'max_destinations': 10,
          'has_premium_support': false,
          'has_offline_access': false,
          'has_advanced_analytics': false,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        },
        {
          'name': 'Basic',
          'description': 'Enhanced features for casual travelers',
          'price': 4.99,
          'type': 'basic',
          'features': [
            'Access to 50 destinations',
            'Advanced search filters',
            'Priority support',
            'Offline access to saved destinations',
          ],
          'is_active': true,
          'max_destinations': 50,
          'has_premium_support': false,
          'has_offline_access': true,
          'has_advanced_analytics': false,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        },
        {
          'name': 'Premium',
          'description': 'Premium features for serious travelers',
          'price': 9.99,
          'type': 'premium',
          'features': [
            'Unlimited destinations',
            'Premium search filters',
            'Premium support',
            'Offline access to all destinations',
            'Advanced analytics',
            'Custom travel itineraries',
          ],
          'is_active': true,
          'max_destinations': null, // Unlimited
          'has_premium_support': true,
          'has_offline_access': true,
          'has_advanced_analytics': true,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        },
        {
          'name': 'Pro',
          'description': 'Professional features for travel experts',
          'price': 19.99,
          'type': 'pro',
          'features': [
            'Everything in Premium',
            'API access',
            'White-label solutions',
            'Dedicated account manager',
            'Custom integrations',
            'Advanced reporting',
          ],
          'is_active': true,
          'max_destinations': null, // Unlimited
          'has_premium_support': true,
          'has_offline_access': true,
          'has_advanced_analytics': true,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        },
      ];

      // Add subscriptions to Firestore
      for (final subscriptionData in subscriptionsData) {
        final docRef = await _firestore.collection('subscriptions').add(subscriptionData);
        print('✅ Added subscription: ${subscriptionData['name']} with ID: ${docRef.id}');
      }

      print('🎉 Successfully seeded ${subscriptionsData.length} subscriptions!');
    } catch (e) {
      print('❌ Error seeding subscriptions: $e');
    }
  }

  static Future<void> assignFreeSubscriptionsToUsers() async {
    try {
      print('🆓 Assigning free subscriptions to users...');

      // Get the free subscription ID
      final QuerySnapshot freeSubscriptionQuery = await _firestore
          .collection('subscriptions')
          .where('type', isEqualTo: 'free')
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (freeSubscriptionQuery.docs.isEmpty) {
        print('❌ No free subscription found');
        return;
      }

      final String freeSubscriptionId = freeSubscriptionQuery.docs.first.id;

      // Get all users without subscription
      final QuerySnapshot usersQuery = await _firestore
          .collection('users')
          .where('subscription_id', isNull: true)
          .get();

      // Update users to assign free subscription
      for (final doc in usersQuery.docs) {
        await doc.reference.update({
          'subscription_id': freeSubscriptionId,
          'updated_at': Timestamp.now(),
        });
        print('✅ Assigned free subscription to user: ${doc.id}');
      }

      print('🎉 Successfully assigned free subscriptions to ${usersQuery.docs.length} users!');
    } catch (e) {
      print('❌ Error assigning free subscriptions: $e');
    }
  }

  static Future<void> seedUsersData() async {
    try {
      print('👥 Starting to seed users data...');

      // Sample users data
      final List<Map<String, dynamic>> usersData = [
        {
          'id': 1,
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phone_number': '+1234567890',
          'city': 'New York',
          'address': '123 Main St',
          'postal_code': '10001',
          'photo_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
          'subscription_id': null, // Will be assigned after subscriptions are created
        },
        {
          'id': 2,
          'name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'phone_number': '+0987654321',
          'city': 'Los Angeles',
          'address': '456 Oak Ave',
          'postal_code': '90210',
          'photo_url': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
          'subscription_id': null, // Will be assigned after subscriptions are created
        },
      ];

      // Add users to Firestore
      for (final userData in usersData) {
        final docRef = await _firestore.collection('users').add(userData);
        print('✅ Added user: ${userData['name']} with ID: ${docRef.id}');
      }

      print('🎉 Successfully seeded ${usersData.length} users!');
    } catch (e) {
      print('❌ Error seeding users: $e');
    }
  }

  static Future<void> runSeeder() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('🚀 Firebase Data Seeder Starting...');
    
    await createTestUser();
    await clearDestinationsData(); // Clear existing data first
    await seedDestinationsData();
    await seedMoroccanDestinations(); // Add this line to seed Moroccan destinations
    await seedSubscriptionsData(); // Seed subscriptions first
    await seedUsersData();
    await assignFreeSubscriptionsToUsers(); // Assign free subscriptions to users
    
    print('✨ Seeding completed!');
  }

  static Future<void> main() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print('🔥 Firebase initialized successfully');
      
      // Run just the Moroccan destinations seeder
      await seedMoroccanDestinations();
      
      print('✅ Moroccan destinations seeding completed!');
    } catch (e) {
      print('❌ Error in main: $e');
    }
  }
}

// Run this function to seed your database
void main() async {
  await FirebaseDataSeeder.runSeeder();
} 
