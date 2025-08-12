import 'package:flutter/material.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/models/location_model.dart';
import 'package:spotnav/data/services/destination_notification_trigger.dart';
import 'package:spotnav/core/di.dart' as di;
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.failed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: AppColors.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Broadcast Test',
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(isDarkMode),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Broadcast Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(isDarkMode),
              ),
            ),
            const Gap(8),
            Text(
              'Send test notifications to all users to verify the broadcast system',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
            const Gap(32),
            
            // Test Cards
            Expanded(
              child: ListView(
                children: [
                  _buildTestCard(
                    title: 'New Destination Broadcast',
                    description: 'Send a notification about a new destination to all users',
                    icon: Icons.location_on,
                    onTap: _triggerNewDestinationBroadcast,
                    isDarkMode: isDarkMode,
                  ),
                  const Gap(16),
                  
                  _buildTestCard(
                    title: 'VR Support Broadcast',
                    description: 'Notify users about a new destination with VR support',
                    icon: Icons.view_in_ar,
                    onTap: _triggerVRSupportBroadcast,
                    isDarkMode: isDarkMode,
                  ),
                  const Gap(16),
                  
                  _buildTestCard(
                    title: 'General Broadcast',
                    description: 'Send a custom notification to all users',
                    icon: Icons.broadcast_on_personal,
                    onTap: _triggerGeneralBroadcast,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackgroundColor(isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDarkMode),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.getPrimaryColor(isDarkMode),
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'Sending broadcast...',
                      style: TextStyle(
                        color: AppColors.getTextPrimaryColor(isDarkMode),
                        fontWeight: FontWeight.w500,
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
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.getPrimaryColor(isDarkMode),
                    size: 28,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimaryColor(isDarkMode),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.getTextThinColor(isDarkMode),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 