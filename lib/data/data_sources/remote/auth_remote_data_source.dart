import 'dart:convert';
import 'dart:io';

import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/token_model.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<(UserModel, TokenModel)> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> updateUserProfile(UserModel user);
  Future<String> uploadProfileImage(File imageFile, String userId);
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String _baseURL = 'https://fdelux.globeapp.dev/api';

  final http.Client _client;

  const AuthRemoteDataSourceImpl({required http.Client client})
    : _client = client;

  @override
  Future<(UserModel, TokenModel)> login(String email, String password) async {
    final Uri uri = Uri.parse('$_baseURL/login');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(
          responseData['data']['user'] as Map<String, dynamic>,
        );
        final token = TokenModel.fromJson(
          responseData['data']['token'] as Map<String, dynamic>,
        );
        return (user, token);
      }

      if (response.statusCode == 400) {
        throw BadRequestException(
          message: responseData['message'] ?? 'Invalid login request format.',
        );
      }

      if (response.statusCode == 401) {
        throw UnauthenticatedException(
          message: responseData['message'] ?? 'Invalid email or password.',
        );
      }

      throw ServerException(
        message: 'Failed to login.',
        statusCode: response.statusCode,
        error: response.body,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}', error: e);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Invalid response format from server: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Unexpected data type during parsing: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final Uri uri = Uri.parse('$_baseURL/register');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return UserModel.fromJson(responseData['data']['user']);
      }

      if (response.statusCode == 400) {
        throw BadRequestException(
          message:
              responseData['message'] ?? 'Invalid registration request format.',
        );
      }

      if (response.statusCode == 409) {
        throw ConflictException(
          message:
              responseData['message'] ?? 'User with this email already exists.',
        );
      }

      throw ServerException(
        message: 'Failed to register.',
        statusCode: response.statusCode,
        error: response.body,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}', error: e);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Invalid response format from server: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Unexpected data type during parsing: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    final Uri uri = Uri.parse('$_baseURL/profile');
    try {
      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return; // Success
      }

      if (response.statusCode == 400) {
        throw BadRequestException(
          message: responseData['message'] ?? 'Invalid profile update request format.',
        );
      }

      if (response.statusCode == 401) {
        throw UnauthenticatedException(
          message: responseData['message'] ?? 'Unauthorized to update profile.',
        );
      }

      throw ServerException(
        message: 'Failed to update profile.',
        statusCode: response.statusCode,
        error: response.body,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}', error: e);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Invalid response format from server: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Unexpected data type during parsing: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    final Uri uri = Uri.parse('$_baseURL/profile/image');
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add the image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      
      // Add user ID
      request.fields['userId'] = userId;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonData['imageUrl'] as String;
      }

      if (response.statusCode == 400) {
        throw BadRequestException(
          message: jsonData['message'] ?? 'Invalid image upload request.',
        );
      }

      if (response.statusCode == 401) {
        throw UnauthenticatedException(
          message: jsonData['message'] ?? 'Unauthorized to upload image.',
        );
      }

      throw ServerException(
        message: 'Failed to upload image.',
        statusCode: response.statusCode,
        error: responseData,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}', error: e);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Invalid response format from server: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Unexpected data type during parsing: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    final Uri uri = Uri.parse('$_baseURL/account/delete');
    try {
      final response = await _client.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return; // Account deleted successfully
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 400) {
        throw BadRequestException(
          message: responseData['message'] ?? 'Invalid delete account request.',
        );
      }

      if (response.statusCode == 401) {
        throw UnauthenticatedException(
          message: responseData['message'] ?? 'Unauthorized to delete account.',
        );
      }

      throw ServerException(
        message: 'Failed to delete account.',
        statusCode: response.statusCode,
        error: response.body,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}', error: e);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Invalid response format from server: ${e.message}',
        error: e,
      );
    } on TypeError catch (e) {
      throw DataParsingException(
        message: 'Unexpected data type during parsing: ${e.toString()}',
        error: e,
      );
    } catch (e) {
      rethrow;
    }
  }
}
