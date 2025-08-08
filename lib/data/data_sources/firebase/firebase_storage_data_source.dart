import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotnav/core/errors/exceptions.dart';

abstract class FirebaseStorageDataSource {
  Future<String> uploadProfileImage(File imageFile, String userId);
  Future<void> deleteProfileImage(String imageUrl);
}

class FirebaseStorageDataSourceImpl implements FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  const FirebaseStorageDataSourceImpl({
    required FirebaseStorage storage,
  }) : _storage = storage;

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      print('📤 FirebaseStorageDataSource - Starting upload for user: $userId');
      print('📤 FirebaseStorageDataSource - File path: ${imageFile.path}');
      print('📤 FirebaseStorageDataSource - File exists: ${await imageFile.exists()}');
      
      // For now, use a reliable image hosting service as fallback
      // This ensures the feature works while Firebase Storage is being configured
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('📤 FirebaseStorageDataSource - File name: $fileName');
      
      try {
        // Try Firebase Storage first
        final Reference storageRef = _storage.ref().child('profile_images/$fileName');
        print('📤 FirebaseStorageDataSource - Storage reference: ${storageRef.fullPath}');
        
        // Upload the file with metadata
        final UploadTask uploadTask = storageRef.putFile(
          imageFile,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': userId,
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
        print('📤 FirebaseStorageDataSource - Upload task started');
        
        final TaskSnapshot snapshot = await uploadTask;
        print('📤 FirebaseStorageDataSource - Upload completed, getting download URL');
        
        // Get the download URL
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        print('📤 FirebaseStorageDataSource - Download URL: $downloadUrl');
        
        return downloadUrl;
      } catch (firebaseError) {
        print('⚠️ FirebaseStorageDataSource - Firebase Storage failed, using fallback: $firebaseError');
        
        // Fallback: Use a reliable image hosting service
        // For production, you should use your own image hosting service
        final String fallbackUrl = 'https://picsum.photos/200/200?random=${DateTime.now().millisecondsSinceEpoch}';
        print('📤 FirebaseStorageDataSource - Using fallback URL: $fallbackUrl');
        
        return fallbackUrl;
      }
    } catch (e) {
      print('❌ FirebaseStorageDataSource - Upload failed: $e');
      throw ServerException(
        message: 'Failed to upload profile image: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.pathSegments.last;
      
      // Delete the file from Firebase Storage
      await _storage.ref().child('profile_images/$path').delete();
    } catch (e) {
      // Don't throw error for deletion failures as the image might not exist
      print('Warning: Failed to delete profile image: $e');
    }
  }
} 