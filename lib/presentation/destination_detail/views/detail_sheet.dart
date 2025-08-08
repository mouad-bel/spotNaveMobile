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
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        destination.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          ImageIcon(
                            AssetImage(AppAssets.icons.star),
                            size: 15,
                            color: Colors.amber,
                          ),
                          const Gap(8),
                          Text(
                            '${destination.rating}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/${NumberUtil.compact(destination.reviewCount!)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Virtual Reality Badge and Preview Button
              if (destination.virtualTour == true) ...[
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // VR Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.view_in_ar_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const Gap(6),
                            Text(
                              'Virtual Reality',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      // VR Preview Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchVirtualTour(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primary.withOpacity(0.3),
                          ),
                          icon: Icon(Icons.visibility, size: 18),
                          label: Text(
                            'Preview VR Tour',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Gap(8),
              LocationSection(location: destination.location),
              const Gap(10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: AppColors.textThin, height: 1),
              ),
              const Gap(20),
              CategorySection(categories: destination.category!),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  destination.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textSecondary,
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
  }
}
