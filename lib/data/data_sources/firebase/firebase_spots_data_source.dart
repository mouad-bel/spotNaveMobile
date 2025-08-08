import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/spot_model.dart';

abstract class FirebaseSpotsDataSource {
  Future<List<SpotModel>> fetchPopular();
  Future<List<SpotModel>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Future<SpotModel> findById(String id);
  Future<List<SpotModel>> searchSpots(String query);
  Future<List<SpotModel>> fetchFeatured();
  Future<List<SpotModel>> fetchByCategory(String category);
}

class FirebaseSpotsDataSourceImpl implements FirebaseSpotsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  const FirebaseSpotsDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  @override
  Future<List<SpotModel>> fetchPopular() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('spots')
          .where('isActive', isEqualTo: true)
          .orderBy('popularScore', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return SpotModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch popular spots: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<SpotModel>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      // Create a bounding box for the search
      final double latDelta = radius / 111.0; // Approximate km to degrees
      final double lngDelta = radius / (111.0 * cos(latitude * pi / 180));

      final QuerySnapshot querySnapshot = await _firestore
          .collection('spots')
          .where('isActive', isEqualTo: true)
          .where('location', isGreaterThan: GeoPoint(
            latitude - latDelta,
            longitude - lngDelta,
          ))
          .where('location', isLessThan: GeoPoint(
            latitude + latDelta,
            longitude + lngDelta,
          ))
          .get();

      final List<SpotModel> spots = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SpotModel.fromJson(data);
      }).toList();

      // Filter by actual distance (more precise than bounding box)
      return spots.where((spot) {
        if (spot.location == null) return false;
        final distance = _calculateDistance(
          latitude,
          longitude,
          spot.location!.latitude,
          spot.location!.longitude,
        );
        return distance <= radius;
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch nearby spots: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<SpotModel> findById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('spots')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw const NotFoundException(
          message: 'Spot not found',
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return SpotModel.fromJson(data);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to fetch spot: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<SpotModel>> searchSpots(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll search by name
      final QuerySnapshot querySnapshot = await _firestore
          .collection('spots')
          .where('isActive', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SpotModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to search spots: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<SpotModel>> fetchFeatured() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('spots')
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('popularScore', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SpotModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch featured spots: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<SpotModel>> fetchByCategory(String category) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('spots')
          .where('isActive', isEqualTo: true)
          .where('category', arrayContains: category)
          .orderBy('popularScore', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SpotModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch spots by category: ${e.toString()}',
        error: e,
      );
    }
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
} 
