import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LocationSection extends StatelessWidget {
  final LocationModel location;

  const LocationSection({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageIcon(
            AssetImage(AppAssets.icons.location),
            size: 20,
            color: AppColors.textSecondary,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              '${location.address}. ${location.city}, ${location.country}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
