import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/common/widgets/custom_filled_button.dart';
import 'package:spotnav/common/widgets/custom_outlined_button.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _copyToClipboard(BuildContext context, String field, String? data) {
    if (data == null || data.isEmpty) return;
    Clipboard.setData(ClipboardData(text: data));
    SnackbarUtil.showNeutral(context, '$field copied to clipboard');
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(isDarkMode),
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: AppColors.getTextSecondaryColor(isDarkMode)),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.getTextSecondaryColor(isDarkMode)),
              ),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _deleteAccount(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.getFailedColor(isDarkMode),
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

  Widget _buildProfileHeader(BuildContext context, dynamic user, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppColors.darkGradientStart,
                  AppColors.darkGradientEnd,
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(isDarkMode),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.photoUrl != null
                  ? Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.getBackgroundColor(isDarkMode),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.getPrimaryColor(isDarkMode),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.getBackgroundColor(isDarkMode),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.getPrimaryColor(isDarkMode),
                      ),
                    ),
            ),
          ),
          const Gap(16),
          // User Name
          Text(
            user?.name ?? 'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(4),
          // User Email
          Text(
            user?.email ?? 'user@email.com',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.getDividerColor(isDarkMode),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            context,
            'Name',
            user?.name,
            Icons.person_outline,
            null,
            isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildInfoTile(
            context,
            'Phone Number',
            user?.phoneNumber,
            Icons.phone_outlined,
            () => _copyToClipboard(context, 'Phone Number', user?.phoneNumber),
            isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildInfoTile(
            context,
            'Email',
            user?.email,
            Icons.email_outlined,
            () => _copyToClipboard(context, 'Email', user?.email),
            isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildInfoTile(
            context,
            'City',
            user?.city,
            Icons.location_city_outlined,
            null,
            isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildInfoTile(
            context,
            'Address',
            user?.address,
            Icons.home_outlined,
            null,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String? value,
    IconData icon,
    VoidCallback? onCopy,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.getPrimaryColor(isDarkMode),
              size: 20,
            ),
          ),
          const Gap(16),
          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(4),
                Text(
                  value ?? '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          // Copy Button (if applicable)
          if (onCopy != null && value != null && value.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: onCopy,
                icon: Icon(
                  Icons.copy_outlined,
                  size: 18,
                  color: AppColors.getPrimaryColor(isDarkMode),
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: AppColors.getDividerColor(isDarkMode),
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            leadingWidth: 72,
            leading: CustomBackButton(
              backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
            ),
            backgroundColor: AppColors.getBackgroundColor(isDarkMode),
            centerTitle: true,
            title: Text(
              'Profile Details',
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
              BlocBuilder<AuthBloc, AuthState>(
                builder: (_, state) {
                  final user = state is Authenticated ? state.user : null;
                  return Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(context, user, isDarkMode),
                      const Gap(24),
                      
                      // Info Card
                      _buildInfoCard(context, user, isDarkMode),
                      const Gap(32),
                      
                      // Action Buttons
                      CustomFilledButton(
                        text: 'Edit Profile',
                        onPressed: () {
                          context.push('/edit-profile');
                        },
                        icon: AppAssets.icons.edit,
                      ),
                      const Gap(16),
                      CustomOutlinedButton(
                        text: 'Delete Account',
                        onPressed: () {
                          _showDeleteAccountDialog(context, isDarkMode);
                        },
                        icon: AppAssets.icons.user.remove,
                        outlineColor: AppColors.getFailedColor(isDarkMode),
                        backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                        foregroundColor: AppColors.getFailedColor(isDarkMode),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
