import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/best_time_to_visit_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BestTimeToVisitSection extends StatelessWidget {
  final BestTimeToVisitModel bestTimeToVisit;

  const BestTimeToVisitSection({super.key, required this.bestTimeToVisit});

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
                'Best Time to Visit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
              const Gap(12),
              Text(
                '${bestTimeToVisit.season} season',
                style: TextStyle(
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                  fontSize: 16,
                ),
              ),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bestTimeToVisit.months.map((e) {
                  return Chip(
                    label: Text(
                      e,
                      style: TextStyle(
                        color: AppColors.getTextPrimaryColor(isDarkMode),
                      ),
                    ),
                    visualDensity: const VisualDensity(vertical: -4),
                    backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                    side: BorderSide(color: AppColors.getDividerColor(isDarkMode)),
                  );
                }).toList(),
              ),
              const Gap(12),
              ListTile(
                tileColor: AppColors.getDividerColor(isDarkMode),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: ImageIcon(
                  AssetImage(AppAssets.icons.info),
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
                subtitle: Text(
                  bestTimeToVisit.notes,
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
