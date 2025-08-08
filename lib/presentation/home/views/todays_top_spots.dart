import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/presentation/home/bloc/todays_top_spots_bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'package:url_launcher/url_launcher.dart';

class TodaysTopSpots extends StatefulWidget {
  const TodaysTopSpots({super.key});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                '🌟 Today\'s Top Spots',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to all destinations
                  context.push('/destinations');
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        SizedBox(
          height: 280,
          child: BlocBuilder<TodaysTopSpotsBloc, TodaysTopSpotsState>(
            builder: (context, state) {
              if (state is TodaysTopSpotsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }
              if (state is TodaysTopSpotsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (state is TodaysTopSpotsLoaded) {
                if (state.destinations.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No top spots available today',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.destinations.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final destination = state.destinations[index];
                    return TodaysTopSpotItem(
                      destination: destination,
                      index: index,
                      lastIndex: state.destinations.length - 1,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class TodaysTopSpotItem extends StatelessWidget {
  final DestinationModel destination;
  final int index;
  final int lastIndex;

  const TodaysTopSpotItem({
    super.key,
    required this.destination,
    required this.index,
    required this.lastIndex,
  });

  Future<void> _launchVirtualTour(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(
        left: index == 0 ? 16 : 8,
        right: index == lastIndex ? 16 : 8,
      ),
      child: GestureDetector(
        onTap: () {
          context.push('/destinations/${destination.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                        destination.cover,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        cache: true,
                        loadStateChanged: (ExtendedImageState state) {
                          if (state.extendedImageLoadState == LoadState.loading) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (state.extendedImageLoadState == LoadState.failed) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      // Star badge (top-left)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: const Text(
                          '⭐',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Virtual Reality badge (bottom-left)
                      if (destination.virtualTour == true)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.9),
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Virtual Reality',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(12),
            // Destination info
            Text(
              destination.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 16,
                ),
                const Gap(4),
                Expanded(
                  child: Text(
                    '${destination.location.city}, ${destination.location.country}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const Gap(4),
                Text(
                  '${destination.rating}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    destination.category?.join(', ') ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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
    );
  }
}