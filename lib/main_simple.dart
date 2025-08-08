import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/core/app_router.dart';
import 'package:spotnav/core/di.dart' as di;
import 'package:spotnav/presentation/home/bloc/popular_destination_bloc.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize regular DI instead of Firebase DI
  await di.init();

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
        BlocProvider<NotificationBloc>(create: (context) => di.sl()),
        BlocProvider<SavedDestinationsBloc>(create: (context) => di.sl()),
      ],
      child: MaterialApp.router(
        title: 'SpotNav',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            primary: AppColors.primary,
            seedColor: AppColors.primary,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        routerConfig: AppRouter(authBloc: _authBloc).config,
      ),
    );
  }
}
