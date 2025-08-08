
import 'package:spotnav/data/models/notification_model.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:go_router/go_router.dart';
import 'package:extended_image/extended_image.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Start listening to real-time notifications
    print('🔔 NotificationPanel: Starting to listen to notifications');
    context.read<NotificationBloc>().add(StartListeningToNotificationsEvent());
    
    // Also trigger a manual load to ensure we get notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔔 NotificationPanel: Triggering manual load');
      context.read<NotificationBloc>().add(LoadNotificationsEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Stop listening when disposing
    try {
      context.read<NotificationBloc>().add(StopListeningToNotificationsEvent());
    } catch (e) {
      // Ignore errors during disposal
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showCleanAllDialog(context);
                        },
                        child: Text(
                          'Clean All',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (state.unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            context.read<NotificationBloc>().add(MarkAllAsReadEvent());
                          },
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }

                  if (state is NotificationError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const Gap(16),
                          Text(
                            'Unable to load notifications',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(20),
                          ElevatedButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(StartListeningToNotificationsEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is NotificationLoaded) {
                    final filteredNotifications = _filterNotifications(state.notifications);
                    
                    if (filteredNotifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const Gap(16),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'You\'re all caught up',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                                         return FadeTransition(
                       opacity: _fadeAnimation,
                       child: ListView.builder(
                         padding: const EdgeInsets.all(16),
                         itemCount: _buildGroupedNotifications(filteredNotifications).length,
                         itemBuilder: (context, index) {
                           final group = _buildGroupedNotifications(filteredNotifications)[index];
                           return Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               // Date header
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 12, top: 8),
                                 child: Text(
                                   group['title'] as String,
                                   style: TextStyle(
                                     fontSize: 14,
                                     fontWeight: FontWeight.w600,
                                     color: Colors.grey[700],
                                     letterSpacing: 0.5,
                                   ),
                                 ),
                               ),
                                                               // Notifications in this group
                                ...group['notifications'] as List<Widget>,
                             ],
                           );
                         },
                       ),
                     );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterChip('all', 'All'),
          const Gap(12),
          _buildFilterChip('unread', 'Unread'),
          const Gap(12),
          _buildFilterChip('recent', 'Recent'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'recent':
        final now = DateTime.now();
        return notifications
            .where((n) => now.difference(n.timestamp).inDays <= 7)
            .toList();
      default:
        return notifications;
    }
  }

     List<Map<String, dynamic>> _buildGroupedNotifications(List<NotificationModel> notifications) {
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final yesterday = today.subtract(const Duration(days: 1));
     
     final grouped = <Map<String, dynamic>>[];
     
     // Group by date
     final todayNotifications = <NotificationModel>[];
     final yesterdayNotifications = <NotificationModel>[];
     final otherNotifications = <DateTime, List<NotificationModel>>{};
     
     for (final notification in notifications) {
       final notificationDate = DateTime(
         notification.timestamp.year,
         notification.timestamp.month,
         notification.timestamp.day,
       );
       
       if (notificationDate == today) {
         todayNotifications.add(notification);
       } else if (notificationDate == yesterday) {
         yesterdayNotifications.add(notification);
       } else {
         otherNotifications.putIfAbsent(notificationDate, () => []).add(notification);
       }
     }
     
     // Add today section
     if (todayNotifications.isNotEmpty) {
       grouped.add({
         'title': 'Today',
         'notifications': _buildNotificationWidgets(todayNotifications),
       });
     }
     
     // Add yesterday section
     if (yesterdayNotifications.isNotEmpty) {
       grouped.add({
         'title': 'Yesterday',
         'notifications': _buildNotificationWidgets(yesterdayNotifications),
       });
     }
     
     // Add other dates
     final sortedDates = otherNotifications.keys.toList()..sort((a, b) => b.compareTo(a));
     for (final date in sortedDates) {
       final notifications = otherNotifications[date]!;
       grouped.add({
         'title': _formatDate(date),
         'notifications': _buildNotificationWidgets(notifications),
       });
     }
     
     return grouped;
   }
   
   List<Widget> _buildNotificationWidgets(List<NotificationModel> notifications) {
     return notifications.map((notification) {
       return Container(
         margin: const EdgeInsets.only(bottom: 12),
         child: Dismissible(
           key: Key(notification.id),
           direction: DismissDirection.endToStart,
           background: Container(
             decoration: BoxDecoration(
               color: Colors.red[50],
               borderRadius: BorderRadius.circular(12),
             ),
             child: const Align(
               alignment: Alignment.centerRight,
               child: Padding(
                 padding: EdgeInsets.only(right: 16),
                 child: Icon(
                   Icons.delete_outline,
                   color: Colors.red,
                   size: 24,
                 ),
               ),
             ),
           ),
           confirmDismiss: (direction) async {
             return await showDialog(
               context: context,
               builder: (BuildContext context) {
                 return AlertDialog(
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(16),
                   ),
                   title: const Text(
                     'Delete notification',
                     style: TextStyle(fontWeight: FontWeight.w600),
                   ),
                   content: const Text(
                     'Are you sure you want to delete this notification?',
                   ),
                   actions: [
                     TextButton(
                       onPressed: () => Navigator.of(context).pop(false),
                       child: const Text('Cancel'),
                     ),
                     ElevatedButton(
                       onPressed: () => Navigator.of(context).pop(true),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.red,
                         foregroundColor: Colors.white,
                       ),
                       child: const Text('Delete'),
                     ),
                   ],
                 );
               },
             );
           },
           onDismissed: (direction) {
             // Delete notification without page reload
             context.read<NotificationBloc>().add(
               DeleteNotificationEvent(notification.id),
             );
             // Show snackbar with undo option
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: const Text('Notification deleted'),
                 behavior: SnackBarBehavior.floating,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8),
                 ),
                 duration: const Duration(seconds: 2),
               ),
             );
           },
           child: NotificationCard(
             notification: notification,
             onTap: () {
               context.read<NotificationBloc>().add(
                 MarkAsReadEvent(notification.id),
               );
               _handleDeepLink(context, notification);
             },
           ),
         ),
       );
     }).toList();
   }
   
   String _formatDate(DateTime date) {
     final now = DateTime.now();
     final difference = now.difference(date).inDays;
     
     if (difference == 1) {
       return 'Yesterday';
     } else if (difference == 0) {
       return 'Today';
     } else {
       // Format as "Monday, January 15" or "Jan 15, 2024" for older dates
       final months = [
         'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
       ];
       
       if (date.year == now.year) {
         return '${months[date.month - 1]} ${date.day}';
       } else {
         return '${months[date.month - 1]} ${date.day}, ${date.year}';
       }
     }
   }

   void _handleDeepLink(BuildContext context, NotificationModel notification) {
     if (notification.deepLink != null) {
       print('Handling deep link: ${notification.deepLink}');
       print('Notification details:');
       print('  - ID: ${notification.id}');
       print('  - Title: ${notification.title}');
       print('  - Type: ${notification.type}');
       print('  - Destination ID: ${notification.destinationId}');
       
       // Special handling for profile update notifications
       if (notification.type == 'profileUpdate') {
         print('📱 Handling profile update notification');
         // Mark as read and navigate to account page
         context.read<NotificationBloc>().add(
           MarkAsReadEvent(notification.id),
         );
         context.push('/account');
         return;
       }
       
       // Handle navigation based on deep link
       if (notification.deepLink!.startsWith('/destinations/')) {
         // Extract destination ID from the deep link
         final destinationId = notification.deepLink!.split('/').last;
         print('Navigating to destination ID: $destinationId');
         
         // Check if this is a valid destination ID (not 0 or empty)
         if (destinationId == '0' || destinationId.isEmpty) {
           print('⚠️ Invalid destination ID: $destinationId');
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: const Text('This destination is no longer available'),
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
               backgroundColor: Colors.orange,
             ),
           );
           return;
         }
         
         context.push(notification.deepLink!);
       } else if (notification.deepLink!.startsWith('/category/')) {
         context.push(notification.deepLink!);
       } else if (notification.deepLink!.startsWith('/suggested-destinations')) {
         print('Navigating to suggested destinations');
         context.push(notification.deepLink!);
       } else {
         // For other deep links, show a snackbar
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Opening: ${notification.title}'),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
           ),
         );
       }
     } else {
       print('No deep link available for notification: ${notification.title}');
     }
   }

   void _showCleanAllDialog(BuildContext context) {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(16),
           ),
           title: const Text(
             'Clean All Notifications',
             style: TextStyle(fontWeight: FontWeight.w600),
           ),
           content: const Text(
             'Are you sure you want to delete all notifications? This action cannot be undone.',
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(false),
               child: const Text('Cancel'),
             ),
             ElevatedButton(
               onPressed: () => Navigator.of(context).pop(true),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red,
                 foregroundColor: Colors.white,
               ),
               child: const Text('Delete All'),
             ),
           ],
         );
       },
     ).then((confirmed) async {
       if (confirmed == true) {
         context.read<NotificationBloc>().add(DeleteAllNotificationsEvent());
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('All notifications deleted'),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
             duration: const Duration(seconds: 2),
           ),
         );
       }
     });
   }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

    @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: notification.isRead ? null : [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 12, top: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                // Destination thumbnail
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: notification.imageUrl != null && notification.imageUrl!.isNotEmpty
                        ? (notification.type == 'profileUpdate' && notification.imageUrl!.startsWith('👤'))
                            ? Container(
                                color: Colors.blue[50],
                                child: Center(
                                  child: Text(
                                    notification.imageUrl!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              )
                            : ExtendedImage.network(
                                notification.imageUrl!,
                                fit: BoxFit.cover,
                                cache: true,
                                loadStateChanged: (state) {
                                  if (state.extendedImageLoadState == LoadState.loading) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  if (state.extendedImageLoadState == LoadState.failed) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const Gap(12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _removeEmojis(notification.title),
                              style: TextStyle(
                                fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.w600,
                                fontSize: 15,
                                color: notification.isRead ? Colors.black87 : Colors.black,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: notification.isRead ? Colors.grey[500] : Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: notification.isRead ? Colors.grey[600] : Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'newSpot':
        return Colors.green[600]!;
      case 'virtualTour':
        return Colors.blue[600]!;
      case 'personalizedTip':
        return Colors.orange[600]!;
      case 'topToday':
        return Colors.red[600]!;
      case 'eventAlert':
        return Colors.purple[600]!;
      case 'systemUpdate':
        return Colors.grey[600]!;
      case 'promo':
        return Colors.pink[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getStatusIcon(String type) {
    switch (type) {
      case 'newSpot':
        return Icons.location_on;
      case 'virtualTour':
        return Icons.view_in_ar;
      case 'personalizedTip':
        return Icons.lightbulb;
      case 'topToday':
        return Icons.star;
      case 'eventAlert':
        return Icons.event;
      case 'systemUpdate':
        return Icons.system_update;
      case 'promo':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'newSpot':
        return Colors.green[600]!;
      case 'virtualTour':
        return Colors.blue[600]!;
      case 'personalizedTip':
        return Colors.orange[600]!;
      case 'topToday':
        return Colors.red[600]!;
      case 'eventAlert':
        return Colors.purple[600]!;
      case 'systemUpdate':
        return Colors.grey[600]!;
      case 'promo':
        return Colors.pink[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'newSpot':
        return 'New Spot';
      case 'virtualTour':
        return 'VR Tour';
      case 'personalizedTip':
        return 'Tip';
      case 'topToday':
        return 'Top Today';
      case 'eventAlert':
        return 'Event';
      case 'systemUpdate':
        return 'System';
      case 'promo':
        return 'Promo';
      default:
        return 'Notification';
    }
  }

                       String _removeEmojis(String text) {
              // Return text as-is since emojis will be fixed in Firebase
              return text;
            }

   String _formatTimestamp(DateTime timestamp) {
     final now = DateTime.now();
     final difference = now.difference(timestamp);

     if (difference.inDays > 7) {
       return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
     } else if (difference.inDays > 0) {
       return '${difference.inDays}d ago';
     } else if (difference.inHours > 0) {
       return '${difference.inHours}h ago';
     } else if (difference.inMinutes > 0) {
       return '${difference.inMinutes}m ago';
     } else {
       return 'Just now';
     }
   }
}