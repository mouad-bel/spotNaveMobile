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
                        _pickImage(ImageSource.gallery);
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
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              if (_currentPhotoUrl != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteCurrentImage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Current Image'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _deleteCurrentImage() {
    setState(() {
      _selectedImage = null;
      _currentPhotoUrl = null;
    });
    SnackbarUtil.showSuccess(context, 'Image deleted');
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
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: const CustomBackButton(),
        forceMaterialTransparency: true,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
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
                                            return ImageIcon(
                                              AssetImage(AppAssets.icons.user.profile),
                                              size: 60,
                                            );
                                          },
                                        )
                                      : ImageIcon(
                                          AssetImage(AppAssets.icons.user.profile),
                                          size: 60,
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
                            onPressed: _showImagePickerDialog,
                            icon: ImageIcon(
                              AssetImage(AppAssets.icons.edit),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  TextButton(
                    onPressed: _showImagePickerDialog,
                    child: const Text('Change Photo'),
                  ),
                ],
              ),
            ),
            const Gap(20),
            
            // Form Fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const Gap(16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const Gap(16),
            
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const Gap(16),
            
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(32),
            
            CustomFilledButton(
              text: 'Save Changes',
              onPressed: _isLoading ? null : _saveProfile,
              icon: AppAssets.icons.archive.outline,
            ),
          ],
        ),
      ),
    );
  }
} 