import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

import 'saved_destination_item.dart';

class SavedDestinationsPage extends StatefulWidget {
  const SavedDestinationsPage({super.key});

  @override
  State<SavedDestinationsPage> createState() => _SavedDestinationsPageState();
}

class _SavedDestinationsPageState extends State<SavedDestinationsPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedDestinationsBloc>().add(
        const FetchSavedDestinationsEvent(),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: AppColors.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Saved Destination',
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(isDarkMode),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SavedDestinationsBloc, SavedDestinationsState>(
        builder: (context, state) {
          if (state is SavedDestinationsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.getPrimaryColor(isDarkMode),
              ),
            );
          }
          if (state is SavedDestinationsLoaded) {
            final list = state.destinations!;
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'No saved yet',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    fontSize: 16,
                  ),
                ),
              );
            }
            return GridView.builder(
              itemCount: list.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final item = list[index];
                return SavedDestinationItem(item: item);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
