part of 'is_saved_destination_bloc.dart';

sealed class IsSavedDestinationEvent extends Equatable {
  const IsSavedDestinationEvent();

  @override
  List<Object> get props => [];
}

final class ToggleIsSavedStatusEvent extends IsSavedDestinationEvent {
  final SavedDestinationModel destination;
  final bool isCurrentlySaved;

  const ToggleIsSavedStatusEvent({
    required this.destination,
    required this.isCurrentlySaved,
  });

  @override
  List<Object> get props => [destination, isCurrentlySaved];
}

final class CheckIsSavedStatusEvent extends IsSavedDestinationEvent {
  final String destinationId;

  const CheckIsSavedStatusEvent({required this.destinationId});

  @override
  List<Object> get props => [destinationId];
}
