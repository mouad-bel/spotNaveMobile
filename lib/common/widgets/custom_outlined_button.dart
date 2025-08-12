import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double width;
  final double? height;
  final String? icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? outlineColor;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height = 46,
    this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: foregroundColor ?? AppColors.getPrimaryColor(isDarkMode),
          backgroundColor: backgroundColor ?? AppColors.getInputBackgroundColor(isDarkMode),
          side: BorderSide(
            color: outlineColor ?? AppColors.getDividerColor(isDarkMode), 
            width: 1
          ),
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
