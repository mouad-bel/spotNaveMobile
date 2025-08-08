import 'dart:io';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_auth_data_source.dart';
import 'package:spotnav/data/data_sources/firebase/firebase_session_data_source.dart';
import 'package:spotnav/data/models/token_model.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';

abstract class FirebaseAuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, UserModel>> checkAuthStatus();
  Future<void> logout();
  Future<void> updateProfile(UserModel user);
  Future<String> uploadProfileImage(File imageFile, String userId);
  Future<void> deleteAccount();
}

class FirebaseAuthRepositoryImpl implements FirebaseAuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirebaseSessionDataSource _sessionDataSource;
  final NetworkInfo _networkInfo;

  const FirebaseAuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirebaseSessionDataSource sessionDataSource,
    required NetworkInfo networkInfo,
  }) : _authDataSource = authDataSource,
       _sessionDataSource = sessionDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final (user, token) = await _authDataSource.login(email, password);
      
      // Cache the user data and token
      await _sessionDataSource.cacheUserData(user);
      await _sessionDataSource.cacheAuthToken(token);

      return right(user);
    } on UnauthenticatedException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return left(InvalidInputFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
  ) async {
    final isConnected = await _networkInfo.isConnected();
    if (!isConnected) {
      return left(const NetworkFailure(message: 'No internet connection'));
    }

    try {
      final user = await _authDataSource.register(name, email, password);
      return right(user);
    } on ConflictException catch (e) {
      return left(UnauthenticatedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return left(InvalidInputFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        return right(user);
      } else {
        return left(const UnauthenticatedFailure(message: 'No authenticated user found'));
      }
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authDataSource.logout();
      await _sessionDataSource.clearSession();
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Don't throw here as logout should always succeed from user perspective
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      await _authDataSource.updateUserProfile(user);
      await _sessionDataSource.cacheUserData(user);
    } catch (e) {
      debugPrint('Error during profile update: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      return await _authDataSource.uploadProfileImage(imageFile, userId);
    } catch (e) {
      debugPrint('Error during image upload: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _authDataSource.deleteAccount();
      await _sessionDataSource.clearSession();
    } catch (e) {
      debugPrint('Error during account deletion: $e');
      rethrow;
    }
  }
} 
