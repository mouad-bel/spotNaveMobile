import 'package:extended_image/extended_image.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class NearbyDestinationItem extends StatelessWidget {
  final DestinationModel destination;
  final void Function(LatLng latLong) onTargetPin;

  const NearbyDestinationItem({
    super.key,
    required this.destination,
    required this.onTargetPin,
  });

  void _targetPin() {
    onTargetPin(
      LatLng(destination.location.latitude, destination.location.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/destinations/${destination.id}');
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ExtendedImage.network(
              destination.cover,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${destination.location.city}, ${destination.location.country}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(10),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: destination.rating,
                      allowHalfRating: true,
                      itemSize: 15,
                      itemPadding: const EdgeInsets.all(0),
                      unratedColor: AppColors.textSecondary,
                      itemBuilder: (context, index) => ImageIcon(
                        AssetImage(AppAssets.icons.star),
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {},
                      ignoreGestures: true,
                    ),
                    const Gap(8),
                    Text(
                      '${destination.rating}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.outlined(
            onPressed: _targetPin,
            icon: ImageIcon(AssetImage(AppAssets.icons.coordinate), size: 20),
          ),
        ],
      ),
    );
  }
}
