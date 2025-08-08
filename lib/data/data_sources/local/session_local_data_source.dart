import 'dart:convert';

import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/token_model.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SessionLocalDataSource {
  Future<void> cacheAuthToken(TokenModel tokenModel);
  Future<TokenModel?> getAuthToken();
  Future<void> cacheUserData(UserModel user);
  Future<UserModel?> getUserData();
  Future<void> clearSession();
}

class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  static const String _tokenKey = 'cached_token_key';
  static const String _userKey = 'cached_user_key';

  final SharedPreferences _sharedPreferences;
  const SessionLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<void> cacheAuthToken(TokenModel tokenModel) {
    try {
      final jsonString = jsonEncode(tokenModel.toJson());
      return _sharedPreferences.setString(_tokenKey, jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache auth token: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<TokenModel?> getAuthToken() {
    try {
      final jsonString = _sharedPreferences.getString(_tokenKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> responseBody = jsonDecode(jsonString);
        return Future.value(TokenModel.fromJson(responseBody));
      }
      return Future.value(null);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Corrupted token data in cache: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Corrupted token data type in cache: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to get auth token: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> cacheUserData(UserModel user) {
    try {
      final jsonString = jsonEncode(user.toJson());
      return _sharedPreferences.setString(_userKey, jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user data: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<UserModel?> getUserData() {
    try {
      final jsonString = _sharedPreferences.getString(_userKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> responseBody = jsonDecode(jsonString);
        return Future.value(UserModel.fromJson(responseBody));
      }
      return Future.value(null);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Corrupted user data in cache: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Corrupted user data type in cache: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to get user data from cache: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> clearSession() {
    try {
      return Future.wait([
        _sharedPreferences.remove(_tokenKey),
        _sharedPreferences.remove(_userKey),
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear session: ${e.toString()}',
        error: e,
      );
    }
  }
}
