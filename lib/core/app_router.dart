import 'dart:async';

import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/common/widgets/error_page.dart';
import 'package:spotnav/core/di.dart' as di;
import 'package:spotnav/presentation/account/views/account_fragment.dart';
import 'package:spotnav/presentation/auth/views/login_page.dart';
import 'package:spotnav/presentation/auth/views/register_page.dart';
import 'package:spotnav/presentation/dashboard/cubit/dashboard_index_cubit.dart';
import 'package:spotnav/presentation/dashboard/views/dashboard_page.dart';
import 'package:spotnav/presentation/destination_detail/blocs/detail/destination_detail_bloc.dart';
import 'package:spotnav/presentation/home/bloc/all_destinations_bloc.dart';
import 'package:spotnav/presentation/destination_detail/blocs/is_saved/is_saved_destination_bloc.dart';
import 'package:spotnav/presentation/destination_detail/views/destination_detail_page.dart';
import 'package:spotnav/presentation/destination_detail/views/gallery_page.dart';
import 'package:spotnav/presentation/home/views/home_fragment.dart';
import 'package:spotnav/presentation/nearby_map/blocs/nearby_destinations/nearby_destinations_bloc.dart';
import 'package:spotnav/presentation/nearby_map/cubits/center_coordinates/center_coordinates_cubit.dart';
import 'package:spotnav/presentation/nearby_map/cubits/nearby_radius/nearby_radius_cubit.dart';
import 'package:spotnav/presentation/nearby_map/views/nearby_map_page.dart';
import 'package:spotnav/presentation/profile/profile_page.dart';
import 'package:spotnav/presentation/profile/edit_profile_page.dart';
import 'package:spotnav/presentation/saved_destinations/views/saved_destinations_page.dart';
import 'package:spotnav/presentation/settings/settings_page.dart';
import 'package:spotnav/presentation/subscription/views/subscription_page.dart';
import 'package:spotnav/presentation/home/views/category_destinations_page.dart';
import 'package:spotnav/presentation/home/bloc/category_destinations_bloc.dart';
import 'package:spotnav/presentation/search/views/search_panel.dart';
import 'package:spotnav/presentation/search/bloc/search_bloc.dart';
import 'package:spotnav/presentation/destinations/views/all_destinations_page.dart';
import 'package:spotnav/presentation/notifications/views/broadcast_test_page.dart';

import 'package:spotnav/presentation/suggested_destinations/views/suggested_destinations_page.dart';
import 'package:spotnav/presentation/suggested_destinations/bloc/suggested_destinations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter({required AuthBloc authBloc}) : _authBloc = authBloc;

  late final GoRouter config = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocProvider(
            create: (context) => DashboardIndexCubit(),
            child: DashboardPage(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeFragment(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/nearby-map',
                                 builder: (context, state) {
                   // Always use Morocco as the default location regardless of user's address
                   String address = 'Casablanca, Morocco'; // Force Morocco location
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (context) => NearbyRadiusCubit()),
                      BlocProvider(
                        create: (context) =>
                            CenterCoordinatesCubit(geocodingInfo: di.sl()),
                      ),
                      BlocProvider(
                        create: (context) =>
                            NearbyDestinationsBloc(repository: di.sl()),
                      ),
                    ],
                    child: NearbyMapPage(address: address),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountFragment(),
              ),
            ],
          ),
        ],
      ),

             GoRoute(
         path: '/profile',
         builder: (context, state) => const ProfilePage(),
       ),
       GoRoute(
         path: '/edit-profile',
         builder: (context, state) => const EditProfilePage(),
       ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: '/broadcast-test',
        builder: (context, state) => const BroadcastTestPage(),
      ),
             GoRoute(
         path: '/nearby-map',
         builder: (context, state) {
           // Always use Morocco as the default location
           final address = state.extra as String? ?? 'Casablanca, Morocco';
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => NearbyRadiusCubit()),
              BlocProvider(
                create: (context) =>
                    CenterCoordinatesCubit(geocodingInfo: di.sl()),
              ),
              BlocProvider(
                create: (context) =>
                    NearbyDestinationsBloc(repository: di.sl()),
              ),
            ],
            child: NearbyMapPage(address: address),
          );
        },
      ),

      GoRoute(
        path: '/destinations',
        builder: (context, state) => BlocProvider(
          create: (context) => AllDestinationsBloc(destinationRepository: di.sl()),
          child: const AllDestinationsPage(),
        ),
        routes: [
          GoRoute(
            path: 'gallery',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final images = extra['images'] as List<String>? ?? [];
              final title = extra['title'] as String? ?? 'Gallery';
              return GalleryPage(images: images, title: title);
            },
          ),
          GoRoute(
            path: 'saved',
            builder: (context, state) => const SavedDestinationsPage(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) {
                      return DestinationDetailBloc(repository: di.sl());
                    },
                  ),
                  BlocProvider(
                    create: (context) {
                      return IsSavedDestinationBloc(repository: di.sl());
                    },
                  ),
                ],
                child: DestinationDetailsPage(id: id),
              );
            },
          ),
          GoRoute(
            path: 'category/:category',
            builder: (context, state) {
              final category = state.pathParameters['category']!;
              final formattedCategory = category.replaceAll('-', ' ');
              
              return BlocProvider(
                create: (context) => CategoryDestinationsBloc(destinationRepository: di.sl()),
                child: CategoryDestinationsPage(category: formattedCategory),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => BlocProvider(
          create: (context) => SearchBloc(destinationRepository: di.sl()),
          child: const SearchPanel(),
        ),
      ),
      GoRoute(
        path: '/suggested-destinations',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? 'general';
          final excludeId = int.tryParse(state.uri.queryParameters['exclude'] ?? '0') ?? 0;
          
          return BlocProvider(
            create: (context) => SuggestedDestinationsBloc(destinationRepository: di.sl()),
            child: SuggestedDestinationsPage(
              category: category,
              excludeDestinationId: excludeId.toString(),
            ),
          );
        },
      ),
    ],
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final authenticated = _authBloc.state is Authenticated;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToRegister = state.uri.path == '/register';
      final isLoading = state.fullPath == '/';

      // If the user is NOT logged in:
      //  - Allow access to /login, or /register.
      //  - For any other path, redirect to /login.
      if (!authenticated) {
        return (isGoingToLogin || isGoingToRegister) ? null : '/login';
      }

      // If the user IS logged in:
      //  - If they are trying to go to /, /login, or /register, redirect them to /dashboard.
      //  - For any other path (e.g., /dashboard or other protected routes), allow access.
      if (authenticated) {
        return (isLoading || isGoingToLogin || isGoingToRegister)
            ? '/home'
            : null;
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
  );
}

// Helper class to make GoRouter react to stream changes (like Bloc state changes)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((AuthState _) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
