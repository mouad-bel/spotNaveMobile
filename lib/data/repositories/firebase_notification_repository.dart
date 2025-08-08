import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_notification_data_source.dart';
import 'package:spotnav/data/models/notification_model.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async';

abstract class FirebaseNotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> fetchNotifications(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead(String userId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, void>> deleteAllNotifications(String userId);
  Future<Either<Failure, NotificationModel>> createNotification(NotificationModel notification);
  Stream<Either<Failure, List<NotificationModel>>> streamNotifications(String userId);
  Future<Either<Failure, int>> getUnreadCount(String userId);
}

class FirebaseNotificationRepositoryImpl implements FirebaseNotificationRepository {
  final FirebaseNotificationDataSource _notificationDataSource;
  final NetworkInfo _networkInfo;

  const FirebaseNotificationRepositoryImpl({
    required FirebaseNotificationDataSource notificationDataSource,
    required NetworkInfo networkInfo,
  }) : _notificationDataSource = notificationDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationModel>>> fetchNotifications(String userId) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final notifications = await _notificationDataSource.fetchNotifications(userId);
      return right(notifications);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationModel>>> streamNotifications(String userId) {
    return _notificationDataSource.streamNotifications(userId).map(
      (notifications) => right<Failure, List<NotificationModel>>(notifications),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    }).cast<Either<Failure, List<NotificationModel>>>();
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _notificationDataSource.markAsRead(notificationId);
      return right(null);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _notificationDataSource.markAllAsRead(userId);
      return right(null);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _notificationDataSource.deleteNotification(notificationId);
      return right(null);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications(String userId) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _notificationDataSource.deleteAllNotifications(userId);
      return right(null);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> createNotification(NotificationModel notification) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      print('🔔 Repository: Creating notification for user ${notification.userId}');
      print('🔔 Repository: Notification title: ${notification.title}');
      print('🔔 Repository: Notification type: ${notification.type}');
      
      final createdNotification = await _notificationDataSource.createNotification(notification);
      
      print('🔔 Repository: Successfully created notification with ID: ${createdNotification.id}');
      return right(createdNotification);
    } on UnauthenticatedException catch (e) {
      print('🔔 Repository: Authentication error: ${e.message}');
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      print('🔔 Repository: Server error: ${e.message}');
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      print('🔔 Repository: Network error: ${e.message}');
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      print('🔔 Repository: Unexpected error: $e');
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final count = await _notificationDataSource.getUnreadCount(userId);
      return right(count);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}