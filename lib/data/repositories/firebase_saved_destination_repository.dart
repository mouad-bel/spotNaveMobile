import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_saved_destination_data_source.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class FirebaseSavedDestinationRepository {
  Future<Either<Failure, void>> save(SavedDestinationModel destination);
  Future<Either<Failure, void>> remove(String destinationId);
  Future<Either<Failure, List<SavedDestinationModel>>> fetchSaved();
  Future<Either<Failure, bool>> isSaved(String destinationId);
}

class FirebaseSavedDestinationRepositoryImpl implements FirebaseSavedDestinationRepository {
  final FirebaseSavedDestinationDataSource _savedDestinationDataSource;
  final NetworkInfo _networkInfo;

  const FirebaseSavedDestinationRepositoryImpl({
    required FirebaseSavedDestinationDataSource savedDestinationDataSource,
    required NetworkInfo networkInfo,
  }) : _savedDestinationDataSource = savedDestinationDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> save(SavedDestinationModel destination) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _savedDestinationDataSource.save(destination);
      return right(null);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String destinationId) async {
    try {
      await _savedDestinationDataSource.remove(destinationId);
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
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final savedDestinations = await _savedDestinationDataSource.fetchSaved();
      return right(savedDestinations);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isSaved(String destinationId) async {
    try {
      final isSaved = await _savedDestinationDataSource.isSaved(destinationId);
      return Right(isSaved);
    } on CacheException {
      return const Left(
        CacheFailure(
          message: 'Failed to check if destination is saved. Please try again.',
        ),
      );
    } on DataParsingException {
      return const Left(
        CacheFailure(
          message:
              'Something went wrong checking this item. The app encountered an unexpected issue.',
        ),
      );
    } on Exception {
      return const Left(
        UnexpectedFailure(
          message:
              'An unexpected problem occurred while checking. Please try again later.',
        ),
      );
    }
  }
} 
