import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.backgroundColor});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return UnconstrainedBox(
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.getCardBackgroundColor(isDarkMode),
          foregroundColor: AppColors.getPrimaryColor(isDarkMode),
          elevation: 2,
          shadowColor: AppColors.getShadowColor(isDarkMode),
        ),
        onPressed: () => context.pop(),
        icon: ImageIcon(AssetImage(AppAssets.icons.arrow.left), size: 20),
      ),
    );
  }
}
