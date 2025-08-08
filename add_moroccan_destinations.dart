import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('🔥 Firebase initialized successfully');
    
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
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
      await firestore.collection('destinations').add(destinationData);
      print('✅ Added Moroccan destination: ${destinationData['name']}');
    }

    print('🎉 Successfully added ${moroccanDestinations.length} Moroccan destinations!');
  } catch (e) {
    print('❌ Error adding Moroccan destinations: $e');
  }
} 