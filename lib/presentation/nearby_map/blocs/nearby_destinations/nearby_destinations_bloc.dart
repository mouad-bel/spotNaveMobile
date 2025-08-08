import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart'; // Import repository directly
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:fpdart/fpdart.dart';

part 'nearby_destinations_event.dart';
part 'nearby_destinations_state.dart';

class NearbyDestinationsBloc
    extends Bloc<NearbyDestinationsEvent, NearbyDestinationsState> {
  static final _logger = Logger('NearbyDestinationBloc');

  final DestinationRepository _repository;
  StreamSubscription<Either<Failure, List<DestinationModel>>>? _streamSubscription;

  NearbyDestinationsBloc({required DestinationRepository repository})
    : _repository = repository,
      super(NearbyDestinationInitial()) {
    _logger.info('NearbyDestinationBloc initialized.');
    on<FetchNearbyDestinationsEvent>(_fetchNearbyDestinations);
    on<StartListeningToNearbyDestinationsEvent>(_startListeningToNearbyDestinations);
    on<StopListeningToNearbyDestinationsEvent>(_stopListeningToNearbyDestinations);
  }

  Future<void> _fetchNearbyDestinations(
    FetchNearbyDestinationsEvent event,
    Emitter<NearbyDestinationsState> emit,
  ) async {
    _logger.info(
      'Event received: FetchNearbyDestinationsEvent for lat: ${event.latitude}, lon: ${event.longitude}, radius: ${event.radius}',
    );
    emit(NearbyDestinationLoading());

    final result = await _repository.fetchNearby(
      event.latitude,
      event.longitude,
      event.radius,
    );
    result.fold(
      (failure) {
        _logger.severe(
          'Failed to fetch nearby destinations: ${failure.message}',
          failure,
        );
        emit(NearbyDestinationFailed(failure: failure));
      },
      (destinations) {
        _logger.info(
          'Successfully fetched ${destinations.length} nearby destinations.',
        );
        emit(NearbyDestinationLoaded(destinations: destinations));
      },
    );
  }

  Future<void> _startListeningToNearbyDestinations(
    StartListeningToNearbyDestinationsEvent event,
    Emitter<NearbyDestinationsState> emit,
  ) async {
    _logger.info(
      'Event received: StartListeningToNearbyDestinationsEvent for lat: ${event.latitude}, lon: ${event.longitude}, radius: ${event.radius}',
    );


    // Cancel any existing subscription
    await _streamSubscription?.cancel();
    
    emit(NearbyDestinationLoading());

    // Use direct fetch first, then start streaming
    final initialResult = await _repository.fetchNearby(
      event.latitude,
      event.longitude,
      event.radius,
    );
    
    initialResult.fold(
      (failure) {

        if (!emit.isDone) {
          emit(NearbyDestinationFailed(failure: failure));
        }
        return;
      },
      (destinations) {

        if (!emit.isDone) {
          emit(NearbyDestinationLoaded(destinations: destinations));
        }
      },
    );

    // Start listening to real-time updates
    _streamSubscription = _repository.streamNearby(
      event.latitude,
      event.longitude,
      event.radius,
    ).listen(
      (result) {

        if (!emit.isDone) {
          result.fold(
            (failure) {

              _logger.severe(
                'Failed to fetch nearby destinations from stream: ${failure.message}',
                failure,
              );
              emit(NearbyDestinationFailed(failure: failure));
            },
            (destinations) {

              _logger.info(
                'Successfully received ${destinations.length} nearby destinations from stream.',
              );
              emit(NearbyDestinationLoaded(destinations: destinations));
            },
          );
        }
      },
      onError: (error) {

        if (!emit.isDone) {
          _logger.severe('Error in nearby destinations stream: $error');
          emit(NearbyDestinationFailed(
            failure: ServerFailure(message: 'Stream error: ${error.toString()}'),
          ));
        }
      },
    );
  }

  Future<void> _stopListeningToNearbyDestinations(
    StopListeningToNearbyDestinationsEvent event,
    Emitter<NearbyDestinationsState> emit,
  ) async {
    _logger.info('Event received: StopListeningToNearbyDestinationsEvent.');
    
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    
    _logger.info('Stopped listening to nearby destinations stream.');
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
