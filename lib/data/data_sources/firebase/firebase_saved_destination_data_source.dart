import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseSavedDestinationDataSource {
  Future<void> save(SavedDestinationModel destination);
  Future<void> remove(String destinationId);
  Future<List<SavedDestinationModel>> fetchSaved();
  Future<bool> isSaved(String destinationId);
}

class FirebaseSavedDestinationDataSourceImpl implements FirebaseSavedDestinationDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  const FirebaseSavedDestinationDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  Future<String> _getCurrentUserId() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw const UnauthenticatedException(
        message: 'Authentication required to manage saved destinations',
      );
    }
    return currentUser.uid;
  }

  @override
  Future<void> save(SavedDestinationModel destination) async {
    try {
      final String userId = await _getCurrentUserId();

      // Check if already saved
      final bool alreadySaved = await isSaved(destination.id);
      if (alreadySaved) {
        return; // Already saved, no need to add again
      }

      // Add to user's saved destinations
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedDestinations')
          .doc(destination.id.toString())
          .set(destination.toJson());
    } on FirebaseException catch (e) {
      throw CacheException(
        message: 'Failed to save destination: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is CacheException) {
        rethrow;
      }
      throw CacheException(
        message: 'Unexpected error saving destination: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> remove(String destinationId) async {
    try {
      final String userId = await _getCurrentUserId();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedDestinations')
          .doc(destinationId)
          .delete();
    } on FirebaseException catch (e) {
      throw CacheException(
        message: 'Failed to remove destination: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is CacheException) {
        rethrow;
      }
      throw CacheException(
        message: 'Unexpected error removing destination: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<List<SavedDestinationModel>> fetchSaved() async {
    try {
      final String userId = await _getCurrentUserId();

      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedDestinations')
          .get();

      final List<SavedDestinationModel> savedDestinations = await compute(
        _parseSavedDestinationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      return savedDestinations;
    } on FirebaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch saved destinations: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is CacheException) {
        rethrow;
      }
      throw CacheException(
        message: 'Unexpected error fetching saved destinations: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<bool> isSaved(String destinationId) async {
    try {
      final String userId = await _getCurrentUserId();

      final DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedDestinations')
          .doc(destinationId)
          .get();

      return docSnapshot.exists;
    } on FirebaseException catch (e) {
      throw CacheException(
        message: 'Failed to check if destination is saved: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is CacheException) {
        rethrow;
      }
      throw CacheException(
        message: 'Unexpected error checking if destination is saved: ${e.toString()}',
        error: e,
      );
    }
  }
}

// Helper function to parse saved destinations from QuerySnapshot
List<SavedDestinationModel> _parseSavedDestinationsFromQuerySnapshot(
  List<QueryDocumentSnapshot> docs,
) {
  return docs.map((doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavedDestinationModel.fromJson(data);
  }).toList();
} 
