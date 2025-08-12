import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:spotnav/presentation/settings/setting_tile.dart';
import 'package:gap/gap.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        leadingWidth: 72,
        leading: const CustomBackButton(),
        backgroundColor: AppColors.getBackgroundColor(isDarkMode),
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.getTextPrimaryColor(isDarkMode),
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Settings Section (including theme toggle)
          _buildSettingsSection(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Theme Toggle
          ListTile(
            onTap: null, // No tap action needed for switch
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
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.getPrimaryColor(isDarkMode),
                size: 20,
              ),
            ),
            title: Text(
              'Theme',
              style: TextStyle(
                color: AppColors.getTextPrimaryColor(isDarkMode),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeBloc>().add(const ToggleThemeEvent());
              },
              activeColor: AppColors.getPrimaryColor(isDarkMode),
              activeTrackColor: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.getTextSecondaryColor(isDarkMode),
              inactiveTrackColor: AppColors.getDividerColor(isDarkMode),
            ),
          ),
          SettingTile(
            icon: AppAssets.icons.notification,
            label: 'Notifications',
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
            isDarkMode: isDarkMode,
          ),
          SettingTile(
            icon: AppAssets.icons.language,
            label: 'Language',
            onTap: () => Navigator.of(context).pushNamed('/language'),
            isDarkMode: isDarkMode,
          ),
          SettingTile(
            icon: AppAssets.icons.password,
            label: 'Security',
            onTap: () => Navigator.of(context).pushNamed('/security'),
            isDarkMode: isDarkMode,
          ),
          SettingTile(
            icon: AppAssets.icons.support,
            label: 'Help & Support',
            onTap: () => Navigator.of(context).pushNamed('/help'),
            isDarkMode: isDarkMode,
          ),
          SettingTile(
            icon: AppAssets.icons.info,
            label: 'About',
            onTap: () => Navigator.of(context).pushNamed('/about'),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
