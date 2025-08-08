import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String icon;
  final void Function()? onTap;
  final Size size;
  final Color backgroundColor;
  final Color? foregroundColor;
  final BorderRadiusGeometry borderRadius;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = const Size(46, 46),
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        fixedSize: size,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      onPressed: onTap,
      icon: ImageIcon(AssetImage(icon), size: 20),
    );
  }
}
