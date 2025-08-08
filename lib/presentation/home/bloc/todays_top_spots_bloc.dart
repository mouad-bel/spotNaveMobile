import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:spotnav/core/errors/failures.dart';

// Events
abstract class TodaysTopSpotsEvent {}

class FetchTodaysTopSpotsEvent extends TodaysTopSpotsEvent {}

class RefreshTodaysTopSpotsEvent extends TodaysTopSpotsEvent {}

class StartListeningToTodaysTopSpotsEvent extends TodaysTopSpotsEvent {}

class StopListeningToTodaysTopSpotsEvent extends TodaysTopSpotsEvent {}

class TodaysTopSpotsUpdatedEvent extends TodaysTopSpotsEvent {
  final List<DestinationModel> destinations;
  
  TodaysTopSpotsUpdatedEvent(this.destinations);
}

// States
abstract class TodaysTopSpotsState {}

class TodaysTopSpotsInitial extends TodaysTopSpotsState {}

class TodaysTopSpotsLoading extends TodaysTopSpotsState {}

class TodaysTopSpotsLoaded extends TodaysTopSpotsState {
  final List<DestinationModel> destinations;
  
  TodaysTopSpotsLoaded(this.destinations);
}

class TodaysTopSpotsError extends TodaysTopSpotsState {
  final String message;
  
  TodaysTopSpotsError(this.message);
}

// Bloc
class TodaysTopSpotsBloc extends Bloc<TodaysTopSpotsEvent, TodaysTopSpotsState> {
  final DestinationRepository _destinationRepository;
  StreamSubscription<dynamic>? _destinationSubscription;

  TodaysTopSpotsBloc({
    required DestinationRepository destinationRepository,
  })  : _destinationRepository = destinationRepository,
        super(TodaysTopSpotsInitial()) {
    on<FetchTodaysTopSpotsEvent>(_onFetchTodaysTopSpots);
    on<RefreshTodaysTopSpotsEvent>(_onRefreshTodaysTopSpots);
    on<StartListeningToTodaysTopSpotsEvent>(_onStartListening);
    on<StopListeningToTodaysTopSpotsEvent>(_onStopListening);
    on<TodaysTopSpotsUpdatedEvent>(_onTodaysTopSpotsUpdated);
  }

  Future<void> _onFetchTodaysTopSpots(
    FetchTodaysTopSpotsEvent event,
    Emitter<TodaysTopSpotsState> emit,
  ) async {
    emit(TodaysTopSpotsLoading());

    final result = await _destinationRepository.fetchTodaysTopSpots();
    
    result.fold(
      (failure) {
        emit(TodaysTopSpotsError(failure.message));
      },
      (destinations) {
        emit(TodaysTopSpotsLoaded(destinations));
      },
    );
  }

  Future<void> _onRefreshTodaysTopSpots(
    RefreshTodaysTopSpotsEvent event,
    Emitter<TodaysTopSpotsState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await _destinationRepository.fetchTodaysTopSpots();
    
    result.fold(
      (failure) => emit(TodaysTopSpotsError(failure.message)),
      (destinations) => emit(TodaysTopSpotsLoaded(destinations)),
    );
  }

  Future<void> _onStartListening(
    StartListeningToTodaysTopSpotsEvent event,
    Emitter<TodaysTopSpotsState> emit,
  ) async {
    // Cancel existing subscription
    await _destinationSubscription?.cancel();

    // Only emit loading if we don't already have data
    if (state is! TodaysTopSpotsLoaded) {
      emit(TodaysTopSpotsLoading());
    }

    _destinationSubscription = _destinationRepository.streamTodaysTopSpots().listen(
      (result) {
        result.fold(
          (failure) {
            if (!emit.isDone) {
              emit(TodaysTopSpotsError(failure.message));
            }
          },
          (destinations) {
            if (!emit.isDone) {
              emit(TodaysTopSpotsLoaded(destinations));
            }
          },
        );
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(TodaysTopSpotsError('Stream error: ${error.toString()}'));
        }
      },
    );
  }

  Future<void> _onStopListening(
    StopListeningToTodaysTopSpotsEvent event,
    Emitter<TodaysTopSpotsState> emit,
  ) async {
    await _destinationSubscription?.cancel();
    _destinationSubscription = null;
  }

  Future<void> _onTodaysTopSpotsUpdated(
    TodaysTopSpotsUpdatedEvent event,
    Emitter<TodaysTopSpotsState> emit,
  ) async {
    emit(TodaysTopSpotsLoaded(event.destinations));
  }

  @override
  Future<void> close() {
    _destinationSubscription?.cancel();
    return super.close();
  }
}