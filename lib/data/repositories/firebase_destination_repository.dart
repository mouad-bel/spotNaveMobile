import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_destination_data_source.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async';

abstract class FirebaseDestinationRepository {
  Future<Either<Failure, List<DestinationModel>>> fetchAll();
  Future<Either<Failure, List<DestinationModel>>> fetchPopular();
  Future<Either<Failure, List<DestinationModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Either<Failure, DestinationModel>> findById(String id);
  Future<Either<Failure, List<DestinationModel>>> searchDestinations(String query);
  Future<Either<Failure, List<DestinationModel>>> fetchByCategory(String category);
  Future<Either<Failure, List<DestinationModel>>> fetchTodaysTopSpots();
  Future<Either<Failure, List<String>>> fetchAllCategories();
  Future<Either<Failure, List<DestinationModel>>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  });
  
  // Real-time streams for live updates
  Stream<Either<Failure, List<DestinationModel>>> streamAll();
  Stream<Either<Failure, List<DestinationModel>>> streamPopular();
  Stream<Either<Failure, List<DestinationModel>>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Stream<Either<Failure, DestinationModel?>> streamById(String id);
  Stream<Either<Failure, List<DestinationModel>>> streamByCategory(String category);
  Stream<Either<Failure, List<DestinationModel>>> streamTodaysTopSpots();
}

class FirebaseDestinationRepositoryImpl implements FirebaseDestinationRepository {
  final FirebaseDestinationDataSource _destinationDataSource;
  final NetworkInfo _networkInfo;

  const FirebaseDestinationRepositoryImpl({
    required FirebaseDestinationDataSource destinationDataSource,
    required NetworkInfo networkInfo,
  }) : _destinationDataSource = destinationDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchAll() async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.fetchAll();
      return right(destinations);
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
  Stream<Either<Failure, List<DestinationModel>>> streamAll() {
    return _destinationDataSource.streamAll().map(
      (destinations) => right<Failure, List<DestinationModel>>(destinations),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    }).cast<Either<Failure, List<DestinationModel>>>();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchPopular() async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.fetchPopular();
      return right(destinations);
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
  Stream<Either<Failure, List<DestinationModel>>> streamPopular() {
    return _destinationDataSource.streamPopular().map(
      (destinations) => right<Failure, List<DestinationModel>>(destinations),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    }).cast<Either<Failure, List<DestinationModel>>>();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.fetchNearby(
        latitude,
        longitude,
        radius,
      );
      return right(destinations);
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
  Stream<Either<Failure, List<DestinationModel>>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  ) {
    return _destinationDataSource.streamNearby(latitude, longitude, radius).map(
      (destinations) => right<Failure, List<DestinationModel>>(destinations),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    }).cast<Either<Failure, List<DestinationModel>>>();
  }

  @override
  Future<Either<Failure, DestinationModel>> findById(String id) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destination = await _destinationDataSource.findById(id);
      return right(destination);
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
  Stream<Either<Failure, DestinationModel?>> streamById(String id) {
    return _destinationDataSource.streamById(id).map(
      (destination) => right<Failure, DestinationModel?>(destination),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    }).cast<Either<Failure, DestinationModel?>>();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> searchDestinations(String query) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.searchDestinations(query);
      return right(destinations);
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
  Future<Either<Failure, List<DestinationModel>>> fetchByCategory(String category) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.fetchByCategory(category);
      return right(destinations);
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
  Future<Either<Failure, List<DestinationModel>>> fetchTodaysTopSpots() async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.fetchTodaysTopSpots();
      return right(destinations);
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
  Stream<Either<Failure, List<DestinationModel>>> streamTodaysTopSpots() {
    return _destinationDataSource.streamTodaysTopSpots().map(
      (destinations) => right<Failure, List<DestinationModel>>(destinations),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamByCategory(String category) {
    return _destinationDataSource.streamByCategory(category).map(
      (destinations) => right<Failure, List<DestinationModel>>(destinations),
    ).handleError((error) {
      if (error is UnauthenticatedException) {
        return left(UnauthenticatedFailure(message: error.message));
      } else if (error is ServerException) {
        return left(ServerFailure(message: error.message));
      } else if (error is NetworkException) {
        return left(NetworkFailure(message: error.message));
      } else {
        return left(ServerFailure(message: 'Unexpected error: ${error.toString()}'));
      }
    }).cast<Either<Failure, List<DestinationModel>>>();
  }

  @override
  Future<Either<Failure, List<String>>> fetchAllCategories() async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final categories = await _destinationDataSource.fetchAllCategories();
      return right(categories);
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
  Future<Either<Failure, List<DestinationModel>>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  }) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final destinations = await _destinationDataSource.getSimilarDestinations(
        category: category,
        excludeDestinationId: excludeDestinationId,
      );
      return right(destinations);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
} 
