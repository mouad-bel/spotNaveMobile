import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/widgets/custom_icon_button.dart';
import 'package:spotnav/presentation/nearby_map/cubits/center_coordinates/center_coordinates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';

import 'destination_map.dart';
import 'nearby_destionation_sheet.dart';
import 'nearby_radius_input.dart';
import 'nearby_search_address_input.dart';

class NearbyMapPage extends StatefulWidget {
  final String address;

  const NearbyMapPage({super.key, required this.address});

  @override
  State<NearbyMapPage> createState() => _NearbyMapPageState();
}

class _NearbyMapPageState extends State<NearbyMapPage> {
  final _nearbyDestinationSheetController = DraggableScrollableController();
  final _mapController = MapController();

  void _onTapMarker(LatLng point) {
    _mapController.move(point, DestinationMap.highlightZoom);
    if (!_nearbyDestinationSheetController.isAttached) return;
    _nearbyDestinationSheetController.animateTo(
      0.25,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInCubic,
    );
  }

  void _onFit(BuildContext context) {
    final center = context.read<CenterCoordinatesCubit>().state.coordinates;
    _mapController.move(center!, DestinationMap.initialZoom);
  }

  void _zoomIn(BuildContext context) {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom >= DestinationMap.maxZoom) return;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut(BuildContext context) {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom <= DestinationMap.minZoom) return;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CenterCoordinatesCubit>().updateCoordinatesFromAddress(
        widget.address,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DestinationMap(
            mapController: _mapController,
            onTapMarker: _onTapMarker,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16.0,
            right: 16.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NearbySearchAddressInput(initialAddress: widget.address),
                const Gap(8),
                Row(
                  children: [
                    const Expanded(child: NearbyRadiusInput()),
                    const Gap(4),
                    CustomIconButton(
                      icon: AppAssets.icons.zoomOut,
                      onTap: () => _zoomOut(context),
                    ),
                    const Gap(4),
                    CustomIconButton(
                      icon: AppAssets.icons.zoomIn,
                      onTap: () => _zoomIn(context),
                    ),
                    const Gap(4),
                    CustomIconButton(
                      icon: AppAssets.icons.fit,
                      onTap: () => _onFit(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          NearbyDestionationSheet(
            mapController: _mapController,
            sheetController: _nearbyDestinationSheetController,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nearbyDestinationSheetController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
