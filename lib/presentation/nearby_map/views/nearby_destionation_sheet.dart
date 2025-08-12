import 'package:spotnav/presentation/nearby_map/blocs/nearby_destinations/nearby_destinations_bloc.dart';
import 'package:spotnav/presentation/nearby_map/views/nearby_destination_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

class NearbyDestionationSheet extends StatelessWidget {
  final MapController mapController;
  final DraggableScrollableController sheetController;

  const NearbyDestionationSheet({
    super.key,
    required this.mapController,
    required this.sheetController,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDarkMode),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.getDividerColor(isDarkMode),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Nearby Destination',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                    height: 1.5,
                  ),
                ),
              ),
              BlocBuilder<
                NearbyDestinationsBloc,
                NearbyDestinationsState
              >(
                builder: (context, state) {
                  String subtitle = '';
                  if (state is NearbyDestinationLoading) {
                    subtitle = 'Looking for destinations...';
                  }
                  if (state is NearbyDestinationFailed) {
                    subtitle = state.failure.message;
                  }
                  if (state is NearbyDestinationLoaded) {
                    final destinationCount = state.destinations.length;
                    subtitle = destinationCount > 0
                        ? 'We found $destinationCount destinations near by you'
                        : "we didn't find any destinations near you";
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                  );
                },
              ),
              const Gap(16),
              Expanded(
                child: NearbyDestinationList(
                  scrollController: scrollController,
                  mapController: mapController,
                  sheetController: sheetController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
