import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';

// Events
abstract class SuggestedDestinationsEvent extends Equatable {
  const SuggestedDestinationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuggestedDestinations extends SuggestedDestinationsEvent {
  final String category;
  final String excludeDestinationId;

  const LoadSuggestedDestinations({
    required this.category,
    required this.excludeDestinationId,
  });

  @override
  List<Object?> get props => [category, excludeDestinationId];
}

// States
abstract class SuggestedDestinationsState extends Equatable {
  const SuggestedDestinationsState();

  @override
  List<Object?> get props => [];
}

class SuggestedDestinationsInitial extends SuggestedDestinationsState {}

class SuggestedDestinationsLoading extends SuggestedDestinationsState {}

class SuggestedDestinationsLoaded extends SuggestedDestinationsState {
  final List<DestinationModel> destinations;

  const SuggestedDestinationsLoaded(this.destinations);

  @override
  List<Object?> get props => [destinations];
}

class SuggestedDestinationsError extends SuggestedDestinationsState {
  final String message;

  const SuggestedDestinationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SuggestedDestinationsBloc extends Bloc<SuggestedDestinationsEvent, SuggestedDestinationsState> {
  final DestinationRepository _destinationRepository;

  SuggestedDestinationsBloc({
    required DestinationRepository destinationRepository,
  }) : _destinationRepository = destinationRepository,
       super(SuggestedDestinationsInitial()) {
    on<LoadSuggestedDestinations>(_onLoadSuggestedDestinations);
  }

  Future<void> _onLoadSuggestedDestinations(
    LoadSuggestedDestinations event,
    Emitter<SuggestedDestinationsState> emit,
  ) async {
    emit(SuggestedDestinationsLoading());
    
    print('🎯 BLoC: Loading suggested destinations');
    print('📂 Category: "${event.category}"');
    print('🚫 Exclude ID: ${event.excludeDestinationId}');

    final result = await _destinationRepository.getSimilarDestinations(
      category: event.category,
      excludeDestinationId: event.excludeDestinationId,
    );

    result.fold(
      (failure) {
        print('❌ BLoC: Error loading suggested destinations: ${failure.message}');
        emit(SuggestedDestinationsError(failure.message));
      },
      (destinations) {
        print('✅ BLoC: Successfully loaded ${destinations.length} suggested destinations');
        emit(SuggestedDestinationsLoaded(destinations));
      },
    );
  }
} 