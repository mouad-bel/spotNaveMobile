import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_failed_section.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/presentation/home/bloc/popular_destination_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'popular_destination_item.dart';

class PopularDestination extends StatefulWidget {
  final bool isDarkMode;
  
  const PopularDestination({super.key, required this.isDarkMode});

  @override
  State<PopularDestination> createState() => _PopularDestinationState();
}

class _PopularDestinationState extends State<PopularDestination> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start listening to real-time updates
      context.read<PopularDestinationBloc>().add(
        const StartListeningToPopularDestinationsEvent(),
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    // Stop listening when the widget is disposed
    try {
      context.read<PopularDestinationBloc>().add(
        const StopListeningToPopularDestinationsEvent(),
      );
    } catch (e) {
      // Ignore errors during disposal
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Popular Destinations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.getTextPrimaryColor(widget.isDarkMode),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.push('/destinations?filter=popular');
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.getPrimaryColor(widget.isDarkMode),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8), // Reduced from 16 to 8 to make title and cards closer
        SizedBox(
          height: 300, // Reverted back to original height
          child: BlocBuilder<PopularDestinationBloc, PopularDestinationState>(
            builder: (context, state) {
              //print('DEBUG: UI received state: ${state.runtimeType}');
              if (state is PopularDestinationLoading) {
                //print('DEBUG: UI showing loading state');
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.getPrimaryColor(widget.isDarkMode),
                  ),
                );
              }
              if (state is PopularDestinationFailed) {
                //print('DEBUG: UI showing failed state: ${state.failure.message}');
                return CustomFailedSection(failure: state.failure);
              }
              if (state is PopularDestinationLoaded) {
                final list = state.destinations;
                //print('DEBUG: UI showing loaded state with ${list.length} destinations');
                if (list.isEmpty) {
                  //print('DEBUG: UI showing empty list message');
                  return const CustomFailedSection(
                    failure: NotFoundFailure(
                      message: 'No destinations available',
                    ),
                  );
                }
                //print('DEBUG: UI building ListView with ${list.length} items');
                return ListView.builder(
                  itemCount: list.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final destination = list[index];
                    //print('DEBUG: Building item $index: ${destination.name}');
                    return PopularDestinationItem(
                      destination: destination,
                      index: index,
                      lastIndex: list.length - 1,
                    );
                  },
                );
              }
              //print('DEBUG: UI showing default state (SizedBox.shrink)');
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
