import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:spotnav/data/models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _notificationsPath = 'assets/data/notifications.json';
  static List<NotificationModel> _notifications = [];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    if (_notifications.isEmpty) {
      await _loadNotifications();
    }
    return _notifications;
  }

  Future<void> _loadNotifications() async {
    try {
      final String jsonString = await rootBundle.loadString(_notificationsPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      _notifications = jsonList
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If loading fails, return empty list
      _notifications = [];
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((notification) => notification.id == notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    if (_notifications.isEmpty) {
      await _loadNotifications();
    }
    return _notifications.where((notification) => !notification.isRead).length;
  }
} 
