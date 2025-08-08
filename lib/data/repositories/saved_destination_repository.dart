import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/data/data_sources/local/saved_destination_local_data_source.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class SavedDestinationRepository {
  Future<Either<Failure, void>> save(SavedDestinationModel destination);
  Future<Either<Failure, void>> remove(String destinationId);
  Future<Either<Failure, List<SavedDestinationModel>>> fetchSaved();
  Future<Either<Failure, bool>> isSaved(String destinationId);
}

class SavedDestinationRepositoryImpl implements SavedDestinationRepository {
  final SavedDestinationLocalDataSource _savedLocalDataSource;

  const SavedDestinationRepositoryImpl({
    required SavedDestinationLocalDataSource localDataSource,
  }) : _savedLocalDataSource = localDataSource;

  @override
  Future<Either<Failure, void>> save(SavedDestinationModel destination) async {
    try {
      await _savedLocalDataSource.save(destination);
      return const Right(null);
    } on CacheException {
      return const Left(
        CacheFailure(
          message:
              'Failed to save to your saved destinations. Please try again.',
        ),
      );
    } on DataParsingException {
      return const Left(
        CacheFailure(
          message:
              'Something went wrong saving this item. The app encountered an unexpected issue.',
        ),
      );
    } on Exception {
      return const Left(
        UnexpectedFailure(
          message:
              'An unexpected problem occurred while saving. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> remove(String destinationId) async {
    try {
      await _savedLocalDataSource.remove(destinationId);
      return const Right(null);
    } on CacheException {
      return const Left(
        CacheFailure(
          message:
              'Couldn\'t remove from your saved destinations. Please try again.',
        ),
      );
    } on DataParsingException {
      return const Left(
        CacheFailure(
          message:
              'Something went wrong removing this item. The app encountered an unexpected issue.',
        ),
      );
    } on Exception {
      return const Left(
        UnexpectedFailure(
          message:
              'An unexpected problem occurred while removing. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<SavedDestinationModel>>> fetchSaved() async {
    try {
      final savedDestinations = await _savedLocalDataSource.fetchSaved();
      return Right(savedDestinations);
    } on CacheException {
      return const Left(
        CacheFailure(
          message: 'Failed to load your saved destinations. Please try again.',
        ),
      );
    } on DataParsingException {
      return const Left(
        CacheFailure(
          message:
              'There was a problem reading your saved destinations. Data might be corrupted.',
        ),
      );
    } on Exception {
      return const Left(
        UnexpectedFailure(
          message:
              'An unexpected problem occurred while fetching saved items. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isSaved(String destinationId) async {
    try {
      final isItSaved = await _savedLocalDataSource.isSaved(destinationId);
      return Right(isItSaved);
    } on CacheException {
      return const Left(
        CacheFailure(
          message: 'Couldn\'t check if this is saved. Please try again.',
        ),
      );
    } on DataParsingException {
      return const Left(
        CacheFailure(
          message:
              'There was a problem verifying this item\'s status. Please try again.',
        ),
      );
    } on Exception {
      return const Left(
        UnexpectedFailure(
          message:
              'An unexpected problem occurred while checking status. Please try again later.',
        ),
      );
    }
  }
}
