import 'package:flutter/material.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/models/location_model.dart';
import 'package:spotnav/data/services/destination_notification_trigger.dart';
import 'package:spotnav/core/di.dart' as di;
import 'package:gap/gap.dart';

class BroadcastTestPage extends StatefulWidget {
  const BroadcastTestPage({super.key});

  @override
  State<BroadcastTestPage> createState() => _BroadcastTestPageState();
}

class _BroadcastTestPageState extends State<BroadcastTestPage> {
  final DestinationNotificationTrigger _trigger = di.sl<DestinationNotificationTrigger>();
  bool _isLoading = false;

  // Sample destination for testing
  final DestinationModel _sampleDestination = DestinationModel(
    id: 'test_broadcast_destination',
    name: 'Test Broadcast Destination',
    description: 'This is a test destination for broadcast notifications',
    cover: 'https://example.com/image.jpg',
    rating: 4.5,
    location: LocationModel(
      address: 'Test Address, Test City',
      city: 'Test City',
      country: 'Test Country',
      latitude: 0.0,
      longitude: 0.0,
    ),
    category: ['test', 'broadcast'],
    gallery: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
    virtualTour: false,
    popularScore: 100,
    isTopToday: true,
  );

  final DestinationModel _sampleVRDestination = DestinationModel(
    id: 'test_vr_destination',
    name: 'Test VR Destination',
    description: 'This is a test destination with VR support',
    cover: 'https://example.com/vr-image.jpg',
    rating: 4.8,
    location: LocationModel(
      address: 'VR Test Address, VR Test City',
      city: 'VR Test City',
      country: 'VR Test Country',
      latitude: 0.0,
      longitude: 0.0,
    ),
    category: ['test', 'vr', 'broadcast'],
    gallery: ['https://example.com/vr-image1.jpg', 'https://example.com/vr-image2.jpg'],
    virtualTour: true,
    popularScore: 150,
    isTopToday: true,
  );

  Future<void> _triggerNewDestinationBroadcast() async {
    setState(() => _isLoading = true);
    
    try {
      await _trigger.triggerNewDestinationNotification(_sampleDestination);
      _showSuccessSnackBar('New destination broadcast sent to all users!');
    } catch (e) {
      _showErrorSnackBar('Error sending new destination broadcast: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerVRSupportBroadcast() async {
    setState(() => _isLoading = true);
    
    try {
      await _trigger.triggerVRSupportNotification(_sampleVRDestination);
      _showSuccessSnackBar('VR support broadcast sent to all users!');
    } catch (e) {
      _showErrorSnackBar('Error sending VR support broadcast: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerGeneralBroadcast() async {
    setState(() => _isLoading = true);
    
    try {
      await _trigger.triggerGeneralBroadcast(
        title: '🎉 App Update Available!',
        body: 'We\'ve added exciting new features. Update now to experience the latest improvements!',
        deepLink: '/settings',
        metadata: {
          'updateType': 'feature_update',
          'version': '2.1.0',
        },
      );
      _showSuccessSnackBar('General broadcast sent to all users!');
    } catch (e) {
      _showErrorSnackBar('Error sending general broadcast: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Broadcast Test',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Broadcast Notification Testing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            const Text(
              'Test broadcast notifications that will be sent to ALL users in the system.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const Gap(32),
            
            // New Destination Broadcast
            _buildTestCard(
              title: '🎉 New Destination Broadcast',
              description: 'Simulate adding a new destination and notify all users',
              onTap: _isLoading ? null : _triggerNewDestinationBroadcast,
              icon: Icons.add_location,
              color: Colors.blue,
            ),
            
            const Gap(16),
            
            // VR Support Broadcast
            _buildTestCard(
              title: '🥽 VR Support Broadcast',
              description: 'Simulate adding VR support to a destination and notify all users',
              onTap: _isLoading ? null : _triggerVRSupportBroadcast,
              icon: Icons.view_in_ar,
              color: Colors.purple,
            ),
            
            const Gap(16),
            
            // General Broadcast
            _buildTestCard(
              title: '📢 General Broadcast',
              description: 'Send a general announcement to all users',
              onTap: _isLoading ? null : _triggerGeneralBroadcast,
              icon: Icons.broadcast_on_personal,
              color: Colors.orange,
            ),
            
            const Gap(32),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Gap(16),
                    Text(
                      'Sending broadcast notification...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Gap(32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ How it works:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Gap(8),
                  Text(
                    '• Broadcast notifications are sent to ALL users\n'
                    '• Users with disabled notifications are skipped\n'
                    '• Each notification includes deep links to relevant pages\n'
                    '• Notifications are stored in Firebase for each user',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required VoidCallback? onTap,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 