import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bottom_nav_bar.dart';
import '../cubit/dashboard_index_cubit.dart';

class DashboardPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    // Hide bottom navigation bar on map page and other detail pages
    final currentLocation = GoRouterState.of(context).uri.toString();
    final showBottomNav = !currentLocation.startsWith('/nearby-map') && 
                         !currentLocation.startsWith('/profile') &&
                         !currentLocation.startsWith('/edit-profile') &&
                         !currentLocation.startsWith('/destinations/') &&
                         !currentLocation.startsWith('/subscription') &&
                         !currentLocation.startsWith('/settings') &&
                         !currentLocation.startsWith('/account');
    
    print('🔍 DashboardPage - Current location: $currentLocation');
    print('🔍 DashboardPage - Show bottom nav: $showBottomNav');
    print('🔍 DashboardPage - Starts with /nearby-map: ${currentLocation.startsWith('/nearby-map')}');
    print('🔍 DashboardPage - Starts with /profile: ${currentLocation.startsWith('/profile')}');
    print('🔍 DashboardPage - Starts with /edit-profile: ${currentLocation.startsWith('/edit-profile')}');

    // Update the dashboard index based on current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DashboardIndexCubit>();
      if (currentLocation.startsWith('/home')) {
        if (cubit.state != 0) {
          print('🔄 Updating dashboard index to 0 (home)');
          cubit.update(0);
        }
      } else if (currentLocation.startsWith('/nearby-map')) {
        if (cubit.state != 1) {
          print('🔄 Updating dashboard index to 1 (map)');
          cubit.update(1);
        }
      } else if (currentLocation.startsWith('/account')) {
        if (cubit.state != 2) {
          print('🔄 Updating dashboard index to 2 (account)');
          cubit.update(2);
        }
      }
    });

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: showBottomNav ? BottomNavBar(navigationShell: navigationShell) : null,
    );
  }
}
