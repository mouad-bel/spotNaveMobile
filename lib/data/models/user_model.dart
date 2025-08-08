import 'package:equatable/equatable.dart';
import 'subscription_model.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? city;
  final String? address;
  final String? postalCode;
  final String? photoUrl;
  final String? subscriptionId;
  final SubscriptionModel? subscription;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.city,
    this.address,
    this.postalCode,
    this.photoUrl,
    this.subscriptionId,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      city: json['city'],
      address: json['address'],
      postalCode: json['postal_code'],
      photoUrl: json['photo_url'],
      subscriptionId: json['subscription_id'],
      subscription: json['subscription'] != null 
          ? SubscriptionModel.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'photo_url': photoUrl,
      'subscription_id': subscriptionId,
      'subscription': subscription?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    city,
    address,
    postalCode,
    photoUrl,
    subscriptionId,
    subscription,
  ];
}
