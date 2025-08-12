import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LocationSection extends StatelessWidget {
  final LocationModel location;

  const LocationSection({super.key, required this.location});

    @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Location icon with better styling
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.getPrimaryColor(isDarkMode),
                  ),
                ),
                
                const Gap(12),
                
                // Location text with better layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getPrimaryColor(isDarkMode),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '${location.address}. ${location.city}, ${location.country}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const Gap(12),
                
                // Map button with improved design
                GestureDetector(
                  onTap: () {
                    // Navigate to nearby map with the destination coordinates
                    context.go('/nearby-map');
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(isDarkMode),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.map_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
