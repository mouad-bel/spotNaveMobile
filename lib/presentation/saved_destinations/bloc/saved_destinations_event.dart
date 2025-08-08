part of 'saved_destinations_bloc.dart';

sealed class SavedDestinationsEvent extends Equatable {
  const SavedDestinationsEvent();

  @override
  List<Object> get props => [];
}

final class FetchSavedDestinationsEvent extends SavedDestinationsEvent {
  const FetchSavedDestinationsEvent();
}

final class RemoveSavedDestinationEvent extends SavedDestinationsEvent {
  final String destinationId;

  const RemoveSavedDestinationEvent({required this.destinationId});

  @override
  List<Object> get props => [destinationId];
}
