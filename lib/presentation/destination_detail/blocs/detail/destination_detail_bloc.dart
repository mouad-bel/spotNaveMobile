import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'destination_detail_event.dart';
part 'destination_detail_state.dart';

class DestinationDetailBloc
    extends Bloc<DestinationDetailEvent, DestinationDetailState> {
  static final _logger = Logger('DestinationDetailBloc');

  final DestinationRepository _repository;

  DestinationDetailBloc({required DestinationRepository repository})
    : _repository = repository,
      super(const DestinationDetailInitial()) {
    _logger.info('DestinationDetailBloc initialized.');
    on<GetDestinationDetailEvent>(_getDestinationDetail);
  }

  Future<void> _getDestinationDetail(
    GetDestinationDetailEvent event,
    Emitter<DestinationDetailState> emit,
  ) async {
    _logger.info(
      'Event received: FetchDestinationDetailEvent for ID: ${event.id}',
    );
    emit(const DestinationDetailLoading());

    final result = await _repository.findById(event.id);
    result.fold(
      (failure) {
        _logger.severe(
          'Failed to fetch destination detail for ID: ${event.id}. Failure: ${failure.message}',
          failure,
        );
        emit(DestinationDetailFailed(failure: failure));
      },
      (destination) {
        _logger.info(
          'Successfully fetched destination detail for ID: ${event.id}.',
        );
        emit(DestinationDetailLoaded(destination: destination));
      },
    );
  }
}
