import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_failed_section.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/presentation/search/bloc/search_bloc.dart';
import 'package:spotnav/presentation/search/views/search_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({super.key});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus the search field when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
          title: const Text(
            'Search Destinations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search destinations, cities, tags...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary.withOpacity(0.8),
                        size: 22,
                      ),
                    ),
                    suffixIcon: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        if (state is SearchLoading || 
                            state is SearchLoaded || 
                            state is SearchFailed) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: AppColors.textSecondary.withOpacity(0.6),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchBloc>().add(const ClearSearchEvent());
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (query) {
                    context.read<SearchBloc>().add(SearchQueryChangedEvent(query: query));
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (query) {
                    context.read<SearchBloc>().add(SearchSubmittedEvent(query: query));
                  },
                ),
              ),
            ),
            // Results
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                                 builder: (context, state) {
                   if (state is SearchInitial) {
                     return _buildInitialState();
                   }
                   if (state is SearchLoading) {
                     return _buildLoadingState(state.query);
                   }
                   if (state is SearchFailed) {
                     return _buildFailedState(state);
                   }
                                     if (state is SearchLoaded) {
                     return _buildResultsState(state);
                   }
                                     return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const Gap(16),
          Text(
            'Search Destinations',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'Type to search for destinations, cities, or tags',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const Gap(16),
          Text(
            'Searching for "$query"...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState(SearchFailed state) {
    return CustomFailedSection(failure: state.failure);
  }

  Widget _buildResultsState(SearchLoaded state) {
    if (state.destinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const Gap(16),
            Text(
              'No results found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Text(
              'Try different keywords or check spelling',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Search query: "${state.query}"',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${state.destinations.length} result${state.destinations.length == 1 ? '' : 's'} for "${state.query}"',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.destinations.length,
                         itemBuilder: (context, index) {
               final destination = state.destinations[index];
               return _buildSearchResultItem(destination, index);
             },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(DestinationModel destination, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.network(
              destination.cover,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: AppColors.textSecondary,
                  child: const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        title: Text(
          destination.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const Gap(4),
                Expanded(
                  child: Text(
                    destination.location.address,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Wrap(
              spacing: 4,
              children: (destination.category ?? []).take(3).map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          context.push('/destinations/${destination.id}');
        },
      ),
    );
  }
} 