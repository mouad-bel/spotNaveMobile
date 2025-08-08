import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/remote/destination_remote_data_source.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async';

abstract class DestinationRepository {
  Future<Either<Failure, List<DestinationModel>>> fetchPopular();
  Future<Either<Failure, List<DestinationModel>>> fetchAll();
  Future<Either<Failure, List<DestinationModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Either<Failure, DestinationModel>> findById(String id);
  Future<Either<Failure, List<DestinationModel>>> fetchByCategory(String category);
  Future<Either<Failure, List<DestinationModel>>> fetchTodaysTopSpots();
  Future<Either<Failure, List<DestinationModel>>> searchDestinations(String query);
  Future<Either<Failure, List<String>>> fetchAllCategories();
  Future<Either<Failure, List<DestinationModel>>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  });
  
  // Real-time streams for live updates
  Stream<Either<Failure, List<DestinationModel>>> streamPopular();
  Stream<Either<Failure, List<DestinationModel>>> streamAll();
  Stream<Either<Failure, List<DestinationModel>>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Stream<Either<Failure, DestinationModel?>> streamById(String id);
  Stream<Either<Failure, List<DestinationModel>>> streamByCategory(String category);
  Stream<Either<Failure, List<DestinationModel>>> streamTodaysTopSpots();
}

class DestinationRepositoryImpl implements DestinationRepository {
  final DestinationRemoteDataSource _destinationRemoteDataSource;
  final NetworkInfo _networkInfo;

  const DestinationRepositoryImpl({
    required DestinationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo,
       _destinationRemoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchAll() async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.fetchAll();
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchPopular() async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.fetchPopular();
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamAll() {
    // For the regular repository, we'll return a stream that emits the current data
    // This is a fallback since the remote data source doesn't support real-time updates
    return Stream.fromFuture(fetchAll());
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamPopular() {
    // For the regular repository, we'll return a stream that emits the current data
    // This is a fallback since the remote data source doesn't support real-time updates
    return Stream.fromFuture(fetchPopular());
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.fetchNearby(
        latitude,
        longitude,
        radius,
      );
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  ) {
    // For the regular repository, we'll return a stream that emits the current data
    return Stream.fromFuture(fetchNearby(latitude, longitude, radius));
  }

  @override
  Future<Either<Failure, DestinationModel>> findById(String id) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.findById(id);
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on NotFoundException {
      return const Left(NotFoundFailure(message: 'No Destination Found'));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, DestinationModel?>> streamById(String id) {
    // For the regular repository, we'll return a stream that emits the current data
    return Stream.fromFuture(findById(id)).map((result) => result.map((destination) => destination));
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchByCategory(String category) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.fetchByCategory(category);
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamByCategory(String category) {
    // For the regular repository, we'll return a stream that emits the current data
    return Stream.fromFuture(fetchByCategory(category));
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchTodaysTopSpots() async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.fetchTodaysTopSpots();
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamTodaysTopSpots() {
    // For the regular repository, we'll return a stream that emits the current data
    return Stream.fromFuture(fetchTodaysTopSpots());
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> searchDestinations(String query) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.searchDestinations(query);
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> fetchAllCategories() async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final categories = await _destinationRemoteDataSource.fetchAllCategories();
      return Right(categories);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  }) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final destinations = await _destinationRemoteDataSource.getSimilarDestinations(
        category: category,
        excludeDestinationId: excludeDestinationId,
      );
      return Right(destinations);
    } on NetworkException {
      return const Left(
        NetworkFailure(message: 'Failed to connect to the network'),
      );
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure(message: ''));
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error. Please try again'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred: ${e.toString()}',
        ),
      );
    }
  }
}
