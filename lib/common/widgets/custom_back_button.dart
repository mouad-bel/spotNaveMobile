import 'package:spotnav/common/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.backgroundColor = Colors.white});
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: IconButton.filled(
        style: IconButton.styleFrom(backgroundColor: backgroundColor),
        onPressed: () => context.pop(),
        icon: ImageIcon(AssetImage(AppAssets.icons.arrow.left), size: 20),
      ),
    );
  }
}
