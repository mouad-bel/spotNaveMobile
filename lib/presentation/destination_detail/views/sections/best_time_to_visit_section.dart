import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/best_time_to_visit_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BestTimeToVisitSection extends StatelessWidget {
  final BestTimeToVisitModel bestTimeToVisit;

  const BestTimeToVisitSection({super.key, required this.bestTimeToVisit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Time to Visit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(12),
          Text('${bestTimeToVisit.season} season'),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bestTimeToVisit.months.map((e) {
              return Chip(
                label: Text(e),
                visualDensity: const VisualDensity(vertical: -4),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.divider),
              );
            }).toList(),
          ),
          const Gap(12),
          ListTile(
            tileColor: AppColors.divider,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: ImageIcon(
              AssetImage(AppAssets.icons.info),
              color: AppColors.textSecondary,
            ),
            subtitle: Text(bestTimeToVisit.notes),
          ),
        ],
      ),
    );
  }
}
