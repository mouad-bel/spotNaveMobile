part of 'saved_destinations_bloc.dart';

sealed class SavedDestinationsState extends Equatable {
  final List<SavedDestinationModel>? destinations;

  const SavedDestinationsState({this.destinations});

  @override
  List<Object?> get props => [destinations];
}

final class SavedDestinationsInitial extends SavedDestinationsState {}

final class SavedDestinationsLoading extends SavedDestinationsState {}

final class SavedDestinationsLoaded extends SavedDestinationsState {
  const SavedDestinationsLoaded({required super.destinations});
}

final class SavedDestinationRemovedSuccess extends SavedDestinationsState {
  final String message;
  final String removedDestinationId;

  const SavedDestinationRemovedSuccess({
    required this.message,
    required this.removedDestinationId,
  });

  @override
  List<Object> get props => [message, removedDestinationId];
}

final class SavedDestinationsFailed extends SavedDestinationsState {
  final Failure failure;

  const SavedDestinationsFailed({required this.failure});

  @override
  List<Object> get props => [failure];
}
