import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:flutter/material.dart';

class AccountItem extends StatelessWidget {
  const AccountItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.nextIcon = true,
    required this.isDarkMode,
  });
  final String icon;
  final String label;
  final void Function() onTap;
  final bool nextIcon;
  final bool isDarkMode;

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
          color: AppColors.getDividerColor(isDarkMode),
        ),
        alignment: Alignment.center,
        child: ImageIcon(
          AssetImage(icon), 
          size: 20,
          color: isDarkMode 
              ? AppColors.getPrimaryColor(isDarkMode)  // Use primary color for icons in dark mode for better visibility
              : AppColors.getTextPrimaryColor(isDarkMode), // Use normal text color in light mode
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDarkMode 
              ? AppColors.getTextSecondaryColor(isDarkMode)  // Use secondary color for better readability in dark mode
              : AppColors.getTextPrimaryColor(isDarkMode), // Use normal text color in light mode
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: nextIcon
          ? ImageIcon(
              AssetImage(AppAssets.icons.navigation.next), 
              size: 20,
              color: AppColors.getTextThinColor(isDarkMode),
            )
          : null,
    );
  }
}
