import 'package:spotnav/data/models/destination_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spotnav/common/app_assets.dart';

class DestinationMarker extends StatelessWidget {
  static const _width = 48.0 * 0.7;
  static const _height = 48.0 * 0.7;

  final List<DestinationModel> destinations;
  final void Function(LatLng point) onTapMarker;

  const DestinationMarker({
    super.key,
    required this.destinations,
    required this.onTapMarker,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: destinations.map((e) {
        final point = LatLng(e.location.latitude, e.location.longitude);
        return Marker(
          point: point,
          width: _width,
          height: _height,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => onTapMarker(point),
            child: Image.asset(AppAssets.images.marker.destination),
          ),
        );
      }).toList(),
    );
  }
}
