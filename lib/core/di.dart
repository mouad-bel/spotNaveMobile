import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/core/platform/geocoding_info.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_notification_data_source.dart';

import 'package:spotnav/data/data_sources/local/saved_destination_local_data_source.dart';
import 'package:spotnav/data/data_sources/local/session_local_data_source.dart';
import 'package:spotnav/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:spotnav/data/data_sources/remote/destination_remote_data_source.dart';
import 'package:spotnav/data/repositories/auth_repository.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:spotnav/data/repositories/firebase_notification_repository.dart';
import 'package:spotnav/data/repositories/saved_destination_repository.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'package:spotnav/data/services/destination_notification_trigger.dart';
import 'package:spotnav/presentation/home/bloc/popular_destination_bloc.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// Cubit/BLoC
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => PopularDestinationBloc(destinationRepository: sl()));
  sl.registerFactory(() => SavedDestinationsBloc(repository: sl()));
  sl.registerFactory(() => NotificationBloc(repository: sl(), firebaseAuth: sl()));

  /// Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<DestinationRepository>(
    () => DestinationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<SavedDestinationRepository>(
    () => SavedDestinationRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<FirebaseNotificationRepository>(
    () => FirebaseNotificationRepositoryImpl(
      notificationDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  /// Services
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(
      repository: sl(),
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<DestinationNotificationTrigger>(
    () => DestinationNotificationTrigger(
      notificationService: sl(),
      firestore: sl(),
    ),
  );

  /// Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<SessionLocalDataSource>(
    () => SessionLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<DestinationRemoteDataSource>(
    () => DestinationRemoteDataSourceImpl(
      client: sl(),
      sessionLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<SavedDestinationLocalDataSource>(
    () => SavedDestinationLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<FirebaseNotificationDataSource>(
    () => FirebaseNotificationDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  /// Platforms
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );
  sl.registerLazySingleton<GeocodingInfo>(
    () => GeocodingInfoImpl(networkInfo: sl()),
  );

  /// External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
