import 'package:equatable/equatable.dart';
import 'package:spotnav/data/models/best_time_to_visit_model.dart';
import 'package:spotnav/data/models/location_model.dart';

class DestinationModel extends Equatable {
  final String id;
  final String name;
  final LocationModel location;
  final String cover;
  final double rating;

  final List<String>? category;
  final String? description;
  final int? popularScore;
  final List<String>? gallery;
  final int? reviewCount;
  final BestTimeToVisitModel? bestTimeToVisit;
  final List<String>? activities;
  final List<String>? imageSources;
  final bool isTopToday;
  final bool virtualTour;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.cover,
    required this.rating,
    this.category,
    this.description,
    this.popularScore,
    this.gallery,
    this.reviewCount,
    this.bestTimeToVisit,
    this.activities,
    this.imageSources,
    this.isTopToday = false,
    this.virtualTour = false,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    // Handle both string and int IDs
    String id;
    if (json['id'] is String) {
      id = json['id'] as String;
    } else if (json['id'] is int) {
      id = (json['id'] as int).toString();
    } else {
      id = '0';
    }

    return DestinationModel(
      id: id,
      name: json['name'] as String? ?? '',
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>? ?? {},
      ),
      cover: json['cover'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      popularScore: json['popular_score'] as int?,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reviewCount: json['review_count'] as int?,
      bestTimeToVisit: json['best_time_to_visit'] != null
          ? BestTimeToVisitModel.fromJson(
              json['best_time_to_visit'] as Map<String, dynamic>,
            )
          : null,
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageSources: (json['image_sources'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isTopToday: json['is_top_today'] as bool? ?? false,
      virtualTour: json['virtual_tour'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'cover': cover,
      'rating': rating,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (popularScore != null) 'popular_score': popularScore,
      if (gallery != null) 'gallery': gallery,
      if (reviewCount != null) 'review_count': reviewCount,
      if (bestTimeToVisit != null)
        'best_time_to_visit': bestTimeToVisit!.toJson(),
      if (activities != null) 'activities': activities,
      if (imageSources != null) 'image_sources': imageSources,
      'is_top_today': isTopToday,
      'virtual_tour': virtualTour,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    cover,
    rating,
    category,
    description,
    popularScore,
    gallery,
    reviewCount,
    bestTimeToVisit,
    activities,
    imageSources,
    isTopToday,
    virtualTour,
  ];
}
