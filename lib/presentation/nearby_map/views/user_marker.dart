import 'package:extended_image/extended_image.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spotnav/common/app_assets.dart';

class UserMarker extends StatelessWidget {
  static const _width = 60.0 * 0.7;
  static const _height = 80.0 * 0.7;

  final LatLng point;
  final void Function(LatLng point) onTap;

  const UserMarker({super.key, required this.point, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }
        return MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: _width,
              height: _height,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => onTap(point),
                child: Stack(
                  children: [
                    ClipOval(
                      child: state.user.photoUrl != null
                          ? ExtendedImage.network(
                              state.user.photoUrl!,
                              width: _width,
                              height: _width,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: _width,
                              height: _width,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: _width * 0.5,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                    Image.asset(
                      AppAssets.images.marker.user,
                      width: _width,
                      height: _height,
                      fit: BoxFit.contain,
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
