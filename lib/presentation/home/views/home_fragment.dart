import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/home/bloc/popular_destination_bloc.dart';
import 'package:spotnav/presentation/home/bloc/all_destinations_bloc.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'home_category.dart';
import 'home_header.dart';
import 'home_search.dart';
import 'todays_top_spots.dart';
import 'popular_destination.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the home page loads
    context.read<NotificationBloc>().add(LoadNotificationsEvent());
    
    // Load all destinations when the home page loads for search functionality
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllDestinationsBloc>().add(const FetchAllDestinationsEvent());
    });
  }

  Future<void> _onScrollRefresh(BuildContext context) async {
    context.read<PopularDestinationBloc>().add(
      const RefreshPopularDestinationsEvent(),
    );
    context.read<NotificationBloc>().add(RefreshNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return RefreshIndicator.adaptive(
      displacement: 10,
      onRefresh: () => _onScrollRefresh(context),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 40, bottom: 100),
        children: [
          HomeHeader(isDarkMode: isDarkMode),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ready to go to next\nbeautiful place?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: AppColors.getTextPrimaryColor(isDarkMode),
              ),
            ),
          ),
          const Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeSearch(isDarkMode: isDarkMode),
          ),
          const Gap(20),
          HomeCategory(isDarkMode: isDarkMode),
          const Gap(24),
          TodaysTopSpots(isDarkMode: isDarkMode),
          const Gap(16), // Increased gap between sections for better visual separation
          PopularDestination(isDarkMode: isDarkMode),
          const Gap(20),
        ],
      ),
    );
  }
}
