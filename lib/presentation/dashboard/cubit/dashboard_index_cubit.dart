import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class DashboardIndexCubit extends Cubit<int> {
  static final _logger = Logger('DashboardIndexCubit');

  DashboardIndexCubit() : super(0) {
    _logger.info('DashboardIndexCubit initialized with state: $state}');
  }

  void update(int newIndex) {
    if (state == newIndex) {
      _logger.fine('Current index is already $newIndex, no update needed.');
      return;
    }
    _logger.info('Dashboard index updated from $state to new state: $newIndex');
    emit(newIndex);
  }
}
