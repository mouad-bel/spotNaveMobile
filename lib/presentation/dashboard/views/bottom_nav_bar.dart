import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/dashboard_index_cubit.dart';
import 'bottom_nav_bar_item.dart';

class BottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  BottomNavBar({super.key, required this.navigationShell});

  final _menu = [
    (
      icon: AppAssets.icons.home.outline,
      activeIcon: AppAssets.icons.home.fill,
      path: '/home',
    ),
    (
      icon: AppAssets.icons.discover.outline,
      activeIcon: AppAssets.icons.discover.fill,
      path: '/nearby-map',
    ),
    (
      icon: AppAssets.icons.account.outline,
      activeIcon: AppAssets.icons.account.fill,
      path: '/account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 4,
              color: Colors.black12,
            ),
          ],
        ),
        child: BlocBuilder<DashboardIndexCubit, int>(
          builder: (context, indexState) {
            return Stack(
              children: [
                AnimatedPositioned(
                  left: indexState * BottomNavBarItem.width,
                  width: BottomNavBarItem.width,
                  height: BottomNavBarItem.height,
                  curve: Curves.easeOutSine,
                  duration: const Duration(milliseconds: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const ColoredBox(color: Colors.white),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_menu.length, (index) {
                    final item = _menu[index];
                    final isActive = indexState == index;
                    final icon = isActive ? item.activeIcon : item.icon;
                    final iconColor = isActive
                        ? AppColors.primary
                        : AppColors.textThin;
                    return BottomNavBarItem(
                      onTap: () {
                        context.read<DashboardIndexCubit>().update(index);
                        navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == navigationShell.currentIndex,
                        );
                      },
                      icon: icon,
                      iconColor: iconColor,
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
