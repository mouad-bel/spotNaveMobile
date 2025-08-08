import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/models/location_model.dart';

class SpotModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? cover;
  final double? rating;
  final List<String>? category;
  final int? popularScore;
  final List<String>? gallery;
  final int? reviewCount;
  final List<String>? activities;
  final List<String>? imageSources;
  final GeoPoint? location;
  final String? address;
  final String? city;
  final String? country;
  final Map<String, dynamic>? bestTimeToVisit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final bool? isActive;
  final bool? isFeatured;

  const SpotModel({
    required this.id,
    required this.name,
    this.description,
    this.cover,
    this.rating,
    this.category,
    this.popularScore,
    this.gallery,
    this.reviewCount,
    this.activities,
    this.imageSources,
    this.location,
    this.address,
    this.city,
    this.country,
    this.bestTimeToVisit,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.isActive,
    this.isFeatured,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) {
    return SpotModel(
      id: json['id'] as String? ?? json['documentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      cover: json['cover'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      popularScore: json['popularScore'] as int?,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reviewCount: json['reviewCount'] as int?,
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageSources: (json['imageSources'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      location: json['location'] as GeoPoint?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      bestTimeToVisit: json['bestTimeToVisit'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : null,
      createdBy: json['createdBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (cover != null) 'cover': cover,
      if (rating != null) 'rating': rating,
      if (category != null) 'category': category,
      if (popularScore != null) 'popularScore': popularScore,
      if (gallery != null) 'gallery': gallery,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (activities != null) 'activities': activities,
      if (imageSources != null) 'imageSources': imageSources,
      if (location != null) 'location': location,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (bestTimeToVisit != null) 'bestTimeToVisit': bestTimeToVisit,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (createdBy != null) 'createdBy': createdBy,
      if (isActive != null) 'isActive': isActive,
      if (isFeatured != null) 'isFeatured': isFeatured,
    };
  }

  // Convert to DestinationModel for compatibility with existing app
  DestinationModel toDestinationModel() {
    return DestinationModel(
      id: id, // Use the string ID directly
      name: name,
      location: LocationModel(
        latitude: location?.latitude ?? 0.0,
        longitude: location?.longitude ?? 0.0,
        address: address ?? '',
        city: city ?? '',
        country: country ?? '',
      ),
      cover: cover ?? '',
      rating: rating ?? 0.0,
      category: category,
      description: description,
      popularScore: popularScore,
      gallery: gallery,
      reviewCount: reviewCount,
      activities: activities,
      imageSources: imageSources,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    cover,
    rating,
    category,
    popularScore,
    gallery,
    reviewCount,
    activities,
    imageSources,
    location,
    address,
    city,
    country,
    bestTimeToVisit,
    createdAt,
    updatedAt,
    createdBy,
    isActive,
    isFeatured,
  ];
} 
