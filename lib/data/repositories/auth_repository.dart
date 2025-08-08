import 'dart:io';
import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:spotnav/core/platform/network_info.dart';
import 'package:spotnav/data/data_sources/local/session_local_data_source.dart';
import 'package:spotnav/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:spotnav/data/models/token_model.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
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

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final SessionLocalDataSource _sessionLocalDataSource;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo,
       _sessionLocalDataSource = localDataSource,
       _authRemoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final (user, token) = await _authRemoteDataSource.login(email, password);
      await Future.wait([
        _sessionLocalDataSource.cacheAuthToken(token),
        _sessionLocalDataSource.cacheUserData(user),
      ]);

      return Right(user);
    } on NetworkException {
      return const Left(NetworkFailure(message: 'No internet connection.'));
    } on BadRequestException {
      return const Left(
        InvalidInputFailure(message: 'Please fill in all fields correctly.'),
      );
    } on UnauthenticatedException {
      return const Left(
        UnauthenticatedFailure(message: 'Email or password is incorrect.'),
      );
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error, please try again later.'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unknown error occurred during login: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        return const Left(
          NoConnectionFailure(message: 'You are not connected to the network.'),
        );
      }

      final user = await _authRemoteDataSource.register(name, email, password);
      return Right(user);
    } on NetworkException {
      return const Left(NetworkFailure(message: 'No internet connection.'));
    } on BadRequestException {
      return const Left(
        InvalidInputFailure(message: 'Please fill in all fields correctly.'),
      );
    } on ConflictException {
      return const Left(
        InvalidInputFailure(message: 'Email is already registered.'),
      );
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Server error, please try again later.'),
      );
    } catch (e) {
      return const Left(UnexpectedFailure(message: 'Something went wrong'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus() async {
    try {
      final result = await Future.wait([
        _sessionLocalDataSource.getAuthToken(),
        _sessionLocalDataSource.getUserData(),
      ]);
      final tokenModel = result[0] as TokenModel?;
      final userModel = result[1] as UserModel?;

      if (tokenModel != null && userModel != null) {
        return Right(userModel);
      }
      return const Left(
        UnauthenticatedFailure(message: 'No session found. Please log in.'),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on DataParsingException catch (e) {
      return Left(
        UnexpectedFailure(message: 'Cached data parsing error: ${e.message}'),
      );
    } catch (e) {
      return const Left(UnexpectedFailure(message: 'Something went wrong'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _sessionLocalDataSource.clearSession();
    } on CacheException catch (e) {
      debugPrint('Error during logout: ${e.message}');
    } catch (e) {
      debugPrint('Unknown error during logout: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        throw const NetworkException(message: 'No internet connection.');
      }

      await _authRemoteDataSource.updateUserProfile(user);
      await _sessionLocalDataSource.cacheUserData(user);
    } on NetworkException {
      rethrow;
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to update profile: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        throw const NetworkException(message: 'No internet connection.');
      }

      return await _authRemoteDataSource.uploadProfileImage(imageFile, userId);
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to upload profile image: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final connected = await _networkInfo.isConnected();
      if (!connected) {
        throw const NetworkException(message: 'No internet connection.');
      }

      // Delete account from remote data source
      await _authRemoteDataSource.deleteAccount();
      
      // Clear local session data
      await _sessionLocalDataSource.clearSession();
    } on NetworkException {
      rethrow;
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete account: ${e.toString()}',
        error: e,
      );
    }
  }
}
