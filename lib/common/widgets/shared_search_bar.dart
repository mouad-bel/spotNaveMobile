import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_icon_button.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/presentation/home/bloc/all_destinations_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

class SharedSearchBar extends StatefulWidget {
  final String hintText;
  final bool isReadOnly;
  final bool showClearButton;
  final bool showSearchModal;
  final bool showFilters;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final Function()? onClearTap;
  final Function()? onFilterTap;
  final Function(String)? onDestinationTap;
  final Function(List<String>)? onFiltersChanged;
  final Function(String)? onSearchChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SharedSearchBar({
    super.key,
    this.hintText = "Search...",
    this.isReadOnly = false,
    this.showClearButton = false,
    this.showSearchModal = false,
    this.showFilters = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClearTap,
    this.onFilterTap,
    this.onDestinationTap,
    this.onFiltersChanged,
    this.onSearchChanged,
    this.controller,
    this.focusNode,
  });

  @override
  State<SharedSearchBar> createState() => _SharedSearchBarState();
}

class _SharedSearchBarState extends State<SharedSearchBar> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';
  bool _showModal = false;
  bool _showFilters = false;
  Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
    _searchFocusNode = widget.focusNode ?? FocusNode();
    
    _searchFocusNode.addListener(_onFocusChanged);
    _searchController.addListener(_onSearchControllerChanged);
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus && _searchQuery.isEmpty) {
      setState(() {
        _showModal = false;
      });
    }
  }

  void _onSearchControllerChanged() {
    final value = _searchController.text;
    _onSearchChanged(value);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _showModal = _searchQuery.isNotEmpty || _selectedFilters.isNotEmpty;
      if (_searchQuery.isNotEmpty) {
        _showFilters = false;
      }
    });
    
    // Call external callback if provided
    widget.onSearchChanged?.call(_searchQuery);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _searchController.dispose();
    }
    if (widget.focusNode == null) {
      _searchFocusNode.dispose();
    }
    super.dispose();
  }

  void _onDestinationTap(String destinationId) {
    setState(() {
      _showModal = false;
      _searchController.clear();
      _selectedFilters.clear();
      _searchFocusNode.unfocus();
    });
    
    if (widget.onDestinationTap != null) {
      widget.onDestinationTap!(destinationId);
    } else {
      // Default navigation
      context.push('/destinations/$destinationId');
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _showModal = false;
        _searchFocusNode.unfocus();
      }
    });
    
    widget.onFilterTap?.call();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
    
    // Call external callback if provided
    widget.onFiltersChanged?.call(_selectedFilters.toList());
  }

  void _applyFilters() {
    if (_selectedFilters.isNotEmpty) {
      setState(() {
        _showModal = true;
        _showFilters = false;
      });
      _searchFocusNode.requestFocus();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
      _showFilters = false;
      if (_searchQuery.isEmpty) {
        _showModal = false;
      }
    });
    
    // Call external callback if provided
    widget.onFiltersChanged?.call([]);
  }

  void _onClearTap() {
    setState(() {
      _showModal = false;
      _showFilters = false;
      _searchController.clear();
      _selectedFilters.clear();
      _searchFocusNode.unfocus();
    });
    
    widget.onClearTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    // Local function to build filter chips
    Widget _buildFilterChip(String label, IconData icon) {
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
        
    return GestureDetector(
      onTap: (_showModal || _showFilters) ? () {
        setState(() {
          _showModal = false;
          _showFilters = false;
          _searchFocusNode.unfocus();
        });
      } : null,
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(isDarkMode),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(isDarkMode),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.getShadowColor(isDarkMode),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: AppColors.getDividerColor(isDarkMode),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              enabled: !widget.isReadOnly,
              onTap: widget.onTap ?? () {
                _searchFocusNode.requestFocus();
              },
              onChanged: widget.onChanged ?? (value) => _onSearchChanged(value),
              onSubmitted: widget.onSubmitted,
              style: TextStyle(
                color: AppColors.getTextPrimaryColor(isDarkMode),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.getTextThinColor(isDarkMode),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.getTextThinColor(isDarkMode),
                    size: 22,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clear button
                      if (widget.showClearButton && _searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: _onClearTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.getDividerColor(isDarkMode),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.clear_rounded,
                              color: AppColors.getTextSecondaryColor(isDarkMode),
                              size: 16,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      // Filter button
                      if (widget.showFilters)
                        CustomIconButton(
                          onTap: _toggleFilters,
                          icon: AppAssets.icons.filter,
                          backgroundColor: AppColors.getPrimaryColor(isDarkMode),
                          foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
                          borderRadius: BorderRadiusGeometry.circular(10),
                          size: const Size(36, 36),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Search modal (dropdown) - only if showSearchModal is true
          if (widget.showSearchModal)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showModal ? 240 : 0,
              margin: const EdgeInsets.only(top: 8),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showModal ? 1.0 : 0.0,
                child: _showModal
                    ? Transform.translate(
                        offset: Offset(0, _showModal ? 0 : -20),
                        child: Container(
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                                                         child: BlocProvider.value(
                               value: context.read<AllDestinationsBloc>(),
                               child: _buildSearchModal(isDarkMode),
                             ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          
          // Filter chips - only if showFilters is true
          if (widget.showFilters)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showFilters ? null : 0,
              margin: const EdgeInsets.only(top: 8),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showFilters ? 1.0 : 0.0,
                child: _showFilters
                    ? Transform.translate(
                        offset: Offset(0, _showFilters ? 0 : -20),
                        child: Container(
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Filter title
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
                                      if (_selectedFilters.isNotEmpty) ...[
                                        GestureDetector(
                                          onTap: _clearAllFilters,
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
                                      ],
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
                                                                     // Filter chips
                                   Wrap(
                                     spacing: 8,
                                     runSpacing: 8,
                                     children: [
                                       _buildFilterChip('Beach', Icons.beach_access),
                                       _buildFilterChip('Mountain', Icons.landscape),
                                       _buildFilterChip('City', Icons.location_city),
                                       _buildFilterChip('Historical', Icons.history_edu),
                                       _buildFilterChip('Adventure', Icons.hiking),
                                       _buildFilterChip('Family', Icons.family_restroom),
                                     ],
                                   ),
                                   // Apply Filters button
                                   if (_selectedFilters.isNotEmpty) ...[
                                     const Gap(16),
                                     SizedBox(
                                       width: double.infinity,
                                       child: ElevatedButton(
                                         onPressed: _applyFilters,
                                         style: ElevatedButton.styleFrom(
                                           backgroundColor: AppColors.getPrimaryColor(isDarkMode),
                                           foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
                                           padding: const EdgeInsets.symmetric(vertical: 12),
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(12),
                                           ),
                                         ),
                                         child: Text(
                                           'View ${_getFilteredResultsCount()} Destination${_getFilteredResultsCount() > 1 ? 's' : ''}',
                                           style: TextStyle(
                                             fontSize: 14,
                                             fontWeight: FontWeight.w600,
                                           ),
                                         ),
                                       ),
                                     ),
                                   ],
                                 ],
                               ),
                             ),
                           ),
                         ),
                       )
                     : const SizedBox.shrink(),
               ),
             ),
         ],
       ),
     );
   }



  Widget _buildSearchModal(bool isDarkMode) {
    return BlocBuilder<AllDestinationsBloc, AllDestinationsState>(
      builder: (context, state) {
        if (state is AllDestinationsLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.getPrimaryColor(isDarkMode),
                ),
                const Gap(16),
                Text(
                  'Loading destinations...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AllDestinationsFailed) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryColor(isDarkMode),
                    foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AllDestinationsLoaded) {
          final destinations = state.destinations;
          final filteredDestinations = _filterDestinationsBySearch(destinations, _searchQuery);
          
          if (filteredDestinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                  const Gap(16),
                  Text(
                    _searchQuery.isEmpty && _selectedFilters.isEmpty
                      ? 'No destinations found'
                      : _selectedFilters.isNotEmpty && _searchQuery.isEmpty
                        ? 'No destinations match selected filters'
                        : 'No results for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),
                  if (_selectedFilters.isNotEmpty) ...[
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Filters: ${_selectedFilters.join(', ')}',
                        style: TextStyle(
                          color: AppColors.getPrimaryColor(isDarkMode),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredDestinations.length,
            itemBuilder: (context, index) {
              final destination = filteredDestinations[index];
              return Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.getCardBackgroundColor(isDarkMode),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.getDividerColor(isDarkMode),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onDestinationTap(destination.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              destination.cover,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.getDividerColor(isDarkMode),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.getTextSecondaryColor(isDarkMode),
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    destination.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.getTextPrimaryColor(isDarkMode),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${destination.location.city}, ${destination.location.country}',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondaryColor(isDarkMode),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 12,
                                      ),
                                      const Gap(2),
                                      Text(
                                        '${destination.rating}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppColors.getTextPrimaryColor(isDarkMode),
                                        ),
                                      ),
                                      if (destination.category?.isNotEmpty == true) ...[
                                        const Gap(6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            destination.category!.first,
                                            style: TextStyle(
                                              color: AppColors.getPrimaryColor(isDarkMode),
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
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Center(
          child: Text(
            'Initializing...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
        );
      },
    );
  }

  List<DestinationModel> _filterDestinationsBySearch(
    List<DestinationModel> destinations,
    String query,
  ) {
    List<DestinationModel> filtered = destinations;
    
    // First filter by selected categories if any
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
    
    // Then filter by search query if any
    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
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
    
    return filtered;
  }

  int _getFilteredResultsCount() {
    try {
      final state = context.read<AllDestinationsBloc>().state;
      if (state is AllDestinationsLoaded) {
        final filtered = _filterDestinationsBySearch(state.destinations, _searchQuery);
        return filtered.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
} 