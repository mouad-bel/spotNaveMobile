import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/common/widgets/custom_filled_button.dart';
import 'package:spotnav/common/widgets/custom_outlined_button.dart';
import 'package:spotnav/common/widgets/group_list_tile_section.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'profile_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _copyToClipboard(BuildContext context, String field, String? data) {
    if (data == null || data.isEmpty) return;
    Clipboard.setData(ClipboardData(text: data));
    SnackbarUtil.showNeutral(context, '$field copied to clipboard');
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _deleteAccount(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) {
    try {
      // Show loading indicator
      SnackbarUtil.showInfo(context, 'Deleting account...');
      
      // Trigger account deletion
      context.read<AuthBloc>().add(const DeleteAccountEvent());
      
      // Navigate to login page
      context.go('/auth');
      
      SnackbarUtil.showSuccess(context, 'Account deleted successfully');
    } catch (e) {
      SnackbarUtil.showError(context, 'Failed to delete account: $e');
    }
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
          'Profile Details',
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
          BlocBuilder<AuthBloc, AuthState>(
            builder: (_, state) {
              final user = state is Authenticated ? state.user : null;
              return GroupListTileSection(
                showDivider: false,
                children: [
                  ProfileTile(label: 'Name', value: user?.name, onTap: null),
                  const Divider(height: 1, color: AppColors.divider),
                  ProfileTile(
                    label: 'Phone Number',
                    value: user?.phoneNumber,
                    onTap: null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Transform.translate(
                      offset: const Offset(-10, -5),
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          visualDensity: const VisualDensity(vertical: -4),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          _copyToClipboard(
                            context,
                            'Phone Number',
                            user?.phoneNumber,
                          );
                        },

                        label: const Text('Copy'),
                        icon: ImageIcon(
                          AssetImage(AppAssets.icons.copy),
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  ProfileTile(label: 'Email', value: user?.email, onTap: null),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Transform.translate(
                      offset: const Offset(-10, -5),
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          visualDensity: const VisualDensity(vertical: -4),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          _copyToClipboard(context, 'Email', user?.email);
                        },

                        label: const Text('Copy'),
                        icon: ImageIcon(
                          AssetImage(AppAssets.icons.copy),
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  ProfileTile(label: 'City', value: user?.city, onTap: null),
                  const Divider(height: 1, color: AppColors.divider),
                  ProfileTile(
                    label: 'Address',
                    value: user?.address,
                    onTap: null,
                  ),
                ],
              );
            },
          ),
          const Gap(20),
          CustomFilledButton(
            text: 'Edit Profile',
            onPressed: () {
              context.push('/edit-profile');
            },
            icon: AppAssets.icons.edit,
          ),
          const Gap(12),
          CustomOutlinedButton(
            text: 'Delete Account',
            onPressed: () {
              _showDeleteAccountDialog(context);
            },
            icon: AppAssets.icons.user.remove,
            outlineColor: AppColors.failed,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.failed,
          ),
        ],
      ),
    );
  }
}
