import 'package:get_it/get_it.dart';
import 'package:spotnav/core/services/firebase_service.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_auth_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_session_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_destination_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_saved_destination_data_source.dart';
import 'package:spotnav/data/repositories/firebase_auth_repository.dart';
import 'package:spotnav/data/repositories/firebase_destination_repository.dart';
import 'package:spotnav/data/repositories/firebase_saved_destination_repository.dart';

class FirebaseDI {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> initialize() async {
    // Initialize Firebase service
    await FirebaseService.instance.initialize();

    // Register Firebase data sources
    _getIt.registerLazySingleton<FirebaseAuthDataSource>(
      () => FirebaseService.instance.createAuthDataSource(),
    );

    _getIt.registerLazySingleton<FirebaseSessionDataSource>(
      () => FirebaseService.instance.createSessionDataSource(),
    );

    _getIt.registerLazySingleton<FirebaseDestinationDataSource>(
      () => FirebaseService.instance.createDestinationDataSource(),
    );

    _getIt.registerLazySingleton<FirebaseSavedDestinationDataSource>(
      () => FirebaseService.instance.createSavedDestinationDataSource(),
    );

    // Register Firebase repositories
    _getIt.registerLazySingleton<FirebaseAuthRepository>(
      () => FirebaseAuthRepositoryImpl(
        authDataSource: _getIt<FirebaseAuthDataSource>(),
        sessionDataSource: _getIt<FirebaseSessionDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    _getIt.registerLazySingleton<FirebaseDestinationRepository>(
      () => FirebaseDestinationRepositoryImpl(
        destinationDataSource: _getIt<FirebaseDestinationDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    _getIt.registerLazySingleton<FirebaseSavedDestinationRepository>(
      () => FirebaseSavedDestinationRepositoryImpl(
        savedDestinationDataSource: _getIt<FirebaseSavedDestinationDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );
  }

  // Helper methods to get Firebase repositories
  static FirebaseAuthRepository get authRepository => _getIt<FirebaseAuthRepository>();
  static FirebaseDestinationRepository get destinationRepository => _getIt<FirebaseDestinationRepository>();
  static FirebaseSavedDestinationRepository get savedDestinationRepository => _getIt<FirebaseSavedDestinationRepository>();
} 
