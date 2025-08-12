import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomIconButton extends StatelessWidget {
  final String icon;
  final void Function()? onTap;
  final Size size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadiusGeometry borderRadius;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = const Size(46, 46),
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return IconButton(
      style: IconButton.styleFrom(
        fixedSize: size,
        backgroundColor: backgroundColor ?? AppColors.getCardBackgroundColor(isDarkMode),
        foregroundColor: foregroundColor ?? AppColors.getPrimaryColor(isDarkMode),
        elevation: 2,
        shadowColor: AppColors.getShadowColor(isDarkMode),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      onPressed: onTap,
      icon: ImageIcon(AssetImage(icon), size: 20),
    );
  }
}
