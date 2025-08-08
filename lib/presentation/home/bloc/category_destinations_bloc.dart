import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:fpdart/fpdart.dart';

part 'category_destinations_event.dart';
part 'category_destinations_state.dart';

class CategoryDestinationsBloc
    extends Bloc<CategoryDestinationsEvent, CategoryDestinationsState> {
  static final _logger = Logger('CategoryDestinationsBloc');

  final DestinationRepository _repository;
  StreamSubscription<Either<Failure, List<DestinationModel>>>? _streamSubscription;

  CategoryDestinationsBloc({required DestinationRepository destinationRepository})
    : _repository = destinationRepository,
      super(const CategoryDestinationsInitial()) {
    _logger.info('CategoryDestinationsBloc initialized.');
    on<FetchCategoryDestinationsEvent>(_fetchCategoryDestinations);
    on<RefreshCategoryDestinationsEvent>(_refreshCategoryDestinations);
    on<StartListeningToCategoryDestinationsEvent>(_startListeningToCategoryDestinations);
    on<StopListeningToCategoryDestinationsEvent>(_stopListeningToCategoryDestinations);
  }

  Future<void> _fetchCategoryDestinations(
    FetchCategoryDestinationsEvent event,
    Emitter<CategoryDestinationsState> emit,
  ) async {
    _logger.info('Received FetchCategoryDestinationsEvent for category: ${event.category}');

    /// avoid re-fetch if already loaded for the same category
    if (state is CategoryDestinationsLoaded && 
        (state as CategoryDestinationsLoaded).category == event.category) {
      _logger.info('State is CategoryDestinationsLoaded for same category, skipping re-fetch.');
      return;
    }

    _logger.fine('Emitting CategoryDestinationsLoading state.');
    emit(CategoryDestinationsLoading(category: event.category));

    final result = await _repository.fetchByCategory(event.category);
    result.fold(
      (failure) {
        _logger.warning('Failed to fetch category destinations: $failure');
        emit(CategoryDestinationsFailed(failure: failure, category: event.category));
      },
      (destinations) {
        _logger.info(
          'Successfully fetched ${destinations.length} destinations for category: ${event.category}',
        );
        emit(CategoryDestinationsLoaded(destinations: destinations, category: event.category));
      },
    );
  }

  Future<void> _refreshCategoryDestinations(
    RefreshCategoryDestinationsEvent event,
    Emitter<CategoryDestinationsState> emit,
  ) async {
    _logger.info('Received RefreshCategoryDestinationsEvent for category: ${event.category}');

    _logger.fine('Emitting CategoryDestinationsLoading state for refresh.');
    emit(CategoryDestinationsLoading(category: event.category));

    final result = await _repository.fetchByCategory(event.category);
    result.fold(
      (failure) {
        _logger.warning('Failed to refresh category destinations: $failure');
        emit(CategoryDestinationsFailed(failure: failure, category: event.category));
      },
      (destinations) {
        _logger.info(
          'Successfully refreshed ${destinations.length} destinations for category: ${event.category}',
        );
        emit(CategoryDestinationsLoaded(destinations: destinations, category: event.category));
      },
    );
  }

  Future<void> _startListeningToCategoryDestinations(
    StartListeningToCategoryDestinationsEvent event,
    Emitter<CategoryDestinationsState> emit,
  ) async {
    _logger.info('Starting to listen to category destinations stream for: ${event.category}');

    // Cancel any existing subscription
    await _streamSubscription?.cancel();
    
    //print('DEBUG: Category BLoC emitting loading state for ${event.category}');
    emit(CategoryDestinationsLoading(category: event.category));

    try {
      // First, get the initial data
      final initialResult = await _repository.fetchByCategory(event.category);
      initialResult.fold(
        (failure) {
          //print('DEBUG: Category BLoC emitting failed state: ${failure.message}');
          emit(CategoryDestinationsFailed(failure: failure, category: event.category));
        },
        (destinations) {
          //print('DEBUG: Category BLoC emitting loaded state with ${destinations.length} destinations');
          emit(CategoryDestinationsLoaded(destinations: destinations, category: event.category));
        },
      );

      // Then start listening to real-time updates
      _streamSubscription = _repository.streamByCategory(event.category).listen(
        (result) {
          //print('DEBUG: Category BLoC received stream update: ${result.runtimeType}');
          result.fold(
            (failure) {
              //print('DEBUG: Category BLoC stream failed: ${failure.message}');
              // Don't emit on stream failure, just log it
            },
            (destinations) {
              //print('DEBUG: Category BLoC stream update with ${destinations.length} destinations');
              // Only emit if the BLoC is still active
              if (!emit.isDone) {
                emit(CategoryDestinationsLoaded(destinations: destinations, category: event.category));
              }
            },
          );
        },
        onError: (error) {
          //print('DEBUG: Category BLoC stream error: $error');
          // Don't emit on stream error, just log it
        },
        cancelOnError: false,
      );
    } catch (error) {
      //print('DEBUG: Category BLoC error: $error');
      emit(CategoryDestinationsFailed(
        failure: ServerFailure(message: 'Error: ${error.toString()}'),
        category: event.category,
      ));
    }
  }

  Future<void> _stopListeningToCategoryDestinations(
    StopListeningToCategoryDestinationsEvent event,
    Emitter<CategoryDestinationsState> emit,
  ) async {
    _logger.info('Received StopListeningToCategoryDestinationsEvent.');
    
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    
    _logger.info('Stopped listening to category destinations stream.');
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
} 