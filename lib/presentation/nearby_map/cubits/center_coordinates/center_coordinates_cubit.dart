import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/geocoding_info.dart';

part 'center_coordinates_state.dart';

class CenterCoordinatesCubit extends Cubit<CenterCoordinatesState> {
  static final _logger = Logger('CenterCoordinateCubit');

  final GeocodingInfo _geocodingInfo;

  CenterCoordinatesCubit({required GeocodingInfo geocodingInfo})
    : _geocodingInfo = geocodingInfo,
      super(const CenterCoordinatesInitial()) {
    _logger.info(
      'CenterCoordinateCubit initialized with initial coordinates: ${state.coordinates?.latitude}, ${state.coordinates?.longitude}',
    );
  }

  Future<void> updateCoordinatesFromAddress(String address) async {
    _logger.info('Attempting to update coordinates from address: $address');

    emit(const CenterCoordinatesLoading());

    final result = await _geocodingInfo.getCoordinatesFromAddress(address);
    result.fold(
      (failure) {
        _logger.severe(
          'Failed to get coordinates from address "$address": ${failure.message}',
          failure,
        );
        
        emit(CenterCoordinatesFailed(failure: failure));
      },
      (newCoordinates) {
        _logger.info(
          'Coordinates from address determined: ${newCoordinates.latitude}, ${newCoordinates.longitude}',
        );
        
        emit(CenterCoordinatesUpdated(coordinates: newCoordinates));
      },
    );
  }
}
