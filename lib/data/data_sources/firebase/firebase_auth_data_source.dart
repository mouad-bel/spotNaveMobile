import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/token_model.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_storage_data_source.dart';

abstract class FirebaseAuthDataSource {
  Future<(UserModel, TokenModel)> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile(UserModel user);
  Future<String> uploadProfileImage(File imageFile, String userId);
  Future<void> deleteAccount();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorageDataSource _storageDataSource;

  const FirebaseAuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required FirebaseStorageDataSource storageDataSource,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _storageDataSource = storageDataSource;

  @override
  Future<(UserModel, TokenModel)> login(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw const UnauthenticatedException(
          message: 'Login failed: No user returned from Firebase',
        );
      }

      // Get user data from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw const UnauthenticatedException(
          message: 'User data not found in database',
        );
      }

      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      final UserModel userModel = UserModel.fromJson(userData);

      // Create token model from Firebase user
      final String? idToken = await user.getIdToken();
      final TokenModel tokenModel = TokenModel(
        accessToken: idToken ?? '',
        refreshToken: user.refreshToken,
        type: 'Bearer',
        expiresIn: 3600, // Default Firebase token expiration
      );

      return (userModel, tokenModel);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw const UnauthenticatedException(
            message: 'No user found with this email',
          );
        case 'wrong-password':
          throw const UnauthenticatedException(
            message: 'Invalid password',
          );
        case 'invalid-email':
          throw const BadRequestException(
            message: 'Invalid email format',
          );
        case 'user-disabled':
          throw const UnauthenticatedException(
            message: 'User account has been disabled',
          );
        default:
          throw ServerException(
            message: 'Authentication failed: ${e.message}',
            error: e,
          );
      }
    } catch (e) {
      if (e is UnauthenticatedException || e is BadRequestException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error during login: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw const ServerException(
          message: 'Registration failed: No user returned from Firebase',
        );
      }

      // Create user model
      final UserModel userModel = UserModel(
        id: user.uid.hashCode, // Using hash code as ID for compatibility
        name: name,
        email: email,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        city: null,
        address: null,
        postalCode: null,
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const ConflictException(
            message: 'User with this email already exists',
          );
        case 'invalid-email':
          throw const BadRequestException(
            message: 'Invalid email format',
          );
        case 'weak-password':
          throw const BadRequestException(
            message: 'Password is too weak',
          );
        default:
          throw ServerException(
            message: 'Registration failed: ${e.message}',
            error: e,
          );
      }
    } catch (e) {
      if (e is ConflictException || e is BadRequestException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error during registration: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(
        message: 'Failed to logout: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get current user: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const UnauthenticatedException(
          message: 'No authenticated user found',
        );
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(user.toJson());
    } catch (e) {
      if (e is UnauthenticatedException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to update user profile: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await _storageDataSource.uploadProfileImage(imageFile, userId);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const UnauthenticatedException(
          message: 'No authenticated user found',
        );
      }

      // Delete user data from Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .delete();

      // Delete user's saved destinations
      final QuerySnapshot savedDestinations = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('savedDestinations')
          .get();

      // Delete all saved destinations
      final WriteBatch batch = _firestore.batch();
      for (final doc in savedDestinations.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete user's notifications
      final QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      // Delete all user notifications
      final WriteBatch notificationBatch = _firestore.batch();
      for (final doc in notifications.docs) {
        notificationBatch.delete(doc.reference);
      }
      await notificationBatch.commit();

      // Delete user's tokens
      final QuerySnapshot tokens = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('tokens')
          .get();

      // Delete all user tokens
      final WriteBatch tokenBatch = _firestore.batch();
      for (final doc in tokens.docs) {
        tokenBatch.delete(doc.reference);
      }
      await tokenBatch.commit();

      // Finally, delete the Firebase Auth user
      await currentUser.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw const UnauthenticatedException(
            message: 'Please log in again before deleting your account',
          );
        default:
          throw ServerException(
            message: 'Failed to delete account: ${e.message}',
            error: e,
          );
      }
    } catch (e) {
      if (e is UnauthenticatedException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to delete account: ${e.toString()}',
        error: e,
      );
    }
  }
} 
