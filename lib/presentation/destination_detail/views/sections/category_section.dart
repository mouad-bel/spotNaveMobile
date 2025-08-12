import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySection extends StatelessWidget {
  final List<String> categories;
  final bool hasVirtualTour;
  final VoidCallback? onVrPreview;

  const CategorySection({
    super.key, 
    required this.categories,
    this.hasVirtualTour = false,
    this.onVrPreview,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 8,
              children: [
                // Categories with improved theme design
                ...categories.map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: AppColors.getPrimaryColor(isDarkMode),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                
                // VR Badge (slightly more remarkable)
                if (hasVirtualTour) ...[
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.getPrimaryColor(isDarkMode),
                          AppColors.getPrimaryColor(isDarkMode).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.6),
                        width: 1.5,
                      ),
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
                          'VR',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
