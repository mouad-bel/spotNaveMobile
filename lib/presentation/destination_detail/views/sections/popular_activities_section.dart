import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PopularActivitiesSection extends StatelessWidget {
  final List<String> activities;

  const PopularActivitiesSection({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Activities',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: activities.map((e) {
              return Row(
                children: [
                  const Icon(
                    Icons.radio_button_checked_sharp,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const Gap(12),
                  Text(
                    e,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
