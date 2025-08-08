import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String icon;
  final String label;
  final void Function()? onTap;
  final bool nextIcon;
  final Widget? suffix;

  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.nextIcon = true,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.divider,
        ),
        alignment: Alignment.center,
        child: ImageIcon(AssetImage(icon), size: 20),
      ),
      title: Text(label),
      trailing:
          suffix ??
          (nextIcon
              ? ImageIcon(AssetImage(AppAssets.icons.navigation.next), size: 20)
              : null),
    );
  }
}
