import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearch extends StatelessWidget {
  static const _borderRadius = BorderRadius.all(Radius.circular(16));

  const HomeSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/search');
      },
      child: TextField(
        enabled: false, // Make it read-only so it acts as a button
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          hintText: "Where do you wanna go?",
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black45,
          ),
          contentPadding: const EdgeInsets.all(0),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide.none,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomIconButton(
              onTap: () {
                context.push('/search');
              },
              icon: AppAssets.icons.search,
              borderRadius: BorderRadiusGeometry.circular(12),
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomIconButton(
              onTap: () {
                context.push('/search');
              },
              icon: AppAssets.icons.filter,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              borderRadius: BorderRadiusGeometry.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
