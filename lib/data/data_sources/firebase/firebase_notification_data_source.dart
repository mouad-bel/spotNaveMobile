import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/notification_model.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseNotificationDataSource {
  Future<List<NotificationModel>> fetchNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications(String userId);
  Future<NotificationModel> createNotification(NotificationModel notification);
  Stream<List<NotificationModel>> streamNotifications(String userId);
  Future<int> getUnreadCount(String userId);
}

class FirebaseNotificationDataSourceImpl implements FirebaseNotificationDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  const FirebaseNotificationDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  Future<void> _ensureAuthenticated() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw const UnauthenticatedException(
        message: 'Authentication required to access notifications',
      );
    }
  }

  @override
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      await _ensureAuthenticated();

      // Simplified query without orderBy to avoid composite index requirement
      final QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .limit(50)
          .get();

      final List<NotificationModel> notifications = await compute(
        _parseNotificationsFromQuerySnapshot,
        querySnapshot.docs,
      );

      // Sort in memory by timestamp (newest first)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return notifications;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch notifications: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching notifications: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    // Simplified query without orderBy to avoid composite index requirement
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Firebase returned ${snapshot.docs.length} notifications for user $userId');
          final notifications = snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final notification = NotificationModel.fromJson({...data, 'id': doc.id});
            print('DEBUG: Notification ${notification.id}: ${notification.title} - ${notification.type}');
            return notification;
          }).toList();
          
          // Sort in memory by timestamp (newest first)
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          print('DEBUG: Returning ${notifications.length} sorted notifications');
          return notifications;
        })
        .handleError((error) {
          //print('DEBUG: Firebase notification error: $error');
          if (error is FirebaseException) {
            throw ServerException(
              message: 'Failed to stream notifications: ${error.message}',
              error: error,
            );
          }
          throw ServerException(
            message: 'Unexpected error streaming notifications: ${error.toString()}',
            error: error,
          );
        });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _ensureAuthenticated();

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to mark notification as read: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error marking notification as read: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _ensureAuthenticated();

      final QuerySnapshot unreadNotifications = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      // Batch update all unread notifications
      final WriteBatch batch = _firestore.batch();
      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'is_read': true});
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to mark all notifications as read: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error marking all notifications as read: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _ensureAuthenticated();

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to delete notification: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error deleting notification: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      await _ensureAuthenticated();

      // Get all notifications for the user
      final QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .get();

      // Delete all notifications in a batch
      final WriteBatch batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('🔔 DataSource: Successfully deleted all notifications for user: $userId');
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to delete all notifications: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error deleting all notifications: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<NotificationModel> createNotification(NotificationModel notification) async {
    try {
      await _ensureAuthenticated();

      print('🔔 DataSource: Creating notification in Firebase');
      print('🔔 DataSource: User ID: ${notification.userId}');
      print('🔔 DataSource: Title: ${notification.title}');
      print('🔔 DataSource: Type: ${notification.type}');
      
      final DocumentReference docRef = await _firestore
          .collection('notifications')
          .add(notification.toFirestore());

      print('🔔 DataSource: Successfully created notification with Firebase ID: ${docRef.id}');
      
      // Return the notification with the generated ID
      return notification.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      print('🔔 DataSource: Firebase error: ${e.message}');
      throw ServerException(
        message: 'Failed to create notification: ${e.message}',
        error: e,
      );
    } catch (e) {
      print('🔔 DataSource: Unexpected error: $e');
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error creating notification: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      await _ensureAuthenticated();

      final AggregateQuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get unread count: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (e is UnauthenticatedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error getting unread count: ${e.toString()}',
        error: e,
      );
    }
  }
}

// Helper function to parse notifications from QuerySnapshot
List<NotificationModel> _parseNotificationsFromQuerySnapshot(
  List<QueryDocumentSnapshot> docs,
) {
  return docs.map((doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson({...data, 'id': doc.id});
  }).toList();
}