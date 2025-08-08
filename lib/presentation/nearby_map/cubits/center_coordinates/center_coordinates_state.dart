part of 'center_coordinates_cubit.dart';

sealed class CenterCoordinatesState extends Equatable {
  final LatLng? coordinates;

  const CenterCoordinatesState({this.coordinates});

  @override
  List<Object?> get props => [coordinates];
}

final class CenterCoordinatesInitial extends CenterCoordinatesState {
  const CenterCoordinatesInitial() : super(coordinates: null);
}

final class CenterCoordinatesLoading extends CenterCoordinatesState {
  const CenterCoordinatesLoading() : super(coordinates: null);
}

final class CenterCoordinatesUpdated extends CenterCoordinatesState {
  const CenterCoordinatesUpdated({required super.coordinates});

  @override
  List<Object?> get props => [coordinates];
}

final class CenterCoordinatesFailed extends CenterCoordinatesState {
  final Failure failure;

  const CenterCoordinatesFailed({required this.failure})
    : super(coordinates: null);

  @override
  List<Object?> get props => [failure];
}
