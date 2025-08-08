import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String? deepLink;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final String? destinationId;
  final String? imageUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.deepLink,
    this.metadata,
    this.userId,
    this.destinationId,
    this.imageUrl,
  });

  // Copy with method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? deepLink,
    Map<String, dynamic>? metadata,
    String? userId,
    String? destinationId,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink ?? this.deepLink,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
      destinationId: destinationId ?? this.destinationId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Helper methods for type-specific properties
  String get typeLabel {
    switch (type) {
      case 'newSpot':
        return 'New Destination';
      case 'virtualTour':
        return 'Virtual Tour';
      case 'personalizedTip':
        return 'Travel Tip';
      case 'topToday':
        return 'Top Today';
      case 'eventAlert':
        return 'Event Alert';
      case 'systemUpdate':
        return 'Update';
      case 'promo':
        return 'Special Offer';
      case 'profileUpdate':
        return 'Profile Update';
      case 'broadcast_new_destination':
        return 'New Destination';
      case 'broadcast_vr_support':
        return 'VR Support';
      case 'interest_based':
        return 'Interest Based';
      case 'virtualTour':
        return 'Virtual Tour';
      default:
        return 'Notification';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'newSpot':
        return '🌟';
      case 'virtualTour':
        return '🎥';
      case 'personalizedTip':
        return '💡';
      case 'topToday':
        return '🔥';
      case 'eventAlert':
        return '📅';
      case 'systemUpdate':
        return '⚙️';
      case 'promo':
        return '🎉';
      case 'profileUpdate':
        return '👤';
      case 'broadcast_new_destination':
        return '🌟';
      case 'broadcast_vr_support':
        return '🥽';
      case 'interest_based':
        return '💫';
      default:
        return '🔔';
    }
  }

  // Firebase serialization
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson({...data, 'id': doc.id});
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle destination_id that could be int or String
    String? destinationId;
    if (json['destination_id'] != null) {
      if (json['destination_id'] is int) {
        destinationId = json['destination_id'].toString();
      } else {
        destinationId = json['destination_id'] as String?;
      }
    }

    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      deepLink: json['deep_link'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      userId: json['user_id'] as String?,
      destinationId: destinationId,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_read': isRead,
      if (deepLink != null) 'deep_link': deepLink,
      if (metadata != null) 'metadata': metadata,
      if (userId != null) 'user_id': userId,
      if (destinationId != null) 'destination_id': destinationId,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        timestamp,
        isRead,
        deepLink,
        metadata,
        userId,
        destinationId,
        imageUrl,
      ];
}