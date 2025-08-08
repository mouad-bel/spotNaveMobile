import 'package:spotnav/common/widgets/custom_failed_section.dart';
import 'package:spotnav/presentation/nearby_map/blocs/nearby_destinations/nearby_destinations_bloc.dart';
import 'package:spotnav/presentation/nearby_map/views/destination_map.dart';
import 'package:spotnav/presentation/nearby_map/views/nearby_destination_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';

class NearbyDestinationList extends StatelessWidget {
  static final Map<String, GlobalKey> _itemKeys = {};

  final ScrollController scrollController;
  final MapController mapController;
  final DraggableScrollableController sheetController;

  const NearbyDestinationList({
    super.key,
    required this.scrollController,
    required this.mapController,
    required this.sheetController,
  });

  void _onTargetPin(LatLng latLong) {
    mapController.move(latLong, DestinationMap.highlightZoom);
    sheetController.animateTo(
      0.25,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyDestinationsBloc, NearbyDestinationsState>(
      builder: (context, state) {
        if (state is NearbyDestinationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NearbyDestinationFailed) {
          return CustomFailedSection(failure: state.failure);
        }
        if (state is NearbyDestinationLoaded) {
          final list = state.destinations;
          if (list.isNotEmpty) {
            return ListView.separated(
              controller: scrollController,
              itemCount: list.length,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const Gap(20),
              itemBuilder: (context, index) {
                final destination = list[index];
                if (!_itemKeys.containsKey(destination.id.toString())) {
                  _itemKeys[destination.id.toString()] = GlobalKey();
                }
                return NearbyDestinationItem(
                  key: _itemKeys[destination.id.toString()],
                  destination: destination,
                  onTargetPin: _onTargetPin,
                );
              },
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
