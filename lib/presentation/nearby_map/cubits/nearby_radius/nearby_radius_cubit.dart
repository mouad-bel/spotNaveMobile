import 'package:spotnav/presentation/nearby_map/views/destination_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class NearbyRadiusCubit extends Cubit<double> {
  static final _logger = Logger('NearbyRadiusCubit');

  NearbyRadiusCubit() : super(DestinationMap.initialRadius) {
    _logger.info(
      'NearbyRadiusCubit initialized with radius: ${DestinationMap.initialRadius}',
    );
  }

  void update(double n) {
    _logger.fine('Updating nearby radius from $state to $n');
    emit(n);
  }
}
