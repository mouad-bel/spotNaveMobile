import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/data/models/notification_model.dart';
import 'package:spotnav/data/repositories/firebase_notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:spotnav/data/models/destination_model.dart';
import 'dart:async';

class NotificationService {
  final FirebaseNotificationRepository _repository;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  
  // Notification triggers and timers
  Timer? _dailyNotificationTimer;
  Timer? _weeklyNotificationTimer;
  StreamSubscription? _destinationStreamSubscription;
  StreamSubscription? _userActivityStreamSubscription;

  NotificationService({
    required FirebaseNotificationRepository repository,
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _repository = repository,
       _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  /// Initialize notification service and start monitoring
  Future<void> initialize() async {
    // Temporarily disable automatic monitoring to prevent infinite loops
    // await _startNotificationMonitoring();
    // await _schedulePeriodicNotifications();
    // await _startDestinationMonitoring();
    print('NotificationService initialized (monitoring disabled for now)');
  }

  /// Dispose of all timers and streams
  void dispose() {
    _dailyNotificationTimer?.cancel();
    _weeklyNotificationTimer?.cancel();
    _destinationStreamSubscription?.cancel();
    _userActivityStreamSubscription?.cancel();
  }

  // ==================== SMART NOTIFICATION GENERATION ====================

  /// Generate notification when new destination is added
  Future<void> triggerNewDestinationNotification(DestinationModel destination) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    // Check if user has shown interest in this category
    final userInterests = await _getUserInterests(userId);
    final isRelevant = userInterests.contains(destination.category?.first) || 
                      destination.rating >= 4.0;

    if (isRelevant) {
      final notification = NotificationModel(
        id: 'dest_${destination.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Amazing Destination!',
        body: '${destination.name} in ${destination.location} has been added. Rated ${destination.rating}/5!',
        type: 'newSpot',
        timestamp: DateTime.now(),
        userId: userId,
        destinationId: destination.id,
        imageUrl: destination.cover,
        deepLink: '/destinations/${destination.id}',
        metadata: {
          'destinationId': destination.id,
          'destinationName': destination.name,
          'category': destination.category,
          'rating': destination.rating,
          'location': destination.location,
        },
      );

      await _repository.createNotification(notification);
      await _sendPushNotification(notification);
    }
  }

  /// Generate notification for virtual tour availability
  Future<void> triggerVirtualTourNotification(DestinationModel destination) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null || !destination.virtualTour) return;

    final notification = NotificationModel(
      id: 'vr_${destination.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Virtual Reality Tour Available!',
      body: 'Experience ${destination.name} in immersive VR. Tap to start your virtual journey!',
      type: 'virtualTour',
      timestamp: DateTime.now(),
      userId: userId,
      destinationId: destination.id,
      imageUrl: destination.cover,
      deepLink: '/destinations/${destination.id}?vr=true',
      metadata: {
        'destinationId': destination.id,
        'destinationName': destination.name,
        'vrEnabled': true,
      },
    );

    await _repository.createNotification(notification);
    await _sendPushNotification(notification);
  }

  /// Generate personalized tip based on user behavior
  Future<void> triggerPersonalizedTipNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final userBehavior = await _analyzeUserBehavior(userId);
    final tip = await _generatePersonalizedTip(userBehavior);

    final notification = NotificationModel(
      id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Personalized Travel Tip',
      body: tip,
      type: 'personalizedTip',
      timestamp: DateTime.now(),
      userId: userId,
      deepLink: '/tips',
      metadata: {
        'tipType': userBehavior['preferredCategory'],
        'userBehavior': userBehavior,
      },
    );

    await _repository.createNotification(notification);
  }

  /// Generate top today notification
  Future<void> triggerTopTodayNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final topDestinations = await _getTopTodayDestinations();
    if (topDestinations.isNotEmpty) {
      final destination = topDestinations.first;
      
      final notification = NotificationModel(
        id: 'top_${destination.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Today\'s Top Pick!',
        body: '${destination.name} is trending today! Don\'t miss this amazing spot.',
        type: 'topToday',
        timestamp: DateTime.now(),
        userId: userId,
        destinationId: destination.id,
        imageUrl: destination.cover,
        deepLink: '/destinations/${destination.id}',
        metadata: {
          'destinationId': destination.id,
          'destinationName': destination.name,
          'rating': destination.rating,
        },
      );

      await _repository.createNotification(notification);
    }
  }

  /// Generate notification when user profile is updated
  Future<void> triggerProfileUpdateNotification({
    required String updatedField,
    String? oldValue,
    String? newValue,
    String? icon,
  }) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    String title = 'Profile Updated!';
    String body = 'Your profile has been successfully updated.';

    // Customize message based on what was updated
    switch (updatedField.toLowerCase()) {
      case 'name':
        title = 'Name Updated!';
        body = 'Your name has been updated successfully.';
        break;
      case 'email':
        title = 'Email Updated!';
        body = 'Your email address has been updated successfully.';
        break;
      case 'profile_image':
      case 'image':
        title = 'Profile Photo Updated!';
        body = 'Your profile photo has been updated successfully.';
        break;
      case 'phone':
        title = 'Phone Updated!';
        body = 'Your phone number has been updated successfully.';
        break;
      default:
        title = 'Profile Updated!';
        body = 'Your profile information has been updated successfully.';
    }

    final notification = NotificationModel(
      id: 'profile_${updatedField}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: 'profileUpdate',
      timestamp: DateTime.now(),
      userId: userId,
      deepLink: '/account',
      imageUrl: icon, // Use the icon parameter as imageUrl
      metadata: {
        'updatedField': updatedField,
        'oldValue': oldValue,
        'newValue': newValue,
        'updateType': 'profile_modification',
        'isProfileUpdate': true, // Flag to identify profile update notifications
      },
    );

    print('🔔 NotificationService: Creating profile update notification');
    print('🔔 NotificationService: Field: $updatedField');
    print('🔔 NotificationService: Title: $title');
    print('🔔 NotificationService: Body: $body');
    print('🔔 NotificationService: Icon: $icon');

    await _repository.createNotification(notification);
    print('🔔 NotificationService: Profile update notification created successfully');
  }

  /// Batch profile update notifications - creates a single notification for multiple updates
  Future<void> triggerBatchProfileUpdateNotification({
    required List<String> updatedFields,
    String? icon,
  }) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    String title = 'Profile Updated!';
    String body = 'Your profile has been successfully updated.';

    // If multiple fields were updated, create a generic message
    if (updatedFields.length > 1) {
      title = 'Profile Updated!';
      body = 'Multiple profile fields have been updated successfully.';
    } else if (updatedFields.length == 1) {
      // Single field update
      switch (updatedFields.first.toLowerCase()) {
        case 'name':
          title = 'Name Updated!';
          body = 'Your name has been updated successfully.';
          break;
        case 'email':
          title = 'Email Updated!';
          body = 'Your email address has been updated successfully.';
          break;
        case 'profile_image':
        case 'image':
          title = 'Profile Photo Updated!';
          body = 'Your profile photo has been updated successfully.';
          break;
        case 'phone':
          title = 'Phone Updated!';
          body = 'Your phone number has been updated successfully.';
          break;
        default:
          title = 'Profile Updated!';
          body = 'Your profile information has been updated successfully.';
      }
    }

    final notification = NotificationModel(
      id: 'profile_batch_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: 'profileUpdate',
      timestamp: DateTime.now(),
      userId: userId,
      deepLink: '/account',
      imageUrl: icon, // Use the icon parameter as imageUrl
      metadata: {
        'updatedFields': updatedFields,
        'updateType': 'profile_modification',
        'isProfileUpdate': true, // Flag to identify profile update notifications
        'isBatchUpdate': true, // Flag to identify batch updates
      },
    );

    print('🔔 NotificationService: Creating batch profile update notification');
    print('🔔 NotificationService: Updated fields: $updatedFields');
    print('🔔 NotificationService: Title: $title');
    print('🔔 NotificationService: Body: $body');
    print('🔔 NotificationService: Icon: $icon');

    await _repository.createNotification(notification);
    print('🔔 NotificationService: Batch profile update notification created successfully');
  }

  // ==================== TIMING LOGIC ====================

  /// Schedule periodic notifications
  Future<void> _schedulePeriodicNotifications() async {
    // Daily notification at 9 AM
    _scheduleDailyNotification();
    
    // Weekly personalized tips
    _scheduleWeeklyNotification();
  }

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

  // ==================== REAL-TIME MONITORING ====================

  /// Start monitoring for real-time triggers
  Future<void> _startNotificationMonitoring() async {
    // Monitor user activity for contextual notifications
    await _startUserActivityMonitoring();
    
    // Monitor app usage patterns
    await _startAppUsageMonitoring();
  }

  /// Monitor destination changes
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

  /// Monitor user activity for personalized notifications
  Future<void> _startUserActivityMonitoring() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    _userActivityStreamSubscription = _firestore
        .collection('user_activity')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      // Analyze user behavior and trigger contextual notifications
      _analyzeAndTriggerContextualNotifications(snapshot.docs);
    });
  }

  // ==================== PUSH NOTIFICATION LOGIC ====================

  /// Send push notification (Firebase Cloud Messaging)
  Future<void> _sendPushNotification(NotificationModel notification) async {
    try {
      // This would integrate with Firebase Cloud Messaging
      // For now, we'll simulate the push notification logic
      
      // Check if user has push notifications enabled
      final userSettings = await _getUserNotificationSettings(notification.userId!);
      
      if (userSettings['pushEnabled'] == true) {
        // Send to FCM
        await _sendToFCM(notification);
      }
    } catch (e) {
      // Handle push notification errors
      print('Push notification error: $e');
    }
  }

  /// Send notification to Firebase Cloud Messaging
  Future<void> _sendToFCM(NotificationModel notification) async {
    // This would be implemented with Firebase Cloud Messaging
    // For now, we'll create a placeholder
    print('Sending push notification: ${notification.title}');
  }

  // ==================== HELPER METHODS ====================

  /// Get user interests based on their activity
  Future<List<String>> _getUserInterests(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return List<String>.from(data['interests'] ?? []);
      }
    } catch (e) {
      print('Error getting user interests: $e');
    }
    return [];
  }

  /// Analyze user behavior for personalized content
  Future<Map<String, dynamic>> _analyzeUserBehavior(String userId) async {
    try {
      final activityDocs = await _firestore
          .collection('user_activity')
          .where('user_id', isEqualTo: userId)
          .limit(50)
          .get();

      final activities = activityDocs.docs.map((doc) => doc.data()).toList();
      
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

      final preferredCategory = categories.isNotEmpty 
          ? categories.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'general';

      return {
        'preferredCategory': preferredCategory,
        'favoriteDestinations': destinations.keys.take(3).toList(),
        'activityCount': activities.length,
        'lastActivity': activities.isNotEmpty ? activities.first['timestamp'] : null,
      };
    } catch (e) {
      print('Error analyzing user behavior: $e');
      return {'preferredCategory': 'general', 'favoriteDestinations': [], 'activityCount': 0};
    }
  }

  /// Generate personalized tip based on user behavior
  Future<String> _generatePersonalizedTip(Map<String, dynamic> userBehavior) async {
    final category = userBehavior['preferredCategory'] as String;
    final activityCount = userBehavior['activityCount'] as int;

    final tips = {
      'beach': 'Perfect weather for beach destinations this month! Consider visiting coastal areas.',
      'mountain': 'Mountain trails are at their best now. Great time for hiking adventures!',
      'city': 'City festivals are happening this weekend. Don\'t miss the cultural events!',
      'general': 'Based on your travel history, you might enjoy exploring new destinations this season.',
    };

    return tips[category] ?? tips['general']!;
  }

  /// Get top destinations for today
  Future<List<DestinationModel>> _getTopTodayDestinations() async {
    try {
      final querySnapshot = await _firestore
          .collection('destinations')
          .where('is_top_today', isEqualTo: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DestinationModel.fromJson({
          ...data,
          'id': int.tryParse(doc.id) ?? 0,
        });
      }).toList();
    } catch (e) {
      print('Error getting top destinations: $e');
      return [];
    }
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
          'pushEnabled': data['push_notifications'] ?? true,
          'emailEnabled': data['email_notifications'] ?? false,
          'preferredTime': data['notification_time'] ?? '09:00',
        };
      }
    } catch (e) {
      print('Error getting user settings: $e');
    }
    return {'pushEnabled': true, 'emailEnabled': false, 'preferredTime': '09:00'};
  }

  /// Analyze and trigger contextual notifications
  void _analyzeAndTriggerContextualNotifications(List<QueryDocumentSnapshot> activities) {
    // Implement contextual notification logic based on user activity
    // This could trigger notifications based on:
    // - Time spent on app
    // - Destinations viewed
    // - Search patterns
    // - Location changes
  }

  /// Start app usage monitoring
  Future<void> _startAppUsageMonitoring() async {
    // Monitor app usage patterns for engagement-based notifications
    // This could track:
    // - App open frequency
    // - Session duration
    // - Feature usage
  }

  // ==================== PUBLIC API ====================

  /// Manually trigger a notification (for testing)
  Future<void> triggerTestNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final notification = NotificationModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Notification',
      body: 'This is a test notification to verify the system is working.',
      type: 'systemUpdate',
      timestamp: DateTime.now(),
      userId: userId,
      deepLink: '/test',
    );

    await _repository.createNotification(notification);
  }

  /// Manually trigger an interest notification for testing
  Future<void> triggerInterestNotification(String destinationName, String category) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final notification = NotificationModel(
      id: 'test_interest_${DateTime.now().millisecondsSinceEpoch}',
      title: 'You seem interested in $destinationName!',
      body: 'Based on your interest in $destinationName, you might enjoy exploring more $category destinations.',
      type: 'interest_based',
      timestamp: DateTime.now(),
      userId: userId,
      destinationId: '1', // Test ID
      deepLink: '/suggested-destinations?category=$category&exclude=1',
    );

    await _repository.createNotification(notification);
    print('✅ Test interest notification created for: $destinationName');
  }

  /// Create a single test notification for debugging
  Future<void> triggerSingleTestNotification() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final notification = NotificationModel(
      id: 'single_test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Notification',
      body: 'This is a test notification to verify the system is working.',
      type: 'systemUpdate',
      timestamp: DateTime.now(),
      userId: userId,
      deepLink: '/test',
    );

    await _repository.createNotification(notification);
    print('✅ Single test notification created');
  }

  /// Track destination view for behavior analysis
  Future<void> trackDestinationView(String destinationId, String destinationName, String category) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('user_activity').add({
        'user_id': userId,
        'destination_id': destinationId,
        'destination_name': destinationName,
        'category': category,
        'action': 'view',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('📊 Tracked view for: $destinationName (ID: $destinationId)');

      // Check if this destination has been viewed multiple times
      await _checkAndTriggerInterestNotification(destinationId, destinationName, category);
    } catch (e) {
      print('Error tracking destination view: $e');
    }
  }

  /// Manually simulate destination views for testing
  Future<void> simulateDestinationViews(String destinationId, String destinationName, String category, int count) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    print('🎯 Simulating $count views for $destinationName...');
    
    for (int i = 0; i < count; i++) {
      await _firestore.collection('user_activity').add({
        'user_id': userId,
        'destination_id': destinationId,
        'destination_name': destinationName,
        'category': category,
        'action': 'view',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('📊 Added view ${i + 1}/$count for $destinationName');
    }

    // Check if this should trigger a notification
    await _checkAndTriggerInterestNotification(destinationId, destinationName, category);
  }

  /// Check if destination has been viewed multiple times and trigger interest notification
  Future<void> _checkAndTriggerInterestNotification(String destinationId, String destinationName, String category) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Check if we already sent a notification for this destination within 24 hours
      // Use a simpler query to avoid Firebase index issues
      final recentNotifications = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: 'interest_based')
          .get();

      // Filter client-side for the specific destination and recent time
      final now = DateTime.now();
      final recentNotification = recentNotifications.docs.where((doc) {
        final data = doc.data();
        final notificationTime = (data['timestamp'] as Timestamp).toDate();
        return data['destination_id'] == destinationId && 
               now.difference(notificationTime).inHours < 24;
      }).firstOrNull;

      if (recentNotification != null) {
        print('Interest-based notification already sent recently for $destinationName. Skipping.');
        return;
      }

      // Count current views for this destination
      final querySnapshot = await _firestore
          .collection('user_activity')
          .where('user_id', isEqualTo: userId)
          .where('destination_id', isEqualTo: destinationId)
          .where('action', isEqualTo: 'view')
          .get();

      print('Checking interest notification for $destinationName. View count: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.length >= 3) {
        print('Creating interest notification for $destinationName (${querySnapshot.docs.length} views)');
        print('User ID: $userId, Destination ID: $destinationId');
        
        // Get destination details to check for VR support and get image
        String? imageUrl;
        bool hasVirtualTour = false;
        
        // Try to find the destination by ID first
        final destinationDoc = await _firestore
            .collection('destinations')
            .doc(destinationId)
            .get();

        if (destinationDoc.exists) {
          final data = destinationDoc.data() as Map<String, dynamic>;
          imageUrl = data['cover'] as String?;
          hasVirtualTour = data['virtual_tour'] == true;
          print('Destination found in Firebase. Image: $imageUrl, VR: $hasVirtualTour');
        } else {
          // If not found by ID, try to find by name
          final nameQuery = await _firestore
              .collection('destinations')
              .where('name', isEqualTo: destinationName)
              .limit(1)
              .get();
          
          if (nameQuery.docs.isNotEmpty) {
            final data = nameQuery.docs.first.data();
            imageUrl = data['cover'] as String?;
            hasVirtualTour = data['virtual_tour'] == true;
            print('Destination found by name. Image: $imageUrl, VR: $hasVirtualTour');
          } else {
            print('Destination not found in Firebase for ID: $destinationId or name: $destinationName');
          }
        }

        // Get similar destinations for suggestions
        final similarDestinations = await _getSimilarDestinations(category, destinationId);
        String suggestionText = 'Based on your interest in $destinationName, you might enjoy exploring more $category destinations.';
        
        if (similarDestinations.isNotEmpty) {
          final suggestedNames = similarDestinations.map((d) => d.name).join(', ');
          suggestionText = 'You seem interested in $destinationName! Check out similar spots like $suggestedNames.';
        }

        if (hasVirtualTour) {
          suggestionText += ' Check out the virtual reality experience!';
        }

        final notification = NotificationModel(
          id: 'interest_${destinationId}_${DateTime.now().millisecondsSinceEpoch}',
          title: 'You seem interested in $destinationName!',
          body: suggestionText,
          type: 'interest_based',
          timestamp: DateTime.now(),
          userId: userId,
          destinationId: destinationId,
          imageUrl: imageUrl,
          deepLink: '/suggested-destinations?category=$category&exclude=$destinationId',
        );

        print('🔗 Generated deep link: /suggested-destinations?category=$category&exclude=$destinationId');
        print('📝 Category used: $category');
        print('🆔 Destination ID: $destinationId');

        try {
          await _repository.createNotification(notification);
          print('✅ Interest-based notification created for: $destinationName');
          
          // Clear the user activity for this destination after sending notification
          for (DocumentSnapshot doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          print('❌ Error creating notification: $e');
        }
      } else {
        print('Not enough views yet. Need 3, have ${querySnapshot.docs.length}');
      }
    } catch (e) {
      print('Error checking interest notification: $e');
    }
  }

  /// Update user notification preferences
  Future<void> updateNotificationPreferences({
    required bool pushEnabled,
    required bool emailEnabled,
    String? preferredTime,
  }) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'push_notifications': pushEnabled,
      'email_notifications': emailEnabled,
      if (preferredTime != null) 'notification_time': preferredTime,
    });
  }

  /// Get similar destinations based on category
  Future<List<DestinationModel>> _getSimilarDestinations(String category, String excludeDestinationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('destinations')
          .where('category', arrayContains: category)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DestinationModel.fromJson({
          ...data,
          'id': doc.id, // Use the actual document ID
        });
      }).where((destination) => destination.id != excludeDestinationId).toList();
    } catch (e) {
      print('Error getting similar destinations: $e');
      return [];
    }
  }

  /// Create a notification using the repository
  Future<void> createNotification(NotificationModel notification) async {
    await _repository.createNotification(notification);
  }

  /// Clear cooldown for testing purposes
  Future<void> clearCooldownForTesting(String destinationId) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Delete recent notifications for this destination
      final recentNotifications = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: 'interest_based')
          .get();

      for (final doc in recentNotifications.docs) {
        final data = doc.data();
        if (data['destination_id'] == destinationId) {
          await doc.reference.delete();
          print('🗑️ Deleted cooldown notification for destination ID: $destinationId');
        }
      }

      // Also clear user activity for this destination
      final userActivity = await _firestore
          .collection('user_activity')
          .where('user_id', isEqualTo: userId)
          .where('destination_id', isEqualTo: destinationId)
          .where('action', isEqualTo: 'view')
          .get();

      for (final doc in userActivity.docs) {
        await doc.reference.delete();
        print('🗑️ Deleted user activity for destination ID: $destinationId');
      }

      print('✅ Cooldown cleared for destination ID: $destinationId');
    } catch (e) {
      print('❌ Error clearing cooldown: $e');
    }
  }

  // ==================== BROADCAST NOTIFICATIONS ====================

  /// Send notification to ALL users when a new destination is added
  Future<void> broadcastNewDestinationNotification(DestinationModel destination) async {
    try {
      print('📢 Broadcasting new destination notification to all users');
      
      // Get all users from the database
      final usersSnapshot = await _firestore.collection('users').get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('⚠️ No users found in database');
        return;
      }

      print('👥 Found ${usersSnapshot.docs.length} users to notify');

      // Create notification for each user
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        // Check if user has notification preferences and if they're enabled
        final userData = userDoc.data();
        final pushEnabled = userData['push_notifications'] ?? true; // Default to true
        
        if (pushEnabled) {
          final notification = NotificationModel(
            id: 'broadcast_new_dest_${destination.id}_${DateTime.now().millisecondsSinceEpoch}_$userId',
            title: '🎉 New Destination Added!',
            body: '${destination.name} has been added to our collection. Rated ${destination.rating}/5 stars!',
            type: 'broadcast_new_destination',
            timestamp: DateTime.now(),
            userId: userId,
            destinationId: destination.id,
            imageUrl: destination.cover,
            deepLink: '/destinations/${destination.id}',
            metadata: {
              'destinationId': destination.id,
              'destinationName': destination.name,
              'category': destination.category,
              'rating': destination.rating,
              'location': {
                'address': destination.location.address,
                'latitude': destination.location.latitude,
                'longitude': destination.location.longitude,
                'city': destination.location.city,
                'country': destination.location.country,
              },
              'broadcastType': 'new_destination',
            },
          );

          try {
            await _repository.createNotification(notification);
            print('✅ Broadcast notification sent to user: $userId');
          } catch (e) {
            print('❌ Failed to create new destination notification for user $userId: $e');
          }
        } else {
          print('⏭️ Skipping user $userId (notifications disabled)');
        }
      }

      print('📢 Successfully broadcasted new destination notification to all users');
    } catch (e) {
      print('❌ Error broadcasting new destination notification: $e');
    }
  }

  /// Send notification to ALL users when a destination gets VR support
  Future<void> broadcastVRSupportNotification(DestinationModel destination) async {
    try {
      print('📢 Broadcasting VR support notification to all users');
      print('  - Destination: ${destination.name}');
      print('  - VR Support: ${destination.virtualTour}');
      print('  - ID: ${destination.id}');
      
      // Get all users from the database
      final usersSnapshot = await _firestore.collection('users').get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('⚠️ No users found in database');
        return;
      }

      print('👥 Found ${usersSnapshot.docs.length} users to notify');

      // Create notification for each user
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        // Check if user has notification preferences and if they're enabled
        final userData = userDoc.data();
        final pushEnabled = userData['push_notifications'] ?? true; // Default to true
        
        if (pushEnabled) {
          final notification = NotificationModel(
            id: 'broadcast_vr_${destination.id}_${DateTime.now().millisecondsSinceEpoch}_$userId',
            title: '🥽 Virtual Reality Experience Available!',
            body: '${destination.name} now supports immersive VR tours. Experience it in virtual reality!',
            type: 'broadcast_vr_support',
            timestamp: DateTime.now(),
            userId: userId,
            destinationId: destination.id,
            imageUrl: destination.cover,
            deepLink: '/destinations/${destination.id}?vr=true',
            metadata: {
              'destinationId': destination.id,
              'destinationName': destination.name,
              'category': destination.category,
              'rating': destination.rating,
              'location': {
                'address': destination.location.address,
                'latitude': destination.location.latitude,
                'longitude': destination.location.longitude,
                'city': destination.location.city,
                'country': destination.location.country,
              },
              'broadcastType': 'vr_support',
              'vrEnabled': true,
            },
          );

          try {
            await _repository.createNotification(notification);
            print('✅ VR broadcast notification sent to user: $userId');
          } catch (e) {
            print('❌ Failed to create VR notification for user $userId: $e');
          }
        } else {
          print('⏭️ Skipping user $userId (notifications disabled)');
        }
      }

      print('📢 Successfully broadcasted VR support notification to all users');
    } catch (e) {
      print('❌ Error broadcasting VR support notification: $e');
    }
  }

  /// Send general broadcast notification to ALL users
  Future<void> broadcastGeneralNotification({
    required String title,
    required String body,
    String? deepLink,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📢 Broadcasting general notification to all users');
      
      // Get all users from the database
      final usersSnapshot = await _firestore.collection('users').get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('⚠️ No users found in database');
        return;
      }

      print('👥 Found ${usersSnapshot.docs.length} users to notify');

      // Create notification for each user
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        // Check if user has notification preferences and if they're enabled
        final userData = userDoc.data();
        final pushEnabled = userData['push_notifications'] ?? true; // Default to true
        
        if (pushEnabled) {
          final notification = NotificationModel(
            id: 'broadcast_general_${DateTime.now().millisecondsSinceEpoch}_$userId',
            title: title,
            body: body,
            type: 'broadcast_general',
            timestamp: DateTime.now(),
            userId: userId,
            deepLink: deepLink,
            imageUrl: imageUrl,
            metadata: {
              ...?metadata,
              'broadcastType': 'general',
            },
          );

          await _repository.createNotification(notification);
          print('✅ General broadcast notification sent to user: $userId');
        } else {
          print('⏭️ Skipping user $userId (notifications disabled)');
        }
      }

      print('📢 Successfully broadcasted general notification to all users');
    } catch (e) {
      print('❌ Error broadcasting general notification: $e');
    }
  }
} 
