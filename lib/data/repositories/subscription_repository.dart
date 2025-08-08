import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_subscription_data_source.dart';
import 'package:spotnav/data/models/subscription_model.dart';
import 'package:spotnav/data/models/user_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionModel>> getAvailableSubscriptions();
  Future<SubscriptionModel?> getUserSubscription(String userId);
  Future<void> updateUserSubscription(String userId, String subscriptionId);
  Future<void> assignFreeSubscription(String userId);
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseSubscriptionDataSource _subscriptionDataSource;

  const SubscriptionRepositoryImpl({
    required FirebaseSubscriptionDataSource subscriptionDataSource,
  }) : _subscriptionDataSource = subscriptionDataSource;

  @override
  Future<List<SubscriptionModel>> getAvailableSubscriptions() async {
    try {
      return await _subscriptionDataSource.getAvailableSubscriptions();
    } catch (e) {
      throw ServerFailure(message: 'Failed to fetch subscriptions: $e');
    }
  }

  @override
  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    try {
      return await _subscriptionDataSource.getUserSubscription(userId);
    } catch (e) {
      throw ServerFailure(message: 'Failed to fetch user subscription: $e');
    }
  }

  @override
  Future<void> updateUserSubscription(String userId, String subscriptionId) async {
    try {
      await _subscriptionDataSource.updateUserSubscription(userId, subscriptionId);
    } catch (e) {
      throw ServerFailure(message: 'Failed to update user subscription: $e');
    }
  }

  @override
  Future<void> assignFreeSubscription(String userId) async {
    try {
      await _subscriptionDataSource.assignFreeSubscription(userId);
    } catch (e) {
      throw ServerFailure(message: 'Failed to assign free subscription: $e');
    }
  }
} 
