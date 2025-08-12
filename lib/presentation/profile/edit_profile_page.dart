import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/common/widgets/custom_filled_button.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/data/services/notification_service.dart';
import 'package:spotnav/core/di_firebase.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      final user = state.user;
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _cityController.text = user.city ?? '';
      _addressController.text = user.address ?? '';
      _postalCodeController.text = user.postalCode ?? '';
      _currentPhotoUrl = user.photoUrl;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          // Clear the current photo URL since we have a new image
          _currentPhotoUrl = null;
        });
        SnackbarUtil.showSuccess(context, 'Image selected successfully');
      }
    } catch (e) {
      SnackbarUtil.showError(context, 'Failed to pick image: $e');
    }
  }

  void _showImagePickerDialog() {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDarkMode),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.getDividerColor(isDarkMode),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.getPrimaryColor(isDarkMode),
        foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        elevation: 4,
        shadowColor: AppColors.getShadowColor(isDarkMode),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final state = context.read<AuthBloc>().state;
      if (state is Authenticated) {
        final currentUser = state.user;
        
        String? photoUrl = _currentPhotoUrl;
        bool imageUpdated = false;
        List<String> updatedFields = [];
        
        // Upload new image if selected
        if (_selectedImage != null) {
          try {
            photoUrl = await context.read<AuthBloc>().uploadProfileImage(_selectedImage!, currentUser.id.toString());
            imageUpdated = true;
            updatedFields.add('profile_image');
          } catch (e) {
            SnackbarUtil.showError(context, 'Failed to upload image: $e');
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
        
        // Create updated user model
        final updatedUser = UserModel(
          id: currentUser.id,
          name: _nameController.text.trim(),
          email: currentUser.email,
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
          photoUrl: photoUrl,
          subscriptionId: currentUser.subscriptionId,
          subscription: currentUser.subscription,
        );

        // Check what fields were updated and collect them
        if (currentUser.name != updatedUser.name) {
          updatedFields.add('name');
        }
        
        if (currentUser.phoneNumber != updatedUser.phoneNumber) {
          updatedFields.add('phone');
        }
        
        if (currentUser.city != updatedUser.city) {
          updatedFields.add('city');
        }
        
        if (currentUser.address != updatedUser.address) {
          updatedFields.add('address');
        }
        
        if (currentUser.postalCode != updatedUser.postalCode) {
          updatedFields.add('postalCode');
        }

        // Update user profile
        context.read<AuthBloc>().add(UpdateProfileEvent(updatedUser));
        
        // Trigger batch profile update notification if any fields were updated
        if (updatedFields.isNotEmpty) {
          final notificationService = sl<NotificationService>();
          await notificationService.triggerBatchProfileUpdateNotification(
            updatedFields: updatedFields,
            icon: '👤', // Use profile icon
          );
        }
        
        SnackbarUtil.showSuccess(context, 'Profile updated successfully');
        context.pop();
      }
    } catch (e) {
      SnackbarUtil.showError(context, 'Failed to update profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileImageSection() {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
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
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.2),
          width: 1,
        ),
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
          // Profile Image
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.getPrimaryColor(isDarkMode).withValues(alpha: 0.3),
                        width: 4,
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
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : _currentPhotoUrl != null
                              ? Image.network(
                                  _currentPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.getBackgroundColor(isDarkMode),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.getPrimaryColor(isDarkMode),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: AppColors.getBackgroundColor(isDarkMode),
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.getPrimaryColor(isDarkMode),
                                  ),
                                ),
                    ),
                  ),
                ),
                // Edit Button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(isDarkMode),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getShadowColor(isDarkMode),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _showImagePickerDialog,
                      icon: Icon(
                        Icons.edit,
                        color: isDarkMode ? AppColors.darkBackground : Colors.white,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          TextButton(
            onPressed: _showImagePickerDialog,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.getPrimaryColor(isDarkMode),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimaryColor(isDarkMode),
            ),
          ),
          const Gap(8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              color: AppColors.getTextPrimaryColor(isDarkMode),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: AppColors.getPrimaryColor(isDarkMode),
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: AppColors.getInputBackgroundColor(isDarkMode),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.getDividerColor(isDarkMode),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.getDividerColor(isDarkMode),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.getPrimaryColor(isDarkMode),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.getFailedColor(isDarkMode),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              // Override global theme colors to ensure visibility
              labelStyle: TextStyle(
                color: AppColors.getTextSecondaryColor(isDarkMode),
                fontSize: 14,
              ),
              hintStyle: TextStyle(
                color: AppColors.getTextThinColor(isDarkMode),
                fontSize: 14,
              ),
              floatingLabelStyle: TextStyle(
                color: AppColors.getPrimaryColor(isDarkMode),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

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
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.getTextPrimaryColor(isDarkMode),
          ),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Image Section
            _buildProfileImageSection(),
            const Gap(32),
            
            // Form Fields
            _buildFormField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            
            _buildFormField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            
            _buildFormField(
              controller: _cityController,
              label: 'City',
              icon: Icons.location_city_outlined,
            ),
            
            _buildFormField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home_outlined,
              maxLines: 2,
            ),
            
            _buildFormField(
              controller: _postalCodeController,
              label: 'Postal Code',
              icon: Icons.location_on_outlined,
            ),
            
            const Gap(32),
            
            // Save Button
            CustomFilledButton(
              text: _isLoading ? 'Saving...' : 'Save Changes',
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading ? null : AppAssets.icons.archive.outline,
            ),
          ],
        ),
      ),
    );
  }
} 