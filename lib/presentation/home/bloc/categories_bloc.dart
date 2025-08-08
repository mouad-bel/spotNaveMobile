import 'package:equatable/equatable.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  static final _logger = Logger('CategoriesBloc');

  final DestinationRepository _repository;

  CategoriesBloc({required DestinationRepository destinationRepository})
    : _repository = destinationRepository,
      super(const CategoriesInitial()) {
    _logger.info('CategoriesBloc initialized.');
    on<FetchCategoriesEvent>(_fetchCategories);
  }

  Future<void> _fetchCategories(
    FetchCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    _logger.info('Received FetchCategoriesEvent');

    emit(const CategoriesLoading());

    final result = await _repository.fetchAllCategories();
    result.fold(
      (failure) {
        _logger.warning('Failed to fetch categories: $failure');
        emit(CategoriesFailed(failure: failure));
      },
      (categories) {
        _logger.info('Successfully fetched ${categories.length} categories');
        emit(CategoriesLoaded(categories: categories));
      },
    );
  }
} 