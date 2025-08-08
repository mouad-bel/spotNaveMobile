import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/subscription_model.dart';

abstract class FirebaseSubscriptionDataSource {
  Future<List<SubscriptionModel>> getAvailableSubscriptions();
  Future<SubscriptionModel?> getUserSubscription(String userId);
  Future<void> updateUserSubscription(String userId, String subscriptionId);
  Future<void> assignFreeSubscription(String userId);
}

class FirebaseSubscriptionDataSourceImpl implements FirebaseSubscriptionDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  const FirebaseSubscriptionDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  Future<void> _ensureAuthenticated() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw const UnauthenticatedException(
        message: 'Authentication required to access subscriptions',
      );
    }
  }

  @override
  Future<List<SubscriptionModel>> getAvailableSubscriptions() async {
    try {
      await _ensureAuthenticated();

      final QuerySnapshot querySnapshot = await _firestore
          .collection('subscriptions')
          .where('is_active', isEqualTo: true)
          .orderBy('price')
          .get();

      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SubscriptionModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch subscriptions: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching subscriptions: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    try {
      await _ensureAuthenticated();

      // Get user document
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      final String? subscriptionId = userData['subscription_id'];

      if (subscriptionId == null) {
        return null;
      }

      // Get subscription document
      final DocumentSnapshot subscriptionDoc = await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .get();

      if (!subscriptionDoc.exists) {
        return null;
      }

      final Map<String, dynamic> subscriptionData = subscriptionDoc.data() as Map<String, dynamic>;
      subscriptionData['id'] = subscriptionDoc.id;
      return SubscriptionModel.fromJson(subscriptionData);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch user subscription: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching user subscription: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> updateUserSubscription(String userId, String subscriptionId) async {
    try {
      await _ensureAuthenticated();

      // Verify subscription exists
      final DocumentSnapshot subscriptionDoc = await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .get();

      if (!subscriptionDoc.exists) {
        throw const NotFoundException(
          message: 'Subscription not found',
        );
      }

      // Update user's subscription
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'subscription_id': subscriptionId,
        'updated_at': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update user subscription: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error updating user subscription: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> assignFreeSubscription(String userId) async {
    try {
      await _ensureAuthenticated();

      // Find the free subscription
      final QuerySnapshot querySnapshot = await _firestore
          .collection('subscriptions')
          .where('type', isEqualTo: 'free')
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw const ServerException(
          message: 'Free subscription not found',
        );
      }

      final String freeSubscriptionId = querySnapshot.docs.first.id;

      // Update user's subscription to free
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'subscription_id': freeSubscriptionId,
        'updated_at': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to assign free subscription: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error assigning free subscription: ${e.toString()}',
        error: e,
      );
    }
  }
} 
