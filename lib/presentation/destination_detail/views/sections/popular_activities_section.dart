import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularActivitiesSection extends StatelessWidget {
  final List<String> activities;

  const PopularActivitiesSection({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Activities',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activities.map((e) {
                  return Row(
                    children: [
                      Icon(
                        Icons.radio_button_checked_sharp,
                        size: 12,
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                      const Gap(12),
                      Text(
                        e,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
