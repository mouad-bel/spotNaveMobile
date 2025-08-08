part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({required this.query});

  @override
  List<Object> get props => [query];
}

class SearchLoaded extends SearchState {
  final List<DestinationModel> destinations;
  final String query;

  const SearchLoaded({
    required this.destinations,
    required this.query,
  });

  @override
  List<Object> get props => [destinations, query];
}

class SearchFailed extends SearchState {
  final Failure failure;
  final String query;

  const SearchFailed({
    required this.failure,
    required this.query,
  });

  @override
  List<Object> get props => [failure, query];
} 