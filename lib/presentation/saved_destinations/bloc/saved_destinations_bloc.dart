import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:spotnav/data/repositories/saved_destination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'saved_destinations_event.dart';
part 'saved_destinations_state.dart';

class SavedDestinationsBloc
    extends Bloc<SavedDestinationsEvent, SavedDestinationsState> {
  static final _logger = Logger('SavedDestinationsBloc');

  final SavedDestinationRepository _repository;

  SavedDestinationsBloc({required SavedDestinationRepository repository})
    : _repository = repository,
      super(SavedDestinationsInitial()) {
    _logger.info('SavedDestinationsBloc initialized.');

    on<FetchSavedDestinationsEvent>(_fetchSavedDestinations);
    on<RemoveSavedDestinationEvent>(_removeSavedDestination);
  }

  Future<void> _fetchSavedDestinations(
    FetchSavedDestinationsEvent event,
    Emitter<SavedDestinationsState> emit,
  ) async {
    _logger.info('Event received: FetchSavedDestinationsEvent');
    emit(SavedDestinationsLoading());
    _logger.info('Emitted SavedDestinationsLoading state.');

    final result = await _repository.fetchSaved();
    result.fold(
      (failure) {
        _logger.severe(
          'Failed to fetch saved destinations: ${failure.message}',
          failure,
        );
        emit(SavedDestinationsFailed(failure: failure));
      },
      (destinations) {
        _logger.info(
          'Successfully fetched ${destinations.length} saved destinations.',
        );
        emit(SavedDestinationsLoaded(destinations: destinations));
      },
    );
  }

  Future<void> _removeSavedDestination(
    RemoveSavedDestinationEvent event,
    Emitter<SavedDestinationsState> emit,
  ) async {
    _logger.info(
      'Event received: RemoveSavedDestinationEvent for ID: ${event.destinationId}',
    );

    final result = await _repository.remove(event.destinationId);
    result.fold(
      (failure) {
        _logger.severe(
          'Failed to remove destination ${event.destinationId}: ${failure.message}',
          failure,
        );
        emit(SavedDestinationsFailed(failure: failure));
      },
      (_) {
        _logger.info(
          'Successfully removed destination ID: ${event.destinationId}. Re-fetching list.',
        );
        add(const FetchSavedDestinationsEvent());
        emit(
          SavedDestinationRemovedSuccess(
            message: 'Removed from saved destinations.',
            removedDestinationId: event.destinationId,
          ),
        );
      },
    );
  }
}
