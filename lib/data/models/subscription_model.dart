import 'package:equatable/equatable.dart';

enum SubscriptionType {
  free,
  basic,
  premium,
  pro,
}

class SubscriptionModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final SubscriptionType type;
  final List<String> features;
  final bool isActive;
  final int? maxDestinations;
  final bool hasPremiumSupport;
  final bool hasOfflineAccess;
  final bool hasAdvancedAnalytics;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.features,
    required this.isActive,
    this.maxDestinations,
    this.hasPremiumSupport = false,
    this.hasOfflineAccess = false,
    this.hasAdvancedAnalytics = false,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SubscriptionType.free,
      ),
      features: List<String>.from(json['features'] ?? []),
      isActive: json['is_active'] ?? true,
      maxDestinations: json['max_destinations'],
      hasPremiumSupport: json['has_premium_support'] ?? false,
      hasOfflineAccess: json['has_offline_access'] ?? false,
      hasAdvancedAnalytics: json['has_advanced_analytics'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type.toString().split('.').last,
      'features': features,
      'is_active': isActive,
      'max_destinations': maxDestinations,
      'has_premium_support': hasPremiumSupport,
      'has_offline_access': hasOfflineAccess,
      'has_advanced_analytics': hasAdvancedAnalytics,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    type,
    features,
    isActive,
    maxDestinations,
    hasPremiumSupport,
    hasOfflineAccess,
    hasAdvancedAnalytics,
  ];
} 
