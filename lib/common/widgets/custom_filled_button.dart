import 'package:flutter/material.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomFilledButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double width;
  final double? height;
  final String? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height = 46,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: backgroundColor ?? AppColors.getPrimaryColor(isDarkMode),
          foregroundColor: foregroundColor ?? (isDarkMode ? AppColors.darkBackground : Colors.white),
          elevation: 4,
          shadowColor: AppColors.getShadowColor(isDarkMode),
        ),
        onPressed: onPressed,
        icon: icon == null ? null : ImageIcon(AssetImage(icon!), size: 15),
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
