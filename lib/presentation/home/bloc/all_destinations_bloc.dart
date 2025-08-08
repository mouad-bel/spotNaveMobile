import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async';

// Events
abstract class AllDestinationsEvent extends Equatable {
  const AllDestinationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllDestinationsEvent extends AllDestinationsEvent {
  const FetchAllDestinationsEvent();
}

class RefreshAllDestinationsEvent extends AllDestinationsEvent {
  const RefreshAllDestinationsEvent();
}

class StartListeningToAllDestinationsEvent extends AllDestinationsEvent {
  const StartListeningToAllDestinationsEvent();
}

class StopListeningToAllDestinationsEvent extends AllDestinationsEvent {
  const StopListeningToAllDestinationsEvent();
}

// States
abstract class AllDestinationsState extends Equatable {
  const AllDestinationsState();

  @override
  List<Object?> get props => [];
}

class AllDestinationsInitial extends AllDestinationsState {
  const AllDestinationsInitial();
}

class AllDestinationsLoading extends AllDestinationsState {
  const AllDestinationsLoading();
}

class AllDestinationsLoaded extends AllDestinationsState {
  final List<DestinationModel> destinations;

  const AllDestinationsLoaded({required this.destinations});

  @override
  List<Object?> get props => [destinations];
}

class AllDestinationsFailed extends AllDestinationsState {
  final Failure failure;

  const AllDestinationsFailed({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// Bloc
class AllDestinationsBloc extends Bloc<AllDestinationsEvent, AllDestinationsState> {
  final DestinationRepository _repository;
  StreamSubscription<Either<Failure, List<DestinationModel>>>? _streamSubscription;

  AllDestinationsBloc({required DestinationRepository destinationRepository})
      : _repository = destinationRepository,
        super(const AllDestinationsInitial()) {
    on<FetchAllDestinationsEvent>(_fetchAllDestinations);
    on<RefreshAllDestinationsEvent>(_refreshAllDestinations);
    on<StartListeningToAllDestinationsEvent>(_startListeningToAllDestinations);
    on<StopListeningToAllDestinationsEvent>(_stopListeningToAllDestinations);
  }

  Future<void> _fetchAllDestinations(
    FetchAllDestinationsEvent event,
    Emitter<AllDestinationsState> emit,
  ) async {
    // Avoid re-fetch if already loaded
    if (state is AllDestinationsLoaded) {
      return;
    }

    emit(const AllDestinationsLoading());

    final result = await _repository.fetchAll();
    result.fold(
      (failure) {
        emit(AllDestinationsFailed(failure: failure));
      },
      (destinations) {
        emit(AllDestinationsLoaded(destinations: destinations));
      },
    );
  }

  Future<void> _refreshAllDestinations(
    RefreshAllDestinationsEvent event,
    Emitter<AllDestinationsState> emit,
  ) async {
    emit(const AllDestinationsLoading());

    final result = await _repository.fetchAll();
    result.fold(
      (failure) {
        emit(AllDestinationsFailed(failure: failure));
      },
      (destinations) {
        emit(AllDestinationsLoaded(destinations: destinations));
      },
    );
  }

  Future<void> _startListeningToAllDestinations(
    StartListeningToAllDestinationsEvent event,
    Emitter<AllDestinationsState> emit,
  ) async {
    // Cancel any existing subscription
    await _streamSubscription?.cancel();

    emit(const AllDestinationsLoading());

    try {
      // First, get the initial data
      final initialResult = await _repository.fetchAll();
      initialResult.fold(
        (failure) {
          emit(AllDestinationsFailed(failure: failure));
        },
        (destinations) {
          emit(AllDestinationsLoaded(destinations: destinations));
        },
      );

      // Then start listening to real-time updates
      _streamSubscription = _repository.streamAll().listen(
        (result) async {
          if (!emit.isDone) {
            result.fold(
              (failure) {
                emit(AllDestinationsFailed(failure: failure));
              },
              (destinations) {
                emit(AllDestinationsLoaded(destinations: destinations));
              },
            );
          }
        },
      );
    } catch (e) {
      emit(AllDestinationsFailed(
        failure: UnexpectedFailure(message: e.toString()),
      ));
    }
  }

  Future<void> _stopListeningToAllDestinations(
    StopListeningToAllDestinationsEvent event,
    Emitter<AllDestinationsState> emit,
  ) async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
} 