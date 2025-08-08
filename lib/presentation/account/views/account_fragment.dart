import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/group_list_tile_section.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'package:spotnav/core/di_firebase.dart';

import 'account_tile.dart';

class AccountFragment extends StatelessWidget {
  const AccountFragment({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(LoggedOutEvent());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('📱 AccountFragment - Image picked: ${pickedFile.path}');
        
        // Get current user state
        final state = context.read<AuthBloc>().state;
        if (state is Authenticated) {
          final currentUser = state.user;
          print('📱 AccountFragment - Current user ID: ${currentUser.id}');
          print('📱 AccountFragment - Current photo URL: ${currentUser.photoUrl}');
          
          // Show loading indicator
          SnackbarUtil.showInfo(context, 'Uploading image...');
          
          try {
            // Upload image to Firebase Storage
            final imageFile = File(pickedFile.path);
            print('📱 AccountFragment - Image file created: ${imageFile.path}');
            
            final imageUrl = await context.read<AuthBloc>().uploadProfileImage(imageFile, currentUser.id.toString());
            print('📱 AccountFragment - Image uploaded successfully: $imageUrl');
            
            // Create updated user with new photo URL
            final updatedUser = UserModel(
              id: currentUser.id,
              name: currentUser.name,
              email: currentUser.email,
              phoneNumber: currentUser.phoneNumber,
              city: currentUser.city,
              address: currentUser.address,
              postalCode: currentUser.postalCode,
              photoUrl: imageUrl,
              subscriptionId: currentUser.subscriptionId,
              subscription: currentUser.subscription,
            );
            
            print('📱 AccountFragment - Updated user created with photo URL: ${updatedUser.photoUrl}');
            
            // Update user profile
            context.read<AuthBloc>().add(UpdateProfileEvent(updatedUser));
            print('📱 AccountFragment - UpdateProfileEvent dispatched');
            
            // Trigger profile update notification
            final notificationService = sl<NotificationService>();
            await notificationService.triggerBatchProfileUpdateNotification(
              updatedFields: ['profile_image'],
              icon: '👤', // Use profile icon
            );
            print('📱 AccountFragment - Profile update notification triggered');
            
            SnackbarUtil.showSuccess(context, 'Profile photo updated successfully');
          } catch (e) {
            print('❌ AccountFragment - Upload failed: $e');
            SnackbarUtil.showError(context, 'Failed to upload image: $e');
          }
        }
      }
    } catch (e) {
      SnackbarUtil.showError(context, 'Failed to pick image: $e');
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(context, ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(context, ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AppBar(
            forceMaterialTransparency: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => context.go('/home'),
              icon: ImageIcon(AssetImage(AppAssets.icons.arrow.left), size: 24),
            ),
            title: const Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: ImageIcon(AssetImage(AppAssets.icons.settings), size: 24),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 4),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: BlocConsumer<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state is Authenticated) {
                                  print('🔄 AccountFragment - User photo URL: ${state.user.photoUrl}');
                                }
                              },
                              builder: (context, state) {
                                if (state is Authenticated) {
                                  return state.user.photoUrl != null
                                      ? ExtendedImage.network(
                                          state.user.photoUrl!,
                                          fit: BoxFit.cover,
                                          loadStateChanged: (state) {
                                            if (state.extendedImageLoadState == LoadState.failed) {
                                              print('❌ Error loading profile image: ${state.lastException}');
                                              return ImageIcon(
                                                AssetImage(AppAssets.icons.user.profile),
                                              );
                                            }
                                            return null;
                                          },
                                        )
                                      : ImageIcon(
                                          AssetImage(AppAssets.icons.user.profile),
                                        );
                                }
                                return ImageIcon(
                                  AssetImage(AppAssets.icons.user.profile),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            fixedSize: const Size(30, 30),
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showImagePickerDialog(context),
                          icon: ImageIcon(
                            AssetImage(AppAssets.icons.edit),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(40),
              GroupListTileSection(
                children: [
                  AccountItem(
                    icon: AppAssets.icons.user.profile,
                    label: 'Profile Details',
                    onTap: () => context.push('/profile'),
                  ),
                  AccountItem(
                    icon: AppAssets.icons.password,
                    label: 'Password',

                    onTap: () => SnackbarUtil.notImplementedYet(context),
                  ),
                ],
              ),
              const Gap(20),
              GroupListTileSection(
                children: [
                  AccountItem(
                    icon: AppAssets.icons.archive.outline,
                    label: 'Saved',

                    onTap: () {
                      context.push('/destinations/saved');
                    },
                  ),
                  AccountItem(
                    icon: AppAssets.icons.journey,
                    label: 'Journey',
                    onTap: () => SnackbarUtil.notImplementedYet(context),
                  ),
                  AccountItem(
                    icon: AppAssets.icons.dollar,
                    label: 'Subscription',
                    onTap: () => context.push('/subscription'),
                  ),
                ],
              ),
              const Gap(20),
              GroupListTileSection(
                children: [
                  AccountItem(
                    icon: AppAssets.icons.logout,
                    label: 'Logout',
                    onTap: () => _showLogoutDialog(context),
                    nextIcon: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
