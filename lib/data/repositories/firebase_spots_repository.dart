import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_spots_data_source.dart';
import 'package:spotnav/data/models/spot_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class FirebaseSpotsRepository {
  Future<Either<Failure, List<SpotModel>>> fetchPopular();
  Future<Either<Failure, List<SpotModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Either<Failure, SpotModel>> findById(String id);
  Future<Either<Failure, List<SpotModel>>> searchSpots(String query);
  Future<Either<Failure, List<SpotModel>>> fetchFeatured();
  Future<Either<Failure, List<SpotModel>>> fetchByCategory(String category);
}

class FirebaseSpotsRepositoryImpl implements FirebaseSpotsRepository {
  final FirebaseSpotsDataSource _spotsDataSource;
  final NetworkInfo _networkInfo;

  const FirebaseSpotsRepositoryImpl({
    required FirebaseSpotsDataSource spotsDataSource,
    required NetworkInfo networkInfo,
  }) : _spotsDataSource = spotsDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SpotModel>>> fetchPopular() async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final spots = await _spotsDataSource.fetchPopular();
      return right(spots);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SpotModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final spots = await _spotsDataSource.fetchNearby(
        latitude,
        longitude,
        radius,
      );
      return right(spots);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SpotModel>> findById(String id) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final spot = await _spotsDataSource.findById(id);
      return right(spot);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SpotModel>>> searchSpots(String query) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final spots = await _spotsDataSource.searchSpots(query);
      return right(spots);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SpotModel>>> fetchFeatured() async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final spots = await _spotsDataSource.fetchFeatured();
      return right(spots);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SpotModel>>> fetchByCategory(String category) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final spots = await _spotsDataSource.fetchByCategory(category);
      return right(spots);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
} 
