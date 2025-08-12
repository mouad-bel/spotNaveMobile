import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:spotnav/presentation/home/bloc/todays_top_spots_bloc.dart';
import 'package:spotnav/presentation/destination_detail/blocs/is_saved/is_saved_destination_bloc.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:ui'; // Added for ImageFilter
import 'package:spotnav/core/di_firebase.dart' as di;

class TodaysTopSpots extends StatefulWidget {
  final bool isDarkMode;
  
  const TodaysTopSpots({super.key, required this.isDarkMode});

  @override
  State<TodaysTopSpots> createState() => _TodaysTopSpotsState();
}

class _TodaysTopSpotsState extends State<TodaysTopSpots> {
  @override
  void initState() {
    super.initState();
    // Fetch today's top spots
    context.read<TodaysTopSpotsBloc>().add(FetchTodaysTopSpotsEvent());
    // Also start listening for real-time updates
    context.read<TodaysTopSpotsBloc>().add(StartListeningToTodaysTopSpotsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Today\'s Top Spots',
                style: TextStyle(
                  fontSize: 18, // Changed from 20 to 18 to match Popular Destinations
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimaryColor(widget.isDarkMode),
                ),
              ),
            ],
          ),
        ),
        const Gap(16), // Increased from 8 to 16 for more space between title and cards
        BlocBuilder<TodaysTopSpotsBloc, TodaysTopSpotsState>(
          builder: (context, state) {
            if (state is TodaysTopSpotsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.getPrimaryColor(widget.isDarkMode),
                ),
              );
            }

            if (state is TodaysTopSpotsError) {
              return Center(
                child: Text(
                  'Failed to load top spots: ${state.message}',
                  style: TextStyle(
                    color: AppColors.getFailedColor(widget.isDarkMode),
                  ),
                ),
              );
            }

            if (state is TodaysTopSpotsLoaded) {
              if (state.destinations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No top spots available today',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(widget.isDarkMode),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 160, // Match the card height exactly
                child: ListView.builder(
                  itemCount: state.destinations.length >= 4 ? 4 : state.destinations.length, // Show max 4 items
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final destination = state.destinations[index];
                    // Show More button on the 4th card (index 3) when we have 4 or more destinations
                    final isLastCard = index == 3 && state.destinations.length >= 4;

                    return BlocProvider(
                      create: (context) => di.sl<IsSavedDestinationBloc>(),
                      child: TodaysTopSpotItem(
                        destination: destination,
                        index: index,
                        lastIndex: 3, // Always show 4 items
                        showMoreButton: isLastCard,
                        isDarkMode: widget.isDarkMode,
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class TodaysTopSpotItem extends StatefulWidget {
  final DestinationModel destination;
  final int index;
  final int lastIndex;
  final bool showMoreButton;
  final bool isDarkMode;

  const TodaysTopSpotItem({
    super.key,
    required this.destination,
    required this.index,
    required this.lastIndex,
    required this.showMoreButton,
    required this.isDarkMode,
  });

  @override
  State<TodaysTopSpotItem> createState() => _TodaysTopSpotItemState();
}

class _TodaysTopSpotItemState extends State<TodaysTopSpotItem> {
  @override
  void initState() {
    super.initState();
    // Initialize save status for this destination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IsSavedDestinationBloc>().add(
        CheckIsSavedStatusEvent(destinationId: widget.destination.id.toString()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: 280, // Match Popular Destinations width for proper alignment
      padding: EdgeInsets.only(
        left: widget.index == 0 ? 16 : 8,
        right: widget.index == widget.lastIndex ? 16 : 8,
      ),
      child: GestureDetector(
        onTap: () {
          context.push('/destinations/${widget.destination.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Container(
              height: 160, // Reduced height from 180 to 160
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(widget.isDarkMode),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Main image
                      ExtendedImage.network(
                        widget.destination.cover,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        cache: true,
                        loadStateChanged: (ExtendedImageState state) {
                          if (state.extendedImageLoadState == LoadState.loading) {
                            return Container(
                              color: AppColors.getInputBackgroundColor(widget.isDarkMode),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.getTextThinColor(widget.isDarkMode),
                                ),
                              ),
                            );
                          }
                          if (state.extendedImageLoadState == LoadState.failed) {
                            return Container(
                              color: AppColors.getInputBackgroundColor(widget.isDarkMode),
                              child: Icon(
                                Icons.error_outline,
                                color: AppColors.getTextThinColor(widget.isDarkMode),
                                size: 50,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      // Gradient overlay for better text readability - reduced height
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 80, // Reduced height to minimize black overlay
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2), // Reduced opacity
                                Colors.black.withValues(alpha: 0.5), // Reduced opacity
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Save button (top-left)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: BlocConsumer<
                          IsSavedDestinationBloc,
                          IsSavedDestinationState
                        >(
                          listener: (context, state) {
                            if (state is IsSavedDestinationOperationSuccess) {
                              context.read<SavedDestinationsBloc>().add(
                                const FetchSavedDestinationsEvent(),
                              );
                              SnackbarUtil.showSuccess(context, state.message);
                            }
                            if (state is IsSavedDestinationFailed) {
                              SnackbarUtil.showError(context, state.failure.message);
                            }
                          },
                          builder: (context, state) {
                            final isSaved = state.isSaved;
                            if (isSaved == null) {
                              return const SizedBox.shrink();
                            }
                            final icon = isSaved
                                ? AppAssets.icons.archive.remove
                                : AppAssets.icons.archive.add;
                            final savedDestination = SavedDestinationModel(
                              id: widget.destination.id.toString(),
                              name: widget.destination.name,
                              cover: widget.destination.cover,
                            );
                            
                            return GestureDetector(
                              onTap: () {
                                context.read<IsSavedDestinationBloc>().add(
                                  ToggleIsSavedStatusEvent(
                                    destination: savedDestination,
                                    isCurrentlySaved: isSaved,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.getCardBackgroundColor(widget.isDarkMode).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.getShadowColor(widget.isDarkMode),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ImageIcon(
                                  AssetImage(icon),
                                  size: 16,
                                  color: isSaved ? AppColors.getPrimaryColor(widget.isDarkMode) : AppColors.getTextPrimaryColor(widget.isDarkMode),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // VR badge (top-right, replacing arrow)
                      if (widget.destination.virtualTour == true)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.getPrimaryColor(widget.isDarkMode).withValues(alpha: 0.9),
                                  AppColors.getPrimaryColor(widget.isDarkMode),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // More button overlay (when this is the last card and there are more destinations)
                      if (widget.showMoreButton)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to show all today's top spots
                              context.push('/destinations?filter=todays');
                            },
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.getTextThinColor(widget.isDarkMode).withValues(alpha: 0.4),
                                    AppColors.getTextThinColor(widget.isDarkMode).withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: AppColors.getTextThinColor(widget.isDarkMode).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'More',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 14,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                color: Colors.black54,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Content overlay at bottom
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12, // Keep original bottom padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Destination name
                            Text(
                              widget.destination.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Keep original font size
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(8), // Keep original gap
                            // Location info
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const Gap(4),
                                Expanded(
                                  child: Text(
                                    '${widget.destination.location.city}, ${widget.destination.location.country}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12, // Keep original font size
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8), // Keep original gap
                            // Rating and category
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const Gap(4),
                                Text(
                                  '${widget.destination.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12, // Keep original font size
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    widget.destination.category?.join(', ') ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11, // Keep original font size
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}