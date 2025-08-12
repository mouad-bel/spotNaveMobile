import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/shared_search_bar.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/presentation/home/bloc/all_destinations_bloc.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'dart:ui';

class AllDestinationsPage extends StatefulWidget {
  const AllDestinationsPage({super.key});

  @override
  State<AllDestinationsPage> createState() => _AllDestinationsPageState();
}

class _AllDestinationsPageState extends State<AllDestinationsPage> {
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  bool _showFilters = false;
  String _category = ''; // Restore this variable

  @override
  void initState() {
    super.initState();
    
    // Load destinations when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllDestinationsBloc>().add(const FetchAllDestinationsEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    _category = uri.queryParameters['filter'] ?? '';
  }

  String get title {
    if (_selectedFilters.isNotEmpty) {
      return 'Filtered Destinations';
    }
    if (_searchQuery.isNotEmpty) {
      return 'Search Results';
    }
    // Show title based on category filter
    switch (_category.toLowerCase()) {
      case 'todays':
        return "Today's Top Spots";
      case 'popular':
        return 'Popular Destinations';
      default:
        if (_category.isNotEmpty) {
          return '${_category[0].toUpperCase()}${_category.substring(1).toLowerCase()} Destinations';
        }
        return 'All Destinations';
    }
  }

  List<DestinationModel> _filterDestinations(List<DestinationModel> destinations) {
    List<DestinationModel> filtered = destinations;
    
    // Filter by category if specified (from URL parameters)
    if (_category.isNotEmpty && _category.trim().isNotEmpty) {
      switch (_category.toLowerCase()) {
        case 'todays':
          // Show destinations that are in today's top spots
          filtered = filtered.where((dest) {
            if (dest.category == null || dest.category!.isEmpty) return false;
            return dest.category!.any((cat) {
              final lowercaseCat = cat.toLowerCase();
              return lowercaseCat.contains('beach') ||
                     lowercaseCat.contains('resort') ||
                     lowercaseCat.contains('modern') ||
                     lowercaseCat.contains('nature') ||
                     lowercaseCat.contains('adventure') ||
                     lowercaseCat.contains('mountain') ||
                     lowercaseCat.contains('desert') ||
                     lowercaseCat.contains('coastal');
            });
          }).toList();
          break;
          
        case 'popular':
          // For popular, show ALL destinations but sort by rating (popularity)
          // No filtering needed - just sort by rating
          break;
          
        default:
          // For specific categories, check if destination has that category
          filtered = filtered.where((dest) {
            if (dest.category == null || dest.category!.isEmpty) return false;
            return dest.category!.any((cat) => 
              cat.toLowerCase().contains(_category.toLowerCase()) ||
              _category.toLowerCase().contains(cat.toLowerCase())
            );
          }).toList();
          break;
      }
    }
    
    // Filter by search query if any
    if (_searchQuery.isNotEmpty && _searchQuery.trim().isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((dest) {
        if (dest.name.toLowerCase().contains(lowercaseQuery)) return true;
        if (dest.location.city.toLowerCase().contains(lowercaseQuery)) return true;
        if (dest.location.country.toLowerCase().contains(lowercaseQuery)) return true;
        if (dest.category?.any((cat) => cat.toLowerCase().contains(lowercaseQuery)) ?? false) {
          return true;
        }
        return false;
      }).toList();
    }
    
    // Filter by selected filters if any
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((dest) {
        if (dest.category == null || dest.category!.isEmpty) return false;
        
        return _selectedFilters.any((filter) {
          final lowercaseFilter = filter.toLowerCase();
          return dest.category!.any((cat) {
            final lowercaseCategory = cat.toLowerCase();
            return lowercaseCategory == lowercaseFilter || 
                   lowercaseCategory.contains(lowercaseFilter) ||
                   lowercaseFilter.contains(lowercaseCategory);
          });
        });
      }).toList();
    }
    
    // Sort destinations by popularity (rating) if category is 'popular'
    if (_category.toLowerCase() == 'popular') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating)); // Highest rating first
    }
    
    return filtered;
  }

  int _getFilteredResultsCount() {
    try {
      final state = context.read<AllDestinationsBloc>().state;
      if (state is AllDestinationsLoaded) {
        final filtered = _filterDestinations(state.destinations);
        return filtered.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFiltersChanged(List<String> filters) {
    setState(() {
      _selectedFilters = filters;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getTextPrimaryColor(isDarkMode),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.getTextPrimaryColor(isDarkMode),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.getBackgroundColor(isDarkMode),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Search bar and filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  SharedSearchBar(
                    hintText: "Search destinations...",
                    showClearButton: true,
                    showSearchModal: false,  // Unified page doesn't show modal
                    showFilters: true,       // Unified page shows filters
                    onSearchChanged: _onSearchChanged,
                    onFiltersChanged: _onFiltersChanged,
                  ),
                  
                  // Filter chips
                  if (_showFilters) ...[
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.getCardBackgroundColor(isDarkMode),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getShadowColor(isDarkMode),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: AppColors.getPrimaryColor(isDarkMode),
                                size: 20,
                              ),
                              const Gap(8),
                              Text(
                                'Quick Filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextPrimaryColor(isDarkMode),
                                ),
                              ),

                              const Spacer(),
                              if (_selectedFilters.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilters.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.getFailedColor(isDarkMode).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color: AppColors.getFailedColor(isDarkMode),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              const Gap(8),
                              GestureDetector(
                                onTap: _toggleFilters,
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.getTextSecondaryColor(isDarkMode),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip('Beach', Icons.beach_access, isDarkMode),
                              _buildFilterChip('Mountain', Icons.landscape, isDarkMode),
                              _buildFilterChip('City', Icons.location_city, isDarkMode),
                              _buildFilterChip('Historical', Icons.history_edu, isDarkMode),
                              _buildFilterChip('Adventure', Icons.hiking, isDarkMode),
                              _buildFilterChip('Family', Icons.family_restroom, isDarkMode),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Add padding for bottom navigation bar
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 16,
            ),
          ),
          
          // Destinations list
          BlocBuilder<AllDestinationsBloc, AllDestinationsState>(
            builder: (context, state) {
              if (state is AllDestinationsLoading) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppColors.getPrimaryColor(isDarkMode),
                      ),
                    ),
                  ),
                );
              }

              if (state is AllDestinationsFailed) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                          ),
                          const Gap(16),
                          Text(
                            'Failed to load destinations',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextSecondaryColor(isDarkMode),
                            ),
                          ),
                          const Gap(8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AllDestinationsBloc>().add(const FetchAllDestinationsEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (state is AllDestinationsLoaded) {
                final destinations = _filterDestinations(state.destinations);
                
                // Debug information
                print('🔍 AllDestinationsPage - Total destinations: ${state.destinations.length}');
                print('🔍 AllDestinationsPage - Filtered destinations: ${destinations.length}');
                print('🔍 AllDestinationsPage - Category filter: $_category');
                print('🔍 AllDestinationsPage - Search query: $_searchQuery');
                print('🔍 AllDestinationsPage - Selected filters: $_selectedFilters');
                
                if (destinations.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const Gap(16),
                            Text(
                              'No destinations found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _selectedFilters.isNotEmpty) ...[
                              const Gap(8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Match search bar padding
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      childAspectRatio: 0.7, // Better for vertical cards
                      crossAxisSpacing: 8, // Tighter spacing
                      mainAxisSpacing: 8, // Tighter spacing
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final destination = destinations[index];
                        print('🔍 Building card $index: ${destination.name}');
                        return _buildDestinationCard(destination);
                      },
                      childCount: destinations.length,
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Initializing...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(DestinationModel destination) {
    return GestureDetector(
      onTap: () => context.push('/destinations/${destination.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Image.network(
                destination.cover,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('🖼️ Image load error for ${destination.name}: $error');
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade400,
                          size: 48,
                        ),
                        const Gap(8),
                        Text(
                          'Image unavailable',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // VR Badge (if available)
              if (destination.virtualTour == true)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Use app theme color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Text overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced blur for more transparency
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.0), // Start transparent
                            Colors.black.withValues(alpha: 0.2), // Middle more transparent
                            Colors.black.withValues(alpha: 0.6), // Bottom less solid
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 14,
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  '${destination.location.city}, ${destination.location.country}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const Gap(4),
                              Text(
                                '${destination.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(), // Push category badge to the right
                              if (destination.category?.isNotEmpty == true) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3), // Transparent white background
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    destination.category!.first,
                                    style: const TextStyle(
                                      color: Colors.white, // White text for better contrast
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isDarkMode) {
    final isSelected = _selectedFilters.contains(label);
    return GestureDetector(
      onTap: () => _onFilterSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.getPrimaryColor(isDarkMode) : AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.getPrimaryColor(isDarkMode) : AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? (isDarkMode ? AppColors.darkBackground : Colors.white) : AppColors.getPrimaryColor(isDarkMode),
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? (isDarkMode ? AppColors.darkBackground : Colors.white) : AppColors.getPrimaryColor(isDarkMode),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const Gap(4),
              Icon(
                Icons.remove_circle_outline,
                size: 14,
                color: isDarkMode ? AppColors.darkBackground : Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 