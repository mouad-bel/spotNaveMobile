import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'setting_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _listenDarkMode = ValueNotifier(false);

  void _onDarkModeChanged(bool darkMode) {
    _listenDarkMode.value = darkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: const CustomBackButton(),
        forceMaterialTransparency: true,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  SettingTile(
                    icon: AppAssets.icons.weather.moon,
                    label: 'Dark Mode',
                    suffix: ValueListenableBuilder(
                      valueListenable: _listenDarkMode,
                      builder: (context, isDark, child) {
                        return Switch(
                          value: isDark,
                          onChanged: _onDarkModeChanged,
                          inactiveTrackColor: AppColors.divider,
                          trackOutlineColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return null;
                            }
                            return AppColors.textThin;
                          }),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  SettingTile(
                    icon: AppAssets.icons.notification,
                    label: 'Notification',
                    onTap: () {
                      SnackbarUtil.notImplementedYet(context);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  SettingTile(
                    icon: AppAssets.icons.info,
                    label: 'Notification Test',
                    onTap: () {
                      context.push('/notification-test');
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  SettingTile(
                    icon: AppAssets.icons.language,
                    label: 'Language',
                    onTap: () {
                      SnackbarUtil.notImplementedYet(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  SettingTile(
                    icon: AppAssets.icons.info,
                    label: 'About Application',
                    onTap: () {
                      SnackbarUtil.notImplementedYet(context);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  SettingTile(
                    icon: AppAssets.icons.feedback,
                    label: 'Feedback',
                    onTap: () {
                      SnackbarUtil.notImplementedYet(context);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  SettingTile(
                    icon: AppAssets.icons.support,
                    label: 'Support',
                    onTap: () {
                      SnackbarUtil.notImplementedYet(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listenDarkMode.dispose();
    super.dispose();
  }
}
