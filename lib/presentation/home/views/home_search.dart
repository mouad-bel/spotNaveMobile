import 'package:spotnav/common/widgets/shared_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearch extends StatelessWidget {
  final bool isDarkMode;
  
  const HomeSearch({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SharedSearchBar(
      hintText: "Where do you wanna go?",
      showClearButton: true,
      showSearchModal: true,  // Home page shows modal
      showFilters: true,      // Home page shows filters
      onDestinationTap: (destinationId) {
        context.push('/destinations/$destinationId');
      },
    );
  }
}

