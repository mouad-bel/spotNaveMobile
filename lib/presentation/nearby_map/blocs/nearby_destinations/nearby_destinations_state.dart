part of 'nearby_destinations_bloc.dart';

@immutable
sealed class NearbyDestinationsState extends Equatable {
  const NearbyDestinationsState();

  @override
  List<Object> get props => [];
}

final class NearbyDestinationInitial extends NearbyDestinationsState {}

final class NearbyDestinationLoading extends NearbyDestinationsState {}

final class NearbyDestinationLoaded extends NearbyDestinationsState {
  final List<DestinationModel> destinations;

  const NearbyDestinationLoaded({required this.destinations});

  @override
  List<Object> get props => [destinations];
}

final class NearbyDestinationFailed extends NearbyDestinationsState {
  final Failure failure;

  const NearbyDestinationFailed({required this.failure});

  @override
  List<Object> get props => [failure];
}
