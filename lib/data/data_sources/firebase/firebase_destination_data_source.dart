import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseDestinationDataSource {
  Future<List<DestinationModel>> fetchAll();
  Future<List<DestinationModel>> fetchPopular();
  Future<List<DestinationModel>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Future<DestinationModel> findById(String id);
  Future<List<DestinationModel>> searchDestinations(String query);
  Future<List<DestinationModel>> fetchByCategory(String category);
  Future<List<DestinationModel>> fetchTodaysTopSpots();
  Future<List<String>> fetchAllCategories();
  Future<List<DestinationModel>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  });
  
  // Real-time listeners for live updates
  Stream<List<DestinationModel>> streamAll();
  Stream<List<DestinationModel>> streamPopular();
  Stream<List<DestinationModel>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Stream<DestinationModel?> streamById(String id);
  Stream<List<DestinationModel>> streamByCategory(String category);
  Stream<List<DestinationModel>> streamTodaysTopSpots();
}

class FirebaseDestinationDataSourceImpl implements FirebaseDestinationDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  const FirebaseDestinationDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  Future<void> _ensureAuthenticated() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw const UnauthenticatedException(
        message: 'Authentication required to access destinations',
      );
    }
  }

  @override
  Future<List<DestinationModel>> fetchAll() async {
    try {
      await _ensureAuthenticated();

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .orderBy('rating', descending: true)
          .get();

      final List<DestinationModel> destinations = await compute(
        _parseDestinationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      return destinations;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch all destinations: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching all destinations: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Stream<List<DestinationModel>> streamAll() {
    return _firestore
        .collection('destinations')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DestinationModel.fromJson({
          ...data,
          'id': doc.id, // Use the actual document ID
        });
      }).toList();
    }).handleError((error) {
      if (error is FirebaseException) {
        throw ServerException(
          message: 'Failed to stream all destinations: ${error.message}',
          error: error,
        );
      }
      throw ServerException(
        message: 'Unexpected error streaming all destinations: ${error.toString()}',
        error: error,
      );
    });
  }

  @override
  Future<List<DestinationModel>> fetchPopular() async {
    try {
      await _ensureAuthenticated();

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .where('popular_score', isGreaterThan: 0)
          .orderBy('popular_score', descending: true)
          .limit(20) // Limit to top 20 popular destinations
          .get();

      final List<DestinationModel> destinations = await compute(
        _parseDestinationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      // If no popular destinations found, fallback to rating-based sorting
      if (destinations.isEmpty) {
        final fallbackQuerySnapshot = await _firestore
            .collection('destinations')
            .orderBy('rating', descending: true)
            .limit(20)
            .get();

        final fallbackDestinations = await compute(
          _parseDestinationsFromQuerySnapshot,
          fallbackQuerySnapshot.docs,
        );
        return fallbackDestinations;
      }

      return destinations;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch destinations: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching destinations: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Stream<List<DestinationModel>> streamPopular() {
    return _firestore
        .collection('destinations')
        .where('popular_score', isGreaterThan: 0)
        .orderBy('popular_score', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          //print('DEBUG: Firebase returned ${snapshot.docs.length} popular destinations');
          final destinations = snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return DestinationModel.fromJson({
              ...data,
              'id': doc.id, // Use the actual document ID
            });
          }).toList();
          
          return destinations;
        })
        .handleError((error) {
          //print('DEBUG: Firebase error: $error');
          if (error is FirebaseException) {
            throw ServerException(
              message: 'Failed to stream destinations: ${error.message}',
              error: error,
            );
          }
          throw ServerException(
            message: 'Unexpected error streaming destinations: ${error.toString()}',
            error: error,
          );
        });
  }

  @override
  Future<List<DestinationModel>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      await _ensureAuthenticated();

      // Calculate bounding box for the radius
      final double latDelta = radius / 111.0; // Approximate km to degrees
      final double lonDelta = radius / (111.0 * cos(latitude * pi / 180));

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .where('location.latitude', isGreaterThanOrEqualTo: latitude - latDelta)
          .where('location.latitude', isLessThanOrEqualTo: latitude + latDelta)
          .get();

      // Filter by longitude and calculate actual distance
      final List<DestinationModel> nearbyDestinations = [];
      final Set<String> seenIds = {}; // Track seen destination IDs
      
      for (final doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> locationData = data['location'] as Map<String, dynamic>;
        final double destLat = locationData['latitude'] as double;
        final double destLon = locationData['longitude'] as double;

        // Check if within longitude bounds
        if (destLon >= longitude - lonDelta && destLon <= longitude + lonDelta) {
          // Calculate actual distance using Haversine formula
          final double distance = _calculateDistance(
            latitude, longitude, destLat, destLon,
          );

          if (distance <= radius) {
            final destination = DestinationModel.fromJson({
              ...data,
              'id': doc.id,
            });
            
            // Only add if we haven't seen this destination before
            if (!seenIds.contains(destination.id)) {
              seenIds.add(destination.id);
              nearbyDestinations.add(destination);
            }
          }
        }
      }

      // Sort by distance
      nearbyDestinations.sort((a, b) {
        final double distA = _calculateDistance(
          latitude, longitude, a.location.latitude, a.location.longitude,
        );
        final double distB = _calculateDistance(
          latitude, longitude, b.location.latitude, b.location.longitude,
        );
        return distA.compareTo(distB);
      });

      return nearbyDestinations;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch nearby destinations: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching nearby destinations: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Stream<List<DestinationModel>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  ) {
    // Calculate bounding box for the radius
    final double latDelta = radius / 111.0; // Approximate km to degrees
    final double lonDelta = radius / (111.0 * cos(latitude * pi / 180));

    return _firestore
        .collection('destinations')
        .where('location.latitude', isGreaterThanOrEqualTo: latitude - latDelta)
        .where('location.latitude', isLessThanOrEqualTo: latitude + latDelta)
        .snapshots()
        .map((snapshot) {
          final List<DestinationModel> nearbyDestinations = [];
          final Set<String> seenIds = {}; // Track seen destination IDs
          
          for (final doc in snapshot.docs) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final Map<String, dynamic> locationData = data['location'] as Map<String, dynamic>;
            final double destLat = locationData['latitude'] as double;
            final double destLon = locationData['longitude'] as double;

            // Check if within longitude bounds
            if (destLon >= longitude - lonDelta && destLon <= longitude + lonDelta) {
              // Calculate actual distance using Haversine formula
              final double distance = _calculateDistance(
                latitude, longitude, destLat, destLon,
              );

              if (distance <= radius) {
                final destination = DestinationModel.fromJson({
                  ...data,
                  'id': doc.id,
                });
                
                // Only add if we haven't seen this destination before
                if (!seenIds.contains(destination.id)) {
                  seenIds.add(destination.id);
                  nearbyDestinations.add(destination);
                }
              }
            }
          }

          // Sort by distance
          nearbyDestinations.sort((a, b) {
            final double distA = _calculateDistance(
              latitude, longitude, a.location.latitude, a.location.longitude,
            );
            final double distB = _calculateDistance(
              latitude, longitude, b.location.latitude, b.location.longitude,
            );
            return distA.compareTo(distB);
          });

          return nearbyDestinations;
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw ServerException(
              message: 'Failed to stream nearby destinations: ${error.message}',
              error: error,
            );
          }
          throw ServerException(
            message: 'Unexpected error streaming nearby destinations: ${error.toString()}',
            error: error,
          );
        });
  }

  @override
  Future<DestinationModel> findById(String id) async {
    try {
      await _ensureAuthenticated();

      print('🔍 Firebase findById called with ID: "$id"');

      final DocumentSnapshot documentSnapshot = await _firestore
          .collection('destinations')
          .doc(id)
          .get();

      print('🔍 Document exists: ${documentSnapshot.exists}');
      print('🔍 Document ID: ${documentSnapshot.id}');

      if (!documentSnapshot.exists) {
        print('❌ Destination not found with ID: $id');
        throw const NotFoundException(
          message: 'Destination not found',
        );
      }

      final Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      print('🔍 Document data keys: ${data.keys.toList()}');
      
      final destination = DestinationModel.fromJson({
        ...data,
        'id': documentSnapshot.id, // Use the actual document ID
      });
      
      print('✅ Successfully found destination: ${destination.name} (ID: ${destination.id})');
      return destination;
    } on FirebaseException catch (e) {
      print('❌ Firebase error in findById: ${e.message}');
      throw ServerException(
        message: 'Failed to fetch destination by ID: ${e.message}',
        error: e,
      );
    } catch (e) {
      print('❌ Unexpected error in findById: $e');
      if (e is UnauthenticatedException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching destination by ID: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Stream<DestinationModel?> streamById(String id) {
    return _firestore
        .collection('destinations')
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }
          final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          return DestinationModel.fromJson({
            ...data,
            'id': snapshot.id, // Use the actual document ID
          });
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw ServerException(
              message: 'Failed to stream destination by ID: ${error.message}',
              error: error,
            );
          }
          throw ServerException(
            message: 'Unexpected error streaming destination by ID: ${error.toString()}',
            error: error,
          );
        });
  }

  @override
  Future<List<DestinationModel>> searchDestinations(String query) async {
    try {
      print('🔍 Firebase search called with query: "$query"');
      await _ensureAuthenticated();

      if (query.isEmpty) {
        print('🔍 Query is empty, returning empty list');
        return [];
      }

      // Convert query to lowercase for case-insensitive search
      final String lowerQuery = query.toLowerCase().trim();
      print('🔍 Lowercase query: "$lowerQuery"');

      // Get all destinations and filter locally for better search flexibility
      print('🔍 Fetching destinations from Firestore...');
      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .limit(50) // Get more results to filter from
          .get();

      print('🔍 Firestore returned ${querySnapshot.docs.length} documents');

      final List<DestinationModel> allDestinations = await compute(
        _parseDestinationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      print('🔍 Parsed ${allDestinations.length} destinations');
      print('🔍 Available destinations: ${allDestinations.map((d) => d.name).toList()}');

      // Filter destinations that match the query
      final List<DestinationModel> matchingDestinations = allDestinations.where((destination) {
        final String name = destination.name.toLowerCase();
        final String address = destination.location.address.toLowerCase();
        final List<String> categories = (destination.category ?? []).map((c) => c.toLowerCase()).toList();
        
        final bool nameMatch = name.contains(lowerQuery);
        final bool addressMatch = address.contains(lowerQuery);
        final bool categoryMatch = categories.any((category) => category.contains(lowerQuery));
        
        print('🔍 Checking "${destination.name}": name=$nameMatch, address=$addressMatch, category=$categoryMatch');
        
        // Check if query matches name, address, or any category
        return nameMatch || addressMatch || categoryMatch;
      }).toList();

      print('🔍 Found ${matchingDestinations.length} matching destinations');

      // Sort by relevance (exact matches first, then partial matches)
      matchingDestinations.sort((a, b) {
        final String aName = a.name.toLowerCase();
        final String bName = b.name.toLowerCase();
        
        // Exact name match gets highest priority
        if (aName == lowerQuery && bName != lowerQuery) return -1;
        if (bName == lowerQuery && aName != lowerQuery) return 1;
        
        // Then by name starts with query
        if (aName.startsWith(lowerQuery) && !bName.startsWith(lowerQuery)) return -1;
        if (bName.startsWith(lowerQuery) && !aName.startsWith(lowerQuery)) return 1;
        
        // Then by alphabetical order
        return aName.compareTo(bName);
      });

      final results = matchingDestinations.take(10).toList(); // Limit to 10 results
      print('🔍 Returning ${results.length} results: ${results.map((d) => d.name).toList()}');
      return results;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to search destinations: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error searching destinations: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<DestinationModel>> fetchByCategory(String category) async {
    try {
      await _ensureAuthenticated();

      //print('DEBUG: Fetching destinations for category: $category');

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .where('category', arrayContains: category)
          .limit(50)
          .get();

      //print('DEBUG: Firebase returned ${querySnapshot.docs.length} documents for category: $category');
      
      // Let's debug the first few documents to see their category structure
      if (querySnapshot.docs.isNotEmpty) {
        for (int i = 0; i < querySnapshot.docs.length && i < 3; i++) {
          final doc = querySnapshot.docs[i];
          final data = doc.data() as Map<String, dynamic>;
          //print('DEBUG: Document ${i}: ${data['name']} - categories: ${data['category']}');
        }
      } else {
        // Let's see what categories actually exist in the database
        //print('DEBUG: No documents found for category $category, let\'s check what categories exist...');
        final allDocsSnapshot = await _firestore
            .collection('destinations')
            .limit(5)
            .get();
        
        for (int i = 0; i < allDocsSnapshot.docs.length; i++) {
          final doc = allDocsSnapshot.docs[i];
          final data = doc.data() as Map<String, dynamic>;
          //print('DEBUG: Sample document ${i}: ${data['name']} - categories: ${data['category']}');
        }
      }

      final List<DestinationModel> destinations = await compute(
        _parseDestinationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      // Sort by rating in memory to avoid composite index requirement
      destinations.sort((a, b) => b.rating.compareTo(a.rating));

      //print('DEBUG: Parsed ${destinations.length} destinations for category: $category');

      return destinations;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch destinations by category: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching destinations by category: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<DestinationModel>> fetchTodaysTopSpots() async {
    try {
      await _ensureAuthenticated();
      
      //print('DEBUG: Fetching today\'s top spots from Firebase');

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .where('is_top_today', isEqualTo: true)
          .limit(4) // Show 2-4 top spots as requested
          .get();

      final List<DestinationModel> destinations = await compute(
        _parseDestinationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      // Sort by rating in memory to prioritize highest rated spots first
      destinations.sort((a, b) => b.rating.compareTo(a.rating));

      //print('DEBUG: Found ${destinations.length} today\'s top spots');
      return destinations;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch today\'s top spots: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching today\'s top spots: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Stream<List<DestinationModel>> streamTodaysTopSpots() {
    return _firestore
        .collection('destinations')
        .where('is_top_today', isEqualTo: true)
        .limit(4)
        .snapshots()
        .map((snapshot) {
          //print('DEBUG: Firebase stream returned ${snapshot.docs.length} today\'s top spots');
          final destinations = snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return DestinationModel.fromJson({
              ...data,
              'id': doc.id, // Use the actual document ID
            });
          }).toList();
          
          // Sort by rating
          destinations.sort((a, b) => b.rating.compareTo(a.rating));
          
          return destinations;
        })
        .handleError((error) {
          //print('DEBUG: Firebase stream error for today\'s top spots: $error');
          if (error is FirebaseException) {
            throw ServerException(
              message: 'Failed to stream today\'s top spots: ${error.message}',
              error: error,
            );
          }
          throw ServerException(
            message: 'Unexpected error streaming today\'s top spots: ${error.toString()}',
            error: error,
          );
        });
  }

  @override
  Stream<List<DestinationModel>> streamByCategory(String category) {
    return _firestore
        .collection('destinations')
        .where('category', arrayContains: category)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final destinations = snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return DestinationModel.fromJson({
              ...data,
              'id': doc.id, // Use the actual document ID
            });
          }).toList();
          
          // Sort by rating in memory to avoid composite index requirement
          destinations.sort((a, b) => b.rating.compareTo(a.rating));
          
          return destinations;
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw ServerException(
              message: 'Failed to stream destinations by category: ${error.message}',
              error: error,
            );
          }
          throw ServerException(
            message: 'Unexpected error streaming destinations by category: ${error.toString()}',
            error: error,
          );
        });
  }

  @override
  Future<List<DestinationModel>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  }) async {
    try {
      await _ensureAuthenticated();

      print('🔍 Searching for similar destinations with category: "$category"');
      print('🚫 Excluding destination ID: $excludeDestinationId');

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .where('category', arrayContains: category)
          .limit(5)
          .get();

      print('📊 Found ${querySnapshot.docs.length} destinations with category "$category"');

      final List<DestinationModel> destinations = querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final destination = DestinationModel.fromJson({
          ...data,
          'id': doc.id, // Use the actual document ID instead of parsing
        });
        print('📍 Destination: ${destination.name} (ID: ${destination.id}) - Categories: ${destination.category}');
        return destination;
      }).where((destination) => destination.id != excludeDestinationId).toList();

      print('🔍 Available destination IDs: ${destinations.map((d) => d.id).toList()}');

      print('✅ Returning ${destinations.length} similar destinations (after excluding ID $excludeDestinationId)');
      return destinations;
    } on FirebaseException catch (e) {
      print('❌ Firebase error in getSimilarDestinations: ${e.message}');
      throw ServerException(
        message: 'Failed to fetch similar destinations: ${e.message}',
        error: e,
      );
    } catch (e) {
      print('❌ Unexpected error in getSimilarDestinations: $e');
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching similar destinations: ${e.toString()}',
        error: e,
      );
    }
  }

  // Helper method to calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Future<List<String>> fetchAllCategories() async {
    try {
      await _ensureAuthenticated();

      final QuerySnapshot querySnapshot = await _firestore
          .collection('destinations')
          .get();

      final Set<String> categories = <String>{};
      
      for (final doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final List<dynamic>? categoryList = data['category'] as List<dynamic>?;
        
        if (categoryList != null) {
          for (final category in categoryList) {
            if (category is String) {
              categories.add(category);
            }
          }
        }
      }

      return categories.toList()..sort();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch all categories: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching all categories: ${e.toString()}',
        error: e,
      );
    }
  }
}

// Helper function to parse destinations from QuerySnapshot
List<DestinationModel> _parseDestinationsFromQuerySnapshot(
  List<QueryDocumentSnapshot> docs,
) {
  return docs.map((doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DestinationModel.fromJson({
      ...data,
      'id': doc.id, // Use the actual document ID
    });
  }).toList();
} 
