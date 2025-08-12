import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupListTileSection extends StatelessWidget {
  final List<Widget> children;
  final bool showDivider;

  const GroupListTileSection({
    super.key,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    final List<Widget> childrenToDisplay = [];
    if (showDivider) {
      // Dynamically build the list of children with dividers
      for (int i = 0; i < children.length; i++) {
        childrenToDisplay.add(children[i]);
        // Add a Divider after each child, except the last one
        if (i < children.length - 1) {
          childrenToDisplay.add(
            Divider(height: 1, color: AppColors.getDividerColor(isDarkMode)),
          );
        }
      }
    } else {
      // If no dividers are needed, just use the original children list
      childrenToDisplay.addAll(children);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: childrenToDisplay,
        ),
      ),
    );
  }
}
