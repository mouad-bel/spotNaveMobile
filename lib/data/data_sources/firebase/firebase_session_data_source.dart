import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/token_model.dart';
import 'package:spotnav/data/models/user_model.dart';

abstract class FirebaseSessionDataSource {
  Future<void> cacheAuthToken(TokenModel tokenModel);
  Future<TokenModel?> getAuthToken();
  Future<void> cacheUserData(UserModel user);
  Future<UserModel?> getUserData();
  Future<void> clearSession();
}

class FirebaseSessionDataSourceImpl implements FirebaseSessionDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const FirebaseSessionDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<void> cacheAuthToken(TokenModel tokenModel) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const UnauthenticatedException(
          message: 'No authenticated user to cache token for',
        );
      }

      // Store token in Firestore for the current user
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('tokens')
          .doc('current')
          .set(tokenModel.toJson());
    } catch (e) {
      if (e is UnauthenticatedException) {
        rethrow;
      }
      throw CacheException(
        message: 'Failed to cache auth token: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<TokenModel?> getAuthToken() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return null;
      }

      // Get token from Firestore
      final DocumentSnapshot tokenDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('tokens')
          .doc('current')
          .get();

      if (!tokenDoc.exists) {
        // If no token in Firestore, try to get from Firebase Auth
        final String? idToken = await currentUser.getIdToken();
        if (idToken != null) {
          return TokenModel(
            accessToken: idToken,
            refreshToken: currentUser.refreshToken,
            type: 'Bearer',
            expiresIn: 3600,
          );
        }
        return null;
      }

      final Map<String, dynamic> tokenData = tokenDoc.data() as Map<String, dynamic>;
      return TokenModel.fromJson(tokenData);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get auth token: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> cacheUserData(UserModel user) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const UnauthenticatedException(
          message: 'No authenticated user to cache data for',
        );
      }

      // Store user data in Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(user.toJson());
    } catch (e) {
      if (e is UnauthenticatedException) {
        rethrow;
      }
      throw CacheException(
        message: 'Failed to cache user data: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<UserModel?> getUserData() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return null;
      }

      // Get user data from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get user data: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        // Clear user data and tokens from Firestore
        await Future.wait([
          _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('tokens')
              .doc('current')
              .delete(),
          // Note: We don't delete the user document itself, just the token
        ]);
      }

      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear session: ${e.toString()}',
        error: e,
      );
    }
  }
} 
