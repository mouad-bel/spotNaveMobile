import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:spotnav/data/repositories/saved_destination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

part 'is_saved_destination_event.dart';
part 'is_saved_destination_state.dart';

class IsSavedDestinationBloc
    extends Bloc<IsSavedDestinationEvent, IsSavedDestinationState> {
  static final _logger = Logger('IsSavedDestinationBloc');

  final SavedDestinationRepository _repository;

  IsSavedDestinationBloc({required SavedDestinationRepository repository})
    : _repository = repository,
      super(const IsSavedDestinationInitial()) {
    _logger.info('IsSavedDestinationBloc initialized.');
    on<ToggleIsSavedStatusEvent>(_toggleIsSavedStatus);
    on<CheckIsSavedStatusEvent>(_checkIsSavedStatus);
  }

  Future<void> _toggleIsSavedStatus(
    ToggleIsSavedStatusEvent event,
    Emitter<IsSavedDestinationState> emit,
  ) async {
    _logger.info(
      'Event received: ToggleIsSavedStatusEvent for ID: ${event.destination.id}, current status: ${event.isCurrentlySaved}',
    );
    emit(IsSavedDestinationLoading(destinationId: event.destination.id));

    final Either<Failure, void> result;
    bool newStatus;

    if (event.isCurrentlySaved) {
      result = await _repository.remove(event.destination.id);
      newStatus = false;
    } else {
      result = await _repository.save(event.destination);
      newStatus = true;
    }

    result.fold(
      (failure) {
        _logger.severe(
          'Failed to toggle saved status for ID: ${event.destination.id}. Failure: ${failure.message}',
          failure,
        );
        emit(
          IsSavedDestinationFailed(
            failure: failure,
            destinationId: event.destination.id,
          ),
        );
      },
      (_) {
        _logger.info(
          'Successfully toggled saved status for ID: ${event.destination.id} to: $newStatus.',
        );
        emit(
          IsSavedDestinationOperationSuccess(
            message: newStatus ? 'Saved!' : 'Removed!',
            destinationId: event.destination.id,
            isSaved: newStatus,
          ),
        );
      },
    );
  }

  Future<void> _checkIsSavedStatus(
    CheckIsSavedStatusEvent event,
    Emitter<IsSavedDestinationState> emit,
  ) async {
    _logger.info(
      'Event received: CheckIsSavedStatusEvent for ID: ${event.destinationId}',
    );
    emit(IsSavedDestinationLoading(destinationId: event.destinationId));

    final result = await _repository.isSaved(event.destinationId);
    result.fold(
      (failure) {
        _logger.severe(
          'Failed to check saved status for ID: ${event.destinationId}. Failure: ${failure.message}',
          failure,
        );
        emit(
          IsSavedDestinationFailed(
            failure: failure,
            destinationId: event.destinationId,
          ),
        );
      },
      (isSaved) {
        _logger.info(
          'Checked saved status for ID: ${event.destinationId} is: $isSaved.',
        );
        emit(
          IsSavedDestinationStatusLoaded(
            destinationId: event.destinationId,
            isSaved: isSaved,
          ),
        );
      },
    );
  }
}
