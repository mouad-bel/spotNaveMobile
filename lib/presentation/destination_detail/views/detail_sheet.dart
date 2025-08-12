import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/number_util.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/presentation/destination_detail/views/sections/best_time_to_visit_section.dart';
import 'package:spotnav/presentation/destination_detail/views/sections/category_section.dart';
import 'package:spotnav/presentation/destination_detail/views/sections/image_sources_section.dart';
import 'package:spotnav/presentation/destination_detail/views/sections/location_section.dart';
import 'package:spotnav/presentation/destination_detail/views/sections/popular_activities_section.dart';
import 'package:spotnav/presentation/nearby_map/views/nearby_radius_input.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DetailSheet extends StatefulWidget {
  final DestinationModel destination;

  const DetailSheet({super.key, required this.destination});

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  final NotificationService _notificationService = GetIt.instance<NotificationService>();
  
  @override
  void initState() {
    super.initState();
    _trackDestinationView();
  }
  
  Future<void> _trackDestinationView() async {
    try {
      final destination = widget.destination;
      final category = destination.category?.first ?? 'general';
      print('🎯 Tracking destination: ${destination.name}');
      print('📂 Destination categories: ${destination.category}');
      print('🏷️ Selected category: $category');
      await _notificationService.trackDestinationView(
        destination.id,
        destination.name,
        category,
      );
      print('Tracked view for: ${destination.name}');
    } catch (e) {
      print('Error tracking destination view: $e');
    }
  }
  
  Future<void> _launchVirtualTour() async {
    // For demo purposes, using a sample VR tour link
    // In production, this would come from the destination data
    final String vrTourUrl = 'https://www.google.com/earth/';
    
    try {
      final Uri url = Uri.parse(vrTourUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch virtual tour';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to launch virtual tour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return DraggableScrollableSheet(
          shouldCloseOnMinExtent: false,
          initialChildSize: 0.35,
          minChildSize: 0.35,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                  ),
                  const Gap(24),
                  // Destination Header Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Destination name and VR Tour in one row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                destination.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getPrimaryColor(isDarkMode),
                                  height: 1.1,
                                ),
                              ),
                            ),
                            // VR Tour button - same size as rating
                            if (destination.virtualTour == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getPrimaryColor(isDarkMode),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const Gap(6),
                                    Text(
                                      'VR Tour',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const Gap(12),
                        
                        // Rating only
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                              const Gap(6),
                              Text(
                                '${destination.rating}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              Text(
                                ' (${NumberUtil.compact(destination.reviewCount!)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  LocationSection(location: destination.location),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      color: AppColors.getDividerColor(isDarkMode),
                      height: 1,
                    ),
                  ),
                  const Gap(20),
                  CategorySection(
                    categories: destination.category!,
                    hasVirtualTour: destination.virtualTour == true,
                    onVrPreview: destination.virtualTour == true ? _launchVirtualTour : null,
                  ),
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      destination.description!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const Gap(16),
                  BestTimeToVisitSection(
                    bestTimeToVisit: destination.bestTimeToVisit!,
                  ),
                  const Gap(20),
                  PopularActivitiesSection(activities: destination.activities!),
                  const Gap(20),
                  ImageSourcesSection(sources: destination.imageSources!),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
