import 'package:spotnav/data/data_sources/local/notification_local_data_source.dart';
import 'package:spotnav/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;

  const NotificationRepositoryImpl({
    required NotificationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notifications = await _localDataSource.getNotifications();
      // Sort by timestamp (newest first)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifications;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _localDataSource.markAsRead(notificationId);
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _localDataSource.markAllAsRead();
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _localDataSource.deleteNotification(notificationId);
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _localDataSource.getUnreadCount();
    } catch (e) {
      return 0;
    }
  }
} 
