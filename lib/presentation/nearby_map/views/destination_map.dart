import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/app_constants.dart';
import 'package:spotnav/common/widgets/custom_failed_section.dart';
import 'package:spotnav/presentation/nearby_map/blocs/nearby_destinations/nearby_destinations_bloc.dart';
import 'package:spotnav/presentation/nearby_map/cubits/center_coordinates/center_coordinates_cubit.dart';
import 'package:spotnav/presentation/nearby_map/cubits/nearby_radius/nearby_radius_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'destination_marker.dart';
import 'user_marker.dart';

class DestinationMap extends StatelessWidget {
  static const initialZoom = 3.0;
  static const minZoom = 2.0;
  static const maxZoom = 14.0;
  static const highlightZoom = 8.0;

  /// radius in kilometer
  static const initialRadius = 2_625.0;
  static const minRadius = 100.0;
  static const maxRadius = 4_000.0;

  final MapController mapController;
  final void Function(LatLng point) onTapMarker;

  const DestinationMap({
    super.key,
    required this.mapController,
    required this.onTapMarker,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CenterCoordinatesCubit, CenterCoordinatesState>(
      listener: (context, state) {
        if (state is CenterCoordinatesUpdated) {
          // Start listening to real-time updates instead of just fetching once
          context.read<NearbyDestinationsBloc>().add(
            StartListeningToNearbyDestinationsEvent(
              latitude: state.coordinates!.latitude,
              longitude: state.coordinates!.longitude,
              radius: context.read<NearbyRadiusCubit>().state,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CenterCoordinatesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CenterCoordinatesFailed) {
          return CustomFailedSection(failure: state.failure);
        }
        if (state is CenterCoordinatesUpdated) {
          final center = state.coordinates!;

          return BlocListener<NearbyRadiusCubit, double>(
            listener: (context, radius) {
              // Restart listening when radius changes
              context.read<NearbyDestinationsBloc>().add(
                StartListeningToNearbyDestinationsEvent(
                  latitude: center.latitude,
                  longitude: center.longitude,
                  radius: radius,
                ),
              );
            },
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                keepAlive: true,
                onMapReady: () {
                  mapController.move(state.coordinates!, initialZoom);
                },
                initialCenter: center,
                minZoom: DestinationMap.minZoom,
                maxZoom: DestinationMap.maxZoom,
                initialZoom: DestinationMap.initialZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: AppConstants.appId,
                ),
                BlocBuilder<NearbyRadiusCubit, double>(
                  builder: (context, radius) {
                    return CircleLayer(
                      circles: [
                        if (radius >= minRadius && radius <= maxRadius)
                          CircleMarker(
                            point: center,
                            radius: radius * 1000,
                            useRadiusInMeter: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderColor: AppColors.primary,
                            borderStrokeWidth: 1,
                          ),
                      ],
                    );
                  },
                ),
                UserMarker(point: center, onTap: onTapMarker),
                BlocBuilder<NearbyDestinationsBloc, NearbyDestinationsState>(
                  builder: (context, nearbyState) {

                    if (nearbyState is NearbyDestinationLoaded) {

                      return DestinationMarker(
                        destinations: nearbyState.destinations,
                        onTapMarker: onTapMarker,
                      );
                    }
                    if (nearbyState is NearbyDestinationLoading) {

                    }
                    if (nearbyState is NearbyDestinationFailed) {

                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
