import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/core/platform/geocoding_info.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_auth_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_session_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_destination_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_saved_destination_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_spots_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_subscription_data_source.dart';
import 'package:spotnav/data/repositories/firebase_auth_repository.dart';
import 'package:spotnav/data/repositories/firebase_destination_repository.dart';
import 'package:spotnav/data/repositories/firebase_saved_destination_repository.dart';
import 'package:spotnav/data/repositories/firebase_spots_repository.dart';
import 'package:spotnav/data/repositories/subscription_repository.dart';
import 'package:spotnav/data/repositories/firebase_repository_adapters.dart';
import 'package:spotnav/data/repositories/auth_repository.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:spotnav/data/repositories/saved_destination_repository.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_notification_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_storage_data_source.dart';
import 'package:spotnav/data/repositories/firebase_notification_repository.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'package:spotnav/data/services/notification_trigger_manager.dart';
import 'package:spotnav/data/services/destination_notification_trigger.dart';
import 'package:spotnav/presentation/home/bloc/popular_destination_bloc.dart';
import 'package:spotnav/presentation/home/bloc/all_destinations_bloc.dart';
import 'package:spotnav/presentation/home/bloc/todays_top_spots_bloc.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:spotnav/presentation/destination_detail/blocs/is_saved/is_saved_destination_bloc.dart';
import 'package:spotnav/presentation/search/bloc/search_bloc.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotnav/firebase_options.dart';

final sl = GetIt.instance;

Future<void> initFirebase() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Cubit/BLoC
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => PopularDestinationBloc(destinationRepository: sl()));
  sl.registerFactory(() => AllDestinationsBloc(destinationRepository: sl()));
  sl.registerFactory(() => SavedDestinationsBloc(repository: sl()));
  sl.registerFactory(() => NotificationBloc(repository: sl(), firebaseAuth: sl()));
  sl.registerFactory(() => IsSavedDestinationBloc(repository: sl()));
  sl.registerFactory(() => TodaysTopSpotsBloc(destinationRepository: sl()));
  sl.registerFactory(() => SearchBloc(destinationRepository: sl()));
  sl.registerFactory(() => ThemeBloc());

  /// Firebase Repositories (using adapters for compatibility)
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepositoryAdapter(sl()),
  );
  sl.registerLazySingleton<DestinationRepository>(
    () => FirebaseDestinationRepositoryAdapter(sl()),
  );
  sl.registerLazySingleton<SavedDestinationRepository>(
    () => FirebaseSavedDestinationRepositoryAdapter(sl()),
  );

  /// Firebase Repository Implementations
  sl.registerLazySingleton<FirebaseAuthRepository>(
    () => FirebaseAuthRepositoryImpl(
      authDataSource: sl(),
      sessionDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseDestinationRepository>(
    () => FirebaseDestinationRepositoryImpl(
      destinationDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseSavedDestinationRepository>(
    () => FirebaseSavedDestinationRepositoryImpl(
      savedDestinationDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseSpotsRepository>(
    () => FirebaseSpotsRepositoryImpl(
      spotsDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      subscriptionDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseNotificationRepository>(
    () => FirebaseNotificationRepositoryImpl(
      notificationDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  /// Firebase Data Sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      storageDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseSessionDataSource>(
    () => FirebaseSessionDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseDestinationDataSource>(
    () => FirebaseDestinationDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseSavedDestinationDataSource>(
    () => FirebaseSavedDestinationDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseSpotsDataSource>(
    () => FirebaseSpotsDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseSubscriptionDataSource>(
    () => FirebaseSubscriptionDataSourceImpl(
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

  /// Firebase Services
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<FirebaseNotificationDataSource>(
    () => FirebaseNotificationDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseStorageDataSource>(
    () => FirebaseStorageDataSourceImpl(
      storage: sl(),
    ),
  );

  /// Notification Services
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(
      repository: sl(),
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationTriggerManager>(
    () => NotificationTriggerManager(
      notificationService: sl(),
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
} 
