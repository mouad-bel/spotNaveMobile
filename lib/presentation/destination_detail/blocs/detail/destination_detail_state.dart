part of 'destination_detail_bloc.dart';

@immutable
sealed class DestinationDetailState extends Equatable {
  const DestinationDetailState();

  @override
  List<Object> get props => [];
}

final class DestinationDetailInitial extends DestinationDetailState {
  const DestinationDetailInitial();
}

final class DestinationDetailLoading extends DestinationDetailState {
  const DestinationDetailLoading();
}

final class DestinationDetailLoaded extends DestinationDetailState {
  final DestinationModel destination;

  const DestinationDetailLoaded({required this.destination});

  @override
  List<Object> get props => [destination];
}

final class DestinationDetailFailed extends DestinationDetailState {
  final Failure failure;

  const DestinationDetailFailed({required this.failure});

  @override
  List<Object> get props => [failure];
}
