import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/data/models/notification_model.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'dart:async';

/// Manages different types of notification triggers
class NotificationTriggerManager {
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  // Trigger conditions
  static const int _maxDailyNotifications = 5;
  static const int _maxWeeklyNotifications = 15;
  static const Duration _minNotificationInterval = Duration(hours: 2);

  NotificationTriggerManager({
    required NotificationService notificationService,
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _notificationService = notificationService,
       _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  // ==================== TRIGGER TYPES ====================

  /// Trigger notification when user views a destination multiple times
  Future<void> triggerInterestBasedNotification(DestinationModel destination) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    // Check if user has viewed this destination multiple times
    final viewCount = await _getDestinationViewCount(userId, destination.id.toString());
    
    if (viewCount >= 3 && await _canSendNotification(userId)) {
      // Create interest-based notification
      final notification = NotificationModel(
        id: 'interest_${DateTime.now().millisecondsSinceEpoch}',
        title: 'You seem interested in ${destination.name}!',
        body: 'Based on your browsing, you might enjoy exploring more ${destination.category?.first ?? 'destination'} locations.',
        type: 'interest_based',
        timestamp: DateTime.now(),
        userId: userId,
        destinationId: destination.id,
        imageUrl: destination.cover,
        deepLink: '/destinations/${destination.id}',
      );

      await _notificationService.createNotification(notification);
      print('Interest-based notification triggered for: ${destination.name}');
    }
  }

  /// Trigger notification based on user location
  Future<void> triggerLocationBasedNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final userLocation = await _getUserLocation(userId);
    if (userLocation != null) {
      final nearbyDestinations = await _getNearbyDestinations(userLocation);
      
      if (nearbyDestinations.isNotEmpty && await _canSendNotification(userId)) {
        final destination = nearbyDestinations.first;
        await _notificationService.triggerNewDestinationNotification(destination);
      }
    }
  }

  /// Trigger notification based on user inactivity
  Future<void> triggerEngagementNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final lastActivity = await _getLastUserActivity(userId);
    final daysSinceLastActivity = DateTime.now().difference(lastActivity).inDays;

    if (daysSinceLastActivity >= 3 && await _canSendNotification(userId)) {
      await _notificationService.triggerPersonalizedTipNotification();
    }
  }

  /// Trigger notification for trending destinations
  Future<void> triggerTrendingNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final trendingDestinations = await _getTrendingDestinations();
    
    if (trendingDestinations.isNotEmpty && await _canSendNotification(userId)) {
      final destination = trendingDestinations.first;
      await _notificationService.triggerNewDestinationNotification(destination);
    }
  }

  /// Trigger notification for seasonal recommendations
  Future<void> triggerSeasonalNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final currentSeason = _getCurrentSeason();
    final seasonalDestinations = await _getSeasonalDestinations(currentSeason);
    
    if (seasonalDestinations.isNotEmpty && await _canSendNotification(userId)) {
      final destination = seasonalDestinations.first;
      await _notificationService.triggerNewDestinationNotification(destination);
    }
  }

  /// Trigger notification for user preferences updates
  Future<void> triggerPreferenceBasedNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final userPreferences = await _getUserPreferences(userId);
    final matchingDestinations = await _getMatchingDestinations(userPreferences);
    
    if (matchingDestinations.isNotEmpty && await _canSendNotification(userId)) {
      final destination = matchingDestinations.first;
      await _notificationService.triggerNewDestinationNotification(destination);
    }
  }

  // ==================== TIMING LOGIC ====================

  /// Check if we can send a notification to this user
  Future<bool> _canSendNotification(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    // Check daily limit
    final todayNotifications = await _getNotificationCount(userId, startOfDay);
    if (todayNotifications >= _maxDailyNotifications) return false;

    // Check weekly limit
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekNotifications = await _getNotificationCount(userId, startOfWeek);
    if (weekNotifications >= _maxWeeklyNotifications) return false;

    // Check minimum interval
    final lastNotification = await _getLastNotificationTime(userId);
    if (lastNotification != null) {
      final timeSinceLastNotification = DateTime.now().difference(lastNotification);
      if (timeSinceLastNotification < _minNotificationInterval) return false;
    }

    // Check user preferences
    final userSettings = await _getUserNotificationSettings(userId);
    if (userSettings['notificationsEnabled'] == false) return false;

    return true;
  }

  /// Get optimal notification time for user
  Future<DateTime> _getOptimalNotificationTime(String userId) async {
    final userSettings = await _getUserNotificationSettings(userId);
    final preferredTime = userSettings['preferredTime'] ?? '09:00';
    
    final timeParts = preferredTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If preferred time has passed today, schedule for tomorrow
    if (today.isBefore(now)) {
      return today.add(const Duration(days: 1));
    }
    
    return today;
  }

  // ==================== HELPER METHODS ====================

  /// Get destination view count for user
  Future<int> _getDestinationViewCount(String userId, String destinationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_activity')
          .where('user_id', isEqualTo: userId)
          .where('destination_id', isEqualTo: destinationId)
          .where('action', isEqualTo: 'view')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get user's current location
  Future<Map<String, double>?> _getUserLocation(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final location = data['current_location'] as Map<String, dynamic>?;
        
        if (location != null) {
          return {
            'latitude': location['latitude'] as double,
            'longitude': location['longitude'] as double,
          };
        }
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
    return null;
  }

  /// Get destinations near user location
  Future<List<DestinationModel>> _getNearbyDestinations(Map<String, double> location) async {
    try {
      // This would use geospatial queries in a real implementation
      // For now, we'll get all destinations and filter by distance
      final querySnapshot = await _firestore
          .collection('destinations')
          .limit(10)
          .get();

      final destinations = querySnapshot.docs.map((doc) {
        return DestinationModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();

      // Filter by approximate distance (simplified)
      return destinations.take(3).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get trending destinations
  Future<List<DestinationModel>> _getTrendingDestinations() async {
    try {
      final querySnapshot = await _firestore
          .collection('destinations')
          .where('is_top_today', isEqualTo: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        return DestinationModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get seasonal destinations
  Future<List<DestinationModel>> _getSeasonalDestinations(String season) async {
    try {
      final querySnapshot = await _firestore
          .collection('destinations')
          .where('season', isEqualTo: season)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        return DestinationModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get current season
  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  /// Get user preferences
  Future<Map<String, dynamic>> _getUserPreferences(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'interests': List<String>.from(data['interests'] ?? []),
          'preferredCategories': List<String>.from(data['preferred_categories'] ?? []),
          'budget': data['budget'] ?? 'medium',
          'travelStyle': data['travel_style'] ?? 'adventure',
        };
      }
    } catch (e) {
      print('Error getting user preferences: $e');
    }
    return {'interests': [], 'preferredCategories': [], 'budget': 'medium', 'travelStyle': 'adventure'};
  }

  /// Get destinations matching user preferences
  Future<List<DestinationModel>> _getMatchingDestinations(Map<String, dynamic> preferences) async {
    try {
      final categories = preferences['preferredCategories'] as List<String>;
      if (categories.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('destinations')
          .where('category', arrayContainsAny: categories)
          .orderBy('rating', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        return DestinationModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get notification count for time period
  Future<int> _getNotificationCount(String userId, DateTime startTime) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startTime)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get last notification time
  Future<DateTime?> _getLastNotificationTime(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as Timestamp;
        return timestamp.toDate();
      }
    } catch (e) {
      print('Error getting last notification time: $e');
    }
    return null;
  }

  /// Get last user activity time
  Future<DateTime> _getLastUserActivity(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_activity')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as Timestamp;
        return timestamp.toDate();
      }
    } catch (e) {
      print('Error getting last user activity: $e');
    }
    return DateTime.now().subtract(const Duration(days: 30)); // Default to 30 days ago
  }

  /// Get user notification settings
  Future<Map<String, dynamic>> _getUserNotificationSettings(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'notificationsEnabled': data['notifications_enabled'] ?? true,
          'pushEnabled': data['push_notifications'] ?? true,
          'emailEnabled': data['email_notifications'] ?? false,
          'preferredTime': data['notification_time'] ?? '09:00',
          'dailyLimit': data['daily_notification_limit'] ?? _maxDailyNotifications,
          'weeklyLimit': data['weekly_notification_limit'] ?? _maxWeeklyNotifications,
        };
      }
    } catch (e) {
      print('Error getting user notification settings: $e');
    }
    return {
      'notificationsEnabled': true,
      'pushEnabled': true,
      'emailEnabled': false,
      'preferredTime': '09:00',
      'dailyLimit': _maxDailyNotifications,
      'weeklyLimit': _maxWeeklyNotifications,
    };
  }

  // ==================== PUBLIC API ====================

  /// Initialize trigger manager
  Future<void> initialize() async {
    // Start monitoring for trigger conditions
    await _startTriggerMonitoring();
  }

  /// Start monitoring for trigger conditions
  Future<void> _startTriggerMonitoring() async {
    // This would set up various monitoring streams
    // For now, we'll create a placeholder
    print('Notification trigger monitoring started');
  }

  /// Manually trigger a notification (for testing)
  Future<void> triggerTestNotification() async {
    await _notificationService.triggerTestNotification();
  }
} 