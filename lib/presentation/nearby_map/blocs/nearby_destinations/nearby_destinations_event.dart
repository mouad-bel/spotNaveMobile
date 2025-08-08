part of 'nearby_destinations_bloc.dart';

sealed class NearbyDestinationsEvent extends Equatable {
  const NearbyDestinationsEvent();

  @override
  List<Object> get props => [];
}

final class FetchNearbyDestinationsEvent extends NearbyDestinationsEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const FetchNearbyDestinationsEvent({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  @override
  List<Object> get props => [latitude, longitude, radius];
}

final class StartListeningToNearbyDestinationsEvent extends NearbyDestinationsEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const StartListeningToNearbyDestinationsEvent({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  @override
  List<Object> get props => [latitude, longitude, radius];
}

final class StopListeningToNearbyDestinationsEvent extends NearbyDestinationsEvent {
  const StopListeningToNearbyDestinationsEvent();
}
