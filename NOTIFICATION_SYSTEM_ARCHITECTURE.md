# Advanced Notification System Architecture

## Overview

This document describes the comprehensive notification system for the SpotNav Flutter app. The system provides intelligent, context-aware notifications that enhance user engagement through smart triggers, timing logic, and real-time monitoring.

## 🏗️ System Architecture

### Core Components

1. **NotificationService** - Main service for notification generation and management
2. **NotificationTriggerManager** - Handles different types of notification triggers
3. **FirebaseNotificationDataSource** - Data layer for Firebase operations
4. **NotificationBloc** - State management for UI
5. **NotificationPanel** - UI component for displaying notifications

## 📱 Smart Notification Generation

### Types of Notifications

#### 1. **New Destination Notifications**
- **Trigger**: When new destinations are added to the database
- **Logic**: Checks user interests and destination rating
- **Condition**: Only sent if user has shown interest in the category OR destination rating ≥ 4.0

```dart
Future<void> triggerNewDestinationNotification(DestinationModel destination) async {
  final userInterests = await _getUserInterests(userId);
  final isRelevant = userInterests.contains(destination.category.first) || 
                    destination.rating >= 4.0;
  
  if (isRelevant) {
    // Create and send notification
  }
}
```

#### 2. **Virtual Tour Notifications**
- **Trigger**: When destinations have virtual tour capability
- **Logic**: Checks if destination has `virtualTour = true`
- **Condition**: Only for destinations with VR capabilities

#### 3. **Personalized Tip Notifications**
- **Trigger**: Based on user behavior analysis
- **Logic**: Analyzes user activity patterns and preferences
- **Condition**: Generated weekly or based on engagement patterns

#### 4. **Top Today Notifications**
- **Trigger**: Daily at 9 AM (configurable)
- **Logic**: Fetches destinations with `is_top_today = true`
- **Condition**: Only sent once per day

## ⏰ Intelligent Timing Logic

### Scheduling System

#### Daily Notifications
```dart
void _scheduleDailyNotification() {
  final now = DateTime.now();
  final nextNotification = DateTime(now.year, now.month, now.day, 9, 0);
  final delay = nextNotification.isBefore(now) 
      ? nextNotification.add(const Duration(days: 1)).difference(now)
      : nextNotification.difference(now);

  _dailyNotificationTimer = Timer(delay, () {
    triggerTopTodayNotification();
    _scheduleDailyNotification(); // Schedule next day
  });
}
```

#### Weekly Notifications
```dart
void _scheduleWeeklyNotification() {
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  final nextNotification = DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 10, 0);
  final delay = nextNotification.difference(now);

  _weeklyNotificationTimer = Timer(delay, () {
    triggerPersonalizedTipNotification();
    _scheduleWeeklyNotification(); // Schedule next week
  });
}
```

### Notification Limits

- **Daily Limit**: 5 notifications per day
- **Weekly Limit**: 15 notifications per week
- **Minimum Interval**: 2 hours between notifications
- **User Preferences**: Respects user notification settings

## 🔔 Real-time Push Notification Logic

### Push Notification Flow

1. **Notification Creation**: Service creates notification in Firebase
2. **User Settings Check**: Verifies if user has push notifications enabled
3. **FCM Integration**: Sends to Firebase Cloud Messaging
4. **Device Delivery**: Delivered to user's device

```dart
Future<void> _sendPushNotification(NotificationModel notification) async {
  final userSettings = await _getUserNotificationSettings(notification.userId!);
  
  if (userSettings['pushEnabled'] == true) {
    await _sendToFCM(notification);
  }
}
```

## 🎯 Smart Trigger System

### Trigger Types

#### 1. **Interest-Based Triggers**
- **Condition**: User views destination 3+ times
- **Action**: Sends virtual tour notification
- **Logic**: Tracks user activity in `user_activity` collection

#### 2. **Location-Based Triggers**
- **Condition**: User is near interesting destinations
- **Action**: Sends nearby destination notifications
- **Logic**: Uses geospatial queries (simplified implementation)

#### 3. **Engagement Triggers**
- **Condition**: User inactive for 3+ days
- **Action**: Sends personalized tip to re-engage
- **Logic**: Analyzes last activity timestamp

#### 4. **Trending Triggers**
- **Condition**: New trending destinations available
- **Action**: Sends trending destination notifications
- **Logic**: Monitors `is_top_today` destinations

#### 5. **Seasonal Triggers**
- **Condition**: Seasonal destinations available
- **Action**: Sends seasonal recommendation notifications
- **Logic**: Matches current season with destination seasons

#### 6. **Preference-Based Triggers**
- **Condition**: Destinations match user preferences
- **Action**: Sends personalized destination notifications
- **Logic**: Analyzes user preferences and interests

## 📊 User Behavior Analysis

### Data Collection

The system collects user activity data in the `user_activity` collection:

```json
{
  "user_id": "user123",
  "destination_id": 456,
  "action": "view",
  "category": "beach",
  "destination_name": "Santorini Sunset",
  "timestamp": "2025-01-27T14:00:00Z"
}
```

### Behavior Analysis

```dart
Future<Map<String, dynamic>> _analyzeUserBehavior(String userId) async {
  final activities = await _getUserActivities(userId);
  
  // Analyze patterns
  final categories = <String, int>{};
  final destinations = <String, int>{};
  
  for (final activity in activities) {
    final category = activity['category'] as String?;
    final destination = activity['destination_name'] as String?;
    
    if (category != null) {
      categories[category] = (categories[category] ?? 0) + 1;
    }
    if (destination != null) {
      destinations[destination] = (destinations[destination] ?? 0) + 1;
    }
  }

  return {
    'preferredCategory': categories.entries.reduce((a, b) => a.value > b.value ? a : b).key,
    'favoriteDestinations': destinations.keys.take(3).toList(),
    'activityCount': activities.length,
    'lastActivity': activities.isNotEmpty ? activities.first['timestamp'] : null,
  };
}
```

## 🔄 Real-time Monitoring

### Destination Monitoring
```dart
Future<void> _startDestinationMonitoring() async {
  _destinationStreamSubscription = _firestore
      .collection('destinations')
      .snapshots()
      .listen((snapshot) {
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final destination = DestinationModel.fromJson({
          ...change.doc.data() as Map<String, dynamic>,
          'id': change.doc.id,
        });
        triggerNewDestinationNotification(destination);
      }
    }
  });
}
```

### User Activity Monitoring
```dart
Future<void> _startUserActivityMonitoring() async {
  _userActivityStreamSubscription = _firestore
      .collection('user_activity')
      .where('user_id', isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
    _analyzeAndTriggerContextualNotifications(snapshot.docs);
  });
}
```

## 🎛️ User Preferences Management

### Notification Settings

Users can configure:
- **Push Notifications**: Enable/disable push notifications
- **Email Notifications**: Enable/disable email notifications
- **Preferred Time**: Set preferred notification time (default: 9:00 AM)
- **Daily Limit**: Customize daily notification limit
- **Weekly Limit**: Customize weekly notification limit

```dart
Future<void> updateNotificationPreferences({
  required bool pushEnabled,
  required bool emailEnabled,
  String? preferredTime,
}) async {
  await _firestore.collection('users').doc(userId).update({
    'push_notifications': pushEnabled,
    'email_notifications': emailEnabled,
    if (preferredTime != null) 'notification_time': preferredTime,
  });
}
```

## 🧪 Testing System

### Test Page Features

The `NotificationTestPage` provides comprehensive testing capabilities:

1. **Basic Notifications**
   - Test notification
   - New destination notification
   - Virtual tour notification
   - Personalized tip notification
   - Top today notification

2. **Smart Triggers**
   - Interest-based trigger
   - Location-based trigger
   - Engagement trigger
   - Trending trigger
   - Seasonal trigger
   - Preference-based trigger

3. **System Tests**
   - Initialize services
   - Check notification limits
   - Update notification preferences

## 📈 Performance Optimizations

### 1. **In-Memory Sorting**
- Performs sorting in memory instead of complex Firestore queries
- Reduces database load and improves performance

### 2. **Batch Operations**
- Uses Firestore batch operations for multiple updates
- Improves efficiency for bulk operations

### 3. **Stream Management**
- Properly disposes of streams to prevent memory leaks
- Manages subscription lifecycles

### 4. **Error Handling**
- Comprehensive error handling with fallbacks
- Graceful degradation when services are unavailable

## 🔧 Configuration

### Environment Variables

```dart
// Notification limits
static const int _maxDailyNotifications = 5;
static const int _maxWeeklyNotifications = 15;
static const Duration _minNotificationInterval = Duration(hours: 2);

// Default notification time
static const String _defaultNotificationTime = '09:00';
```

### Firebase Collections

1. **notifications** - Stores all notifications
2. **user_activity** - Tracks user behavior
3. **users** - User preferences and settings
4. **destinations** - Destination data

## 🚀 Future Enhancements

### Planned Features

1. **Advanced Analytics**
   - Notification engagement tracking
   - A/B testing for notification content
   - User behavior prediction

2. **Machine Learning Integration**
   - Personalized content recommendations
   - Optimal timing prediction
   - Content optimization

3. **Rich Notifications**
   - Image attachments
   - Action buttons
   - Interactive notifications

4. **Geofencing**
   - Location-based triggers
   - Proximity notifications
   - Travel route suggestions

5. **Social Features**
   - Friend activity notifications
   - Shared destination alerts
   - Group travel coordination

## 📋 Implementation Checklist

- [x] Basic notification system
- [x] Firebase integration
- [x] Real-time monitoring
- [x] Smart triggers
- [x] Timing logic
- [x] User preferences
- [x] Testing framework
- [x] Performance optimizations
- [ ] Push notification integration
- [ ] Analytics tracking
- [ ] A/B testing framework
- [ ] Machine learning integration

## 🔍 Debugging

### Common Issues

1. **Notifications not appearing**
   - Check user authentication
   - Verify Firebase permissions
   - Check notification limits

2. **Real-time updates not working**
   - Verify stream subscriptions
   - Check network connectivity
   - Review Firebase rules

3. **Performance issues**
   - Monitor stream disposal
   - Check memory usage
   - Review query optimization

### Debug Tools

- Use `NotificationTestPage` for testing
- Check Firebase console for data
- Monitor app logs for errors
- Use Flutter Inspector for UI debugging

## 📚 API Reference

### NotificationService Methods

- `initialize()` - Initialize the notification service
- `dispose()` - Clean up resources
- `triggerNewDestinationNotification()` - Trigger new destination notification
- `triggerVirtualTourNotification()` - Trigger virtual tour notification
- `triggerPersonalizedTipNotification()` - Trigger personalized tip
- `triggerTopTodayNotification()` - Trigger top today notification
- `updateNotificationPreferences()` - Update user preferences

### NotificationTriggerManager Methods

- `triggerInterestBasedNotification()` - Interest-based trigger
- `triggerLocationBasedNotification()` - Location-based trigger
- `triggerEngagementNotification()` - Engagement trigger
- `triggerTrendingNotification()` - Trending trigger
- `triggerSeasonalNotification()` - Seasonal trigger
- `triggerPreferenceBasedNotification()` - Preference-based trigger

This comprehensive notification system provides intelligent, context-aware notifications that enhance user engagement while respecting user preferences and system limits. 