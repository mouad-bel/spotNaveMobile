import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final List<String> categories;

  const CategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 8,
          children: categories.map((e) {
            return Chip(
              label: Text(e),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.divider),
              visualDensity: const VisualDensity(vertical: -2),
            );
          }).toList(),
        ),
      ),
    );
  }
}
