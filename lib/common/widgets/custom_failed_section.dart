import 'package:extended_image/extended_image.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomFailedSection extends StatelessWidget {
  const CustomFailedSection({super.key, required this.failure});
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExtendedImage.asset(_mappingFailureImages, fit: BoxFit.contain),
          const Gap(16),
          Text(
            _mappingFailureTitles,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(8),
          Text(
            failure.message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String get _mappingFailureImages => switch (failure) {
    CacheFailure _ => AppAssets.images.failures.cache,
    NetworkFailure _ => AppAssets.images.failures.network,
    NoConnectionFailure _ => AppAssets.images.failures.noConnection,
    NotFoundFailure _ => AppAssets.images.failures.notFound,
    ServerFailure _ => AppAssets.images.failures.server,
    ServiceUnavailableFailure _ => AppAssets.images.failures.serviceUnavailable,
    UnauthenticatedFailure _ => AppAssets.images.failures.unauthenticated,
    _ => AppAssets.images.failures.unexpected,
  };

  String get _mappingFailureTitles => switch (failure) {
    CacheFailure _ => 'Cache Error',
    NetworkFailure _ => 'Network Error',
    NoConnectionFailure _ => 'No Connection',
    NotFoundFailure _ => 'Not Found',
    ServerFailure _ => 'Server Error',
    ServiceUnavailableFailure _ => 'Service Unavailable',
    UnauthenticatedFailure _ => 'Unauthenticated',
    _ => 'Unknown Error',
  };
}
