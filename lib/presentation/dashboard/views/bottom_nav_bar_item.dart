import 'package:flutter/material.dart';

class BottomNavBarItem extends StatelessWidget {
  static const width = 60.0;
  static const height = 60.0;

  final String icon;
  final Color iconColor;
  final void Function() onTap;

  const BottomNavBarItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        fixedSize: const Size(width, height),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: ImageIcon(AssetImage(icon), size: 24, color: iconColor),
    );
  }
}
