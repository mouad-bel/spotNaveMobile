import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_failed_section.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/presentation/home/bloc/category_destinations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:extended_image/extended_image.dart';

import 'popular_destination_item.dart';

class CategoryDestinationsPage extends StatefulWidget {
  final String category;

  const CategoryDestinationsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDestinationsPage> createState() => _CategoryDestinationsPageState();
}

class _CategoryDestinationsPageState extends State<CategoryDestinationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start listening to real-time updates
      context.read<CategoryDestinationsBloc>().add(
        StartListeningToCategoryDestinationsEvent(category: widget.category),
      );
    });
  }

  @override
  void dispose() {
    // Stop listening when the widget is disposed
    try {
      context.read<CategoryDestinationsBloc>().add(
        const StopListeningToCategoryDestinationsEvent(),
      );
    } catch (e) {
      // Ignore errors during disposal
    }
    super.dispose();
  }

  Future<void> _onScrollRefresh(BuildContext context) async {
    context.read<CategoryDestinationsBloc>().add(
      RefreshCategoryDestinationsEvent(category: widget.category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.category} Destinations',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        displacement: 10,
        onRefresh: () => _onScrollRefresh(context),
        child: BlocBuilder<CategoryDestinationsBloc, CategoryDestinationsState>(
          builder: (context, state) {
            if (state is CategoryDestinationsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is CategoryDestinationsFailed) {
              return CustomFailedSection(failure: state.failure);
            }

            if (state is CategoryDestinationsLoaded) {
              final destinations = state.destinations;
              
              if (destinations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const Gap(16),
                      Text(
                        'No ${widget.category} destinations found',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Try exploring other categories!',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/destinations/${destination.id}');
                    },
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
                            // Background Image
                            ExtendedImage.network(
                              destination.cover,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    destination.name,
                                    style: const TextStyle(
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                      const Gap(2),
                                      Expanded(
                                        child: Text(
                                          destination.location.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 1,
                                                color: Colors.black54,
                                              ),
                                            ],
                                          ),
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
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 