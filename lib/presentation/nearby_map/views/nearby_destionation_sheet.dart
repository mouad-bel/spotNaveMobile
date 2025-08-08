import 'package:spotnav/presentation/nearby_map/blocs/nearby_destinations/nearby_destinations_bloc.dart';
import 'package:spotnav/presentation/nearby_map/views/nearby_destination_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';

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
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
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
                          color: Colors.grey[300],
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
                          color: Colors.grey[800],
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
                              color: Colors.grey[600],
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
              ),
            ),
          ],
        );
      },
    );
  }
}
