import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

abstract class GeocodingInfo {
  Future<Either<Failure, LatLng>> getCoordinatesFromAddress(String address);
}

class GeocodingInfoImpl implements GeocodingInfo {
  final NetworkInfo _networkInfo;

  const GeocodingInfoImpl({required NetworkInfo networkInfo})
    : _networkInfo = networkInfo;

  @override
  Future<Either<Failure, LatLng>> getCoordinatesFromAddress(
    String address,
  ) async {
    if (!await _networkInfo.isConnected()) {
      return const Left(
        NoConnectionFailure(message: 'You are not connected to the network.'),
      );
    }

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        return const Left(
          NotFoundFailure(
            message: 'No coordinates found for the given address',
          ),
        );
      }
      final LatLng result = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );
      return Right(result);
    } on NoResultFoundException {
      return const Left(
        NotFoundFailure(message: 'No coordinates found for the given address'),
      );
    } on PlatformException {
      return const Left(
        ServiceUnavailableFailure(message: 'Geocoding service error'),
      );
    } catch (e) {
      return const Left(
        UnexpectedFailure(message: 'An unexpected error occurred'),
      );
    }
  }
}
