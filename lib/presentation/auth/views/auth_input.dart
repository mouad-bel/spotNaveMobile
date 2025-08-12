import 'package:flutter/material.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthInput extends StatelessWidget {
  static const _borderRadius = BorderRadius.all(Radius.circular(16));

  final TextEditingController controller;
  final String hint;
  final Widget prefix;
  final Widget? suffix;
  final bool obscureText;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefix,
    this.suffix,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return TextField(
      controller: controller,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscureText,
      style: TextStyle(
        color: AppColors.getTextPrimaryColor(isDarkMode),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.getInputBackgroundColor(isDarkMode),
        isDense: true,
        prefixIcon: prefix,
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.getTextThinColor(isDarkMode),
        ),
        contentPadding: const EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(
            color: AppColors.getDividerColor(isDarkMode),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(
            color: AppColors.getDividerColor(isDarkMode),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(
            color: AppColors.getPrimaryColor(isDarkMode),
            width: 2,
          ),
        ),
      ),
    );
  }
}
