part of 'category_destinations_bloc.dart';

abstract class CategoryDestinationsState extends Equatable {
  const CategoryDestinationsState();

  @override
  List<Object?> get props => [];
}

class CategoryDestinationsInitial extends CategoryDestinationsState {
  const CategoryDestinationsInitial();
}

class CategoryDestinationsLoading extends CategoryDestinationsState {
  final String category;

  const CategoryDestinationsLoading({required this.category});

  @override
  List<Object?> get props => [category];
}

class CategoryDestinationsLoaded extends CategoryDestinationsState {
  final List<DestinationModel> destinations;
  final String category;

  const CategoryDestinationsLoaded({
    required this.destinations,
    required this.category,
  });

  @override
  List<Object?> get props => [destinations, category];
}

class CategoryDestinationsFailed extends CategoryDestinationsState {
  final Failure failure;
  final String category;

  const CategoryDestinationsFailed({
    required this.failure,
    required this.category,
  });

  @override
  List<Object?> get props => [failure, category];
} 