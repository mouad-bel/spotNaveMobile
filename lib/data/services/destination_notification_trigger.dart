import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/services/notification_service.dart';

/// Service to handle automatic notification triggers for destination changes
class DestinationNotificationTrigger {
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;
  final Map<String, bool> _destinationVRState = {};
  final Set<String> _existingDestinationIds = {};
  DateTime? _initializationTime;

  DestinationNotificationTrigger({
    required NotificationService notificationService,
    required FirebaseFirestore firestore,
  }) : _notificationService = notificationService,
       _firestore = firestore;

  /// Initialize the trigger system to monitor destination changes
  Future<void> initialize() async {
    print('🔔 Initializing destination notification triggers');
    
    // Record initialization time to ignore existing destinations
    _initializationTime = DateTime.now();
    
    // Load initial VR states and track existing destination IDs
    final snapshot = await _firestore.collection('destinations').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      _destinationVRState[doc.id] = data['virtual_tour'] ?? false;
      _existingDestinationIds.add(doc.id);
    }
    
    print('📝 Loaded initial VR states for ${snapshot.docs.length} destinations');
    print('📝 Tracked ${_existingDestinationIds.length} existing destination IDs');
    
    // Set up listener for new destinations
    _firestore
        .collection('destinations')
        .snapshots()
        .listen(_handleDestinationChanges);
    
    print('✅ Destination notification triggers initialized');
  }

  /// Handle changes in the destinations collection
  void _handleDestinationChanges(QuerySnapshot snapshot) {
    for (final change in snapshot.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          _handleNewDestination(change.doc);
          break;
        case DocumentChangeType.modified:
          _handleDestinationUpdate(change.doc);
          break;
        case DocumentChangeType.removed:
          // Handle destination removal if needed
          break;
      }
    }
  }

  /// Handle when a new destination is added
  void _handleNewDestination(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final destination = DestinationModel.fromJson({
        ...data,
        'id': doc.id,
      });

      // Check if this destination already existed when we started
      if (_existingDestinationIds.contains(doc.id)) {
        print('⏭️ Skipping existing destination: ${destination.name} (ID: ${doc.id})');
        // Still initialize VR state for existing destinations
        _destinationVRState[doc.id] = destination.virtualTour ?? false;
        return;
      }

      print('🆕 New destination detected: ${destination.name}');
      
      // Send broadcast notification to all users
      await _notificationService.broadcastNewDestinationNotification(destination);
      
      print('✅ Broadcast notification sent for new destination: ${destination.name}');
      
      // Initialize VR state in our cache
      _destinationVRState[doc.id] = destination.virtualTour ?? false;
    } catch (e) {
      print('❌ Error handling new destination: $e');
    }
  }

  /// Handle when a destination is updated (e.g., VR support added)
  void _handleDestinationUpdate(DocumentSnapshot doc) async {
    try {
      // Get the new state
      final newData = doc.data() as Map<String, dynamic>;
      final destination = DestinationModel.fromJson({
        ...newData,
        'id': doc.id,
      });

      // Get the old state from our cache
      final oldVRSupport = _destinationVRState[doc.id] ?? false;
      final newVRSupport = destination.virtualTour ?? false;
      
      print('🔍 Checking VR support change:');
      print('  - Destination: ${destination.name}');
      print('  - Old VR support: $oldVRSupport');
      print('  - New VR support: $newVRSupport');
      
      if (newVRSupport && !oldVRSupport) {
        print('🥽 VR support added for destination: ${destination.name}');
        
        // Send broadcast notification to all users about VR support
        await _notificationService.broadcastVRSupportNotification(destination);
        
        print('✅ VR broadcast notification sent for destination: ${destination.name}');
      }
      
      // Update our cache with the new state
      _destinationVRState[doc.id] = newVRSupport;
    } catch (e) {
      print('❌ Error handling destination update: $e');
    }
  }

  /// Manually trigger new destination notification (for testing)
  Future<void> triggerNewDestinationNotification(DestinationModel destination) async {
    print('🧪 Manually triggering new destination notification for: ${destination.name}');
    await _notificationService.broadcastNewDestinationNotification(destination);
  }

  /// Manually trigger VR support notification (for testing)
  Future<void> triggerVRSupportNotification(DestinationModel destination) async {
    print('🧪 Manually triggering VR support notification for: ${destination.name}');
    await _notificationService.broadcastVRSupportNotification(destination);
  }

  /// Manually trigger general broadcast notification (for testing)
  Future<void> triggerGeneralBroadcast({
    required String title,
    required String body,
    String? deepLink,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    print('🧪 Manually triggering general broadcast notification');
    await _notificationService.broadcastGeneralNotification(
      title: title,
      body: body,
      deepLink: deepLink,
      imageUrl: imageUrl,
      metadata: metadata,
    );
  }
} 