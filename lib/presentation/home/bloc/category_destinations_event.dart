part of 'category_destinations_bloc.dart';

abstract class CategoryDestinationsEvent extends Equatable {
  const CategoryDestinationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoryDestinationsEvent extends CategoryDestinationsEvent {
  final String category;

  const FetchCategoryDestinationsEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

class RefreshCategoryDestinationsEvent extends CategoryDestinationsEvent {
  final String category;

  const RefreshCategoryDestinationsEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

class StartListeningToCategoryDestinationsEvent extends CategoryDestinationsEvent {
  final String category;

  const StartListeningToCategoryDestinationsEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

class StopListeningToCategoryDestinationsEvent extends CategoryDestinationsEvent {
  const StopListeningToCategoryDestinationsEvent();
} 