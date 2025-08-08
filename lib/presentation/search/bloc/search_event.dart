part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChangedEvent extends SearchEvent {
  final String query;

  const SearchQueryChangedEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class SearchSubmittedEvent extends SearchEvent {
  final String query;

  const SearchSubmittedEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
} 