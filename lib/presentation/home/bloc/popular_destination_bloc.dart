import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:fpdart/fpdart.dart';

part 'popular_destination_event.dart';
part 'popular_destination_state.dart';

class PopularDestinationBloc
    extends Bloc<PopularDestinationEvent, PopularDestinationState> {
  static final _logger = Logger('PopularDestinationBloc');

  final DestinationRepository _repository;
  StreamSubscription<Either<Failure, List<DestinationModel>>>? _streamSubscription;

  PopularDestinationBloc({required DestinationRepository destinationRepository})
    : _repository = destinationRepository,
      super(const PopularDestinationInitial()) {
    _logger.info('PopularDestinationBloc initialized.');
    on<FetchPopularDestinationsEvent>(_fetchPopularDestination);
    on<RefreshPopularDestinationsEvent>(_refreshPopularDestination);
    on<StartListeningToPopularDestinationsEvent>(_startListeningToPopularDestinations);
    on<StopListeningToPopularDestinationsEvent>(_stopListeningToPopularDestinations);
  }

  Future<void> _fetchPopularDestination(
    FetchPopularDestinationsEvent event,
    Emitter<PopularDestinationState> emit,
  ) async {
    _logger.info('Received FetchPopularDestinationsEvent.');

    /// avoid re-fetch if already loaded
    if (state is PopularDestinationLoaded) {
      _logger.info('State is PopularDestinationLoaded, skipping re-fetch.');
      return;
    }

    _logger.fine('Emitting PopularDestinationLoading state.');
    emit(const PopularDestinationLoading());

    final result = await _repository.fetchPopular();
    result.fold(
      (failure) {
        _logger.warning('Failed to fetch popular destinations: $failure');
        emit(PopularDestinationFailed(failure: failure));
      },
      (destinations) {
        _logger.info(
          'Successfully fetched ${destinations.length} popular destinations.',
        );
        emit(PopularDestinationLoaded(destinations: destinations));
      },
    );
  }

  Future<void> _refreshPopularDestination(
    RefreshPopularDestinationsEvent event,
    Emitter<PopularDestinationState> emit,
  ) async {
    _logger.info('Received RefreshPopularDestinationsEvent.');

    _logger.fine('Emitting PopularDestinationLoading state for refresh.');
    emit(const PopularDestinationLoading());

    final result = await _repository.fetchPopular();
    result.fold(
      (failure) {
        _logger.warning('Failed to refresh popular destinations: $failure');
        emit(PopularDestinationFailed(failure: failure));
      },
      (destinations) {
        _logger.info(
          'Successfully refreshed ${destinations.length} popular destinations.',
        );
        emit(PopularDestinationLoaded(destinations: destinations));
      },
    );
  }

  Future<void> _startListeningToPopularDestinations(
    StartListeningToPopularDestinationsEvent event,
    Emitter<PopularDestinationState> emit,
  ) async {
    _logger.info('Starting to listen to destinations stream');

    // Cancel any existing subscription
    await _streamSubscription?.cancel();
    
    //print('DEBUG: BLoC emitting loading state');
    emit(const PopularDestinationLoading());

    // Use a different approach to avoid emit issues
    try {
      // First, get the initial data
      final initialResult = await _repository.fetchPopular();
      initialResult.fold(
        (failure) {
          //print('DEBUG: BLoC emitting failed state: ${failure.message}');
          emit(PopularDestinationFailed(failure: failure));
        },
        (destinations) {
          //print('DEBUG: BLoC emitting loaded state with ${destinations.length} destinations');
          emit(PopularDestinationLoaded(destinations: destinations));
        },
      );

      // Then start listening to real-time updates
      _streamSubscription = _repository.streamPopular().listen(
        (result) {
          //print('DEBUG: BLoC received stream update: ${result.runtimeType}');
          result.fold(
            (failure) {
              //print('DEBUG: BLoC stream failed: ${failure.message}');
              // Don't emit on stream failure, just log it
            },
            (destinations) {
              //print('DEBUG: BLoC stream update with ${destinations.length} destinations');
              // Only emit if the BLoC is still active
              if (!emit.isDone) {
                emit(PopularDestinationLoaded(destinations: destinations));
              }
            },
          );
        },
        onError: (error) {
          //print('DEBUG: BLoC stream error: $error');
          // Don't emit on stream error, just log it
        },
        cancelOnError: false,
      );
    } catch (error) {
      //print('DEBUG: BLoC error: $error');
      emit(PopularDestinationFailed(
        failure: ServerFailure(message: 'Error: ${error.toString()}'),
      ));
    }
  }

  Future<void> _stopListeningToPopularDestinations(
    StopListeningToPopularDestinationsEvent event,
    Emitter<PopularDestinationState> emit,
  ) async {
    _logger.info('Received StopListeningToPopularDestinationsEvent.');
    
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    
    _logger.info('Stopped listening to popular destinations stream.');
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
