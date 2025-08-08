import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static final _logger = Logger('SearchBloc');

  final DestinationRepository _repository;
  Timer? _debounceTimer;

  SearchBloc({required DestinationRepository destinationRepository})
    : _repository = destinationRepository,
      super(const SearchInitial()) {
    _logger.info('SearchBloc initialized.');
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<SearchSubmittedEvent>(_onSearchSubmitted);
    on<ClearSearchEvent>(_onClearSearch);
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<SearchState> emit,
  ) {
    _logger.info('Search query changed: ${event.query}');
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (event.query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // Emit loading state immediately
    emit(SearchLoading(query: event.query));

    // Debounce the search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(event.query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final result = await _repository.searchDestinations(query);
      
      result.fold(
        (failure) {
          _logger.warning('Search failed: ${failure.message}');
          add(SearchQueryChangedEvent(query: query)); // Re-trigger the event
        },
        (destinations) {
          _logger.info('Search completed with ${destinations.length} results');
          emit(SearchLoaded(
            destinations: destinations,
            query: query,
          ));
        },
      );
    } catch (e) {
      _logger.severe('Search error: $e');
      emit(SearchFailed(
        failure: ServerFailure(message: 'Search error: $e'),
        query: query,
      ));
    }
  }

  Future<void> _onSearchSubmitted(
    SearchSubmittedEvent event,
    Emitter<SearchState> emit,
  ) async {
    _logger.info('Search submitted: ${event.query}');
    
    // Cancel any pending debounce
    _debounceTimer?.cancel();
    
    if (event.query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchLoading(query: event.query));

    try {
      final result = await _repository.searchDestinations(event.query);
      
      if (!emit.isDone) {
        result.fold(
          (failure) {
            _logger.warning('Search failed: ${failure.message}');
            emit(SearchFailed(failure: failure, query: event.query));
          },
          (destinations) {
            _logger.info('Search completed with ${destinations.length} results');
            emit(SearchLoaded(
              destinations: destinations,
              query: event.query,
            ));
          },
        );
      }
    } catch (e) {
      _logger.severe('Search error: $e');
      if (!emit.isDone) {
        emit(SearchFailed(
          failure: ServerFailure(message: 'Search error: $e'),
          query: event.query,
        ));
      }
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    _logger.info('Clearing search');
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
} 