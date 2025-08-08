part of 'is_saved_destination_bloc.dart';

sealed class IsSavedDestinationState extends Equatable {
  final bool? isSaved;
  final String? destinationId;

  const IsSavedDestinationState({this.isSaved, this.destinationId});

  @override
  List<Object?> get props => [isSaved, destinationId];
}

final class IsSavedDestinationInitial extends IsSavedDestinationState {
  const IsSavedDestinationInitial();
}

final class IsSavedDestinationLoading extends IsSavedDestinationState {
  const IsSavedDestinationLoading({required super.destinationId});
}

final class IsSavedDestinationStatusLoaded extends IsSavedDestinationState {
  const IsSavedDestinationStatusLoaded({
    required super.destinationId,
    required super.isSaved,
  });
}

final class IsSavedDestinationOperationSuccess extends IsSavedDestinationState {
  final String message;

  const IsSavedDestinationOperationSuccess({
    required this.message,
    required super.destinationId,
    required super.isSaved,
  });

  @override
  List<Object?> get props => [message, isSaved, destinationId];
}

final class IsSavedDestinationFailed extends IsSavedDestinationState {
  final Failure failure;

  const IsSavedDestinationFailed({
    required this.failure,
    required super.destinationId,
  }) : super(isSaved: null);

  @override
  List<Object?> get props => [failure, destinationId];
}
