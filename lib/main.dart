import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/core/app_router.dart';
import 'package:spotnav/core/di_firebase.dart' as di;
import 'package:spotnav/presentation/home/bloc/popular_destination_bloc.dart';
import 'package:spotnav/presentation/home/bloc/todays_top_spots_bloc.dart';
import 'package:spotnav/presentation/home/bloc/all_destinations_bloc.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:spotnav/presentation/destination_detail/blocs/is_saved/is_saved_destination_bloc.dart';
import 'package:spotnav/presentation/search/bloc/search_bloc.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'package:spotnav/data/services/destination_notification_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase DI instead of regular DI
  await di.initFirebase();

  // Initialize notification service
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();

  // Initialize destination notification trigger
  final destinationNotificationTrigger = di.sl<DestinationNotificationTrigger>();
  await destinationNotificationTrigger.initialize();

  // Small delay to ensure notification trigger is fully set up
  await Future.delayed(const Duration(milliseconds: 500));

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('StackTrace: ${record.stackTrace}');
    }
  });

  if (Platform.isAndroid || Platform.isIOS) {
    // Set preferred orientations for mobile devices
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Lock to portrait mode, upright
      // DeviceOrientation.portraitDown, // Optional: if you also want upside down portrait
    ]);
  }

  // Start listening to notifications
  final notificationBloc = di.sl<NotificationBloc>();
  notificationBloc.add(StartListeningToNotificationsEvent());
  notificationBloc.add(LoadNotificationsEvent());

  // Theme will be auto-loaded when ThemeBloc is created

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthBloc _authBloc = di.sl<AuthBloc>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => _authBloc..add(AppStartedEvent()),
        ),
        BlocProvider<PopularDestinationBloc>(create: (context) => di.sl()),
        BlocProvider<AllDestinationsBloc>(create: (context) => di.sl()),
        BlocProvider<TodaysTopSpotsBloc>(create: (context) => di.sl()),
        BlocProvider<NotificationBloc>(create: (context) => di.sl()),
        BlocProvider<SavedDestinationsBloc>(create: (context) => di.sl()),
        BlocProvider<IsSavedDestinationBloc>(create: (context) => di.sl()),
        BlocProvider<SearchBloc>(create: (context) => di.sl()),
        BlocProvider<ThemeBloc>(create: (context) => di.sl()),
        Provider<DestinationRepository>(create: (context) => di.sl()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
          
          return MaterialApp.router(
            title: 'SpotNav',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(
                primary: AppColors.primary,
                seedColor: AppColors.primary,
                surface: AppColors.surface,
                background: AppColors.background,
                onSurface: AppColors.textPrimary,
                onBackground: AppColors.textPrimary,
              ),
              cardTheme: CardThemeData(
                color: AppColors.cardBackground,
                elevation: 2,
                shadowColor: AppColors.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.failed),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                // Add these properties to ensure input text is visible
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textThin),
                floatingLabelStyle: TextStyle(color: AppColors.primary),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: AppColors.cardBackground,
                elevation: 8,
                shadowColor: AppColors.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.darkBackground,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                primary: AppColors.darkPrimary,
                seedColor: AppColors.darkPrimary,
                surface: AppColors.darkSurface,
                background: AppColors.darkBackground,
                onSurface: AppColors.darkTextPrimary,
                onBackground: AppColors.darkTextPrimary,
                surfaceContainerHighest: AppColors.darkCardBackground,
                onSurfaceVariant: AppColors.darkTextSecondary,
                onPrimary: AppColors.darkBackground,
                onSecondary: AppColors.darkBackground,
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
                bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
                bodySmall: TextStyle(color: AppColors.darkTextSecondary),
                titleLarge: TextStyle(color: AppColors.darkTextPrimary),
                titleMedium: TextStyle(color: AppColors.darkTextPrimary),
                titleSmall: TextStyle(color: AppColors.darkTextPrimary),
                labelLarge: TextStyle(color: AppColors.darkTextPrimary),
                labelMedium: TextStyle(color: AppColors.darkTextSecondary),
                labelSmall: TextStyle(color: AppColors.darkTextThin),
              ),
              cardTheme: CardThemeData(
                color: AppColors.darkCardBackground,
                elevation: 4,
                shadowColor: AppColors.darkShadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.darkInputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.darkDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.darkDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.darkFailed),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                labelStyle: TextStyle(color: AppColors.darkTextSecondary),
                hintStyle: TextStyle(color: AppColors.darkTextThin),
                floatingLabelStyle: TextStyle(color: AppColors.darkPrimary),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: AppColors.darkCardBackground,
                elevation: 12,
                shadowColor: AppColors.darkShadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  foregroundColor: AppColors.darkBackground,
                  elevation: 4,
                  shadowColor: AppColors.darkShadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.darkBackground,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
                titleTextStyle: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter(authBloc: _authBloc).config,
          );
        },
      ),
    );
  }
} 
