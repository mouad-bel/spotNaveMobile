import 'dart:convert';

import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/data_sources/local/session_local_data_source.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class DestinationRemoteDataSource {
  Future<List<DestinationModel>> fetchPopular();
  Future<List<DestinationModel>> fetchAll();
  Future<List<DestinationModel>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  );
  Future<DestinationModel> findById(String id);
  Future<List<DestinationModel>> fetchByCategory(String category);
  Future<List<DestinationModel>> fetchTodaysTopSpots();
  Future<List<DestinationModel>> searchDestinations(String query);
  Future<List<String>> fetchAllCategories();
  Future<List<DestinationModel>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  });
}

class DestinationRemoteDataSourceImpl implements DestinationRemoteDataSource {
  static const String _baseURL = 'https://fdelux.globeapp.dev/api/destinations';

  final http.Client _client;
  final SessionLocalDataSource _sessionLocalDataSource;

  const DestinationRemoteDataSourceImpl({
    required http.Client client,
    required SessionLocalDataSource sessionLocalDataSource,
  }) : _sessionLocalDataSource = sessionLocalDataSource,
       _client = client;

  Future<String> _getAuthHeader() async {
    final tokenModel = await _sessionLocalDataSource.getAuthToken();
    if (tokenModel == null || tokenModel.accessToken.isEmpty) {
      throw const UnauthenticatedException(
        message: 'Authentication token missing.',
      );
    }
    return 'Bearer ${tokenModel.accessToken}';
  }

  @override
  Future<List<DestinationModel>> fetchAll() async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson =
            responseBody['data']['destinations'] as List<dynamic>;
        final List<DestinationModel> destinations = await compute(
          _parseJsonArrayDestinations,
          destinationsJson,
        );
        return destinations;
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      throw ServerException(
        message:
            'Failed to fetch all destinations. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<List<DestinationModel>> fetchPopular() async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/popular');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson =
            responseBody['data']['destinations'] as List<dynamic>;
        final List<DestinationModel> destinations = await compute(
          _parseJsonArrayDestinations,
          destinationsJson,
        );
        return destinations;
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      throw ServerException(
        message:
            'Failed to fetch popular destinations. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<List<DestinationModel>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/nearby');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson =
            responseBody['data']['destinations'] as List<dynamic>;
        final List<DestinationModel> destinations = await compute(
          _parseJsonArrayDestinations,
          destinationsJson,
        );
        return destinations;
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      if (statusCode == 404) {
        throw NotFoundException(message: errorMessage, statusCode: statusCode);
      }

      throw ServerException(
        message:
            'Failed to fetch nearby destinations. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<DestinationModel> findById(String id) async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/$id');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        return DestinationModel.fromJson(
          responseBody['data']['destination'] as Map<String, dynamic>,
        );
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      if (statusCode == 404) {
        throw NotFoundException(message: errorMessage, statusCode: statusCode);
      }

      throw ServerException(
        message:
            'Failed to fetch destination by ID. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<List<DestinationModel>> fetchByCategory(String category) async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/category/$category');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson =
            responseBody['data']['destinations'] as List<dynamic>;
        final List<DestinationModel> destinations = await compute(
          _parseJsonArrayDestinations,
          destinationsJson,
        );
        return destinations;
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      throw ServerException(
        message:
            'Failed to fetch destinations by category. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<List<DestinationModel>> fetchTodaysTopSpots() async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/todays-top-spots');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson =
            responseBody['data']['destinations'] as List<dynamic>;
        final List<DestinationModel> destinations = await compute(
          _parseJsonArrayDestinations,
          destinationsJson,
        );
        return destinations;
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      throw ServerException(
        message:
            'Failed to fetch today\'s top spots. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<List<String>> fetchAllCategories() async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/categories');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> categoriesJson =
            responseBody['data']['categories'] as List<dynamic>;
        return categoriesJson.map((category) => category as String).toList();
      }

      String errorMessage =
          responseBody['message'] ?? 'An unknown error occurred.';

      if (statusCode == 401) {
        throw UnauthenticatedException(
          message: errorMessage,
          statusCode: statusCode,
        );
      }

      throw ServerException(
        message:
            'Failed to fetch all categories. Status code: $statusCode, Body: ${response.body}',
        statusCode: statusCode,
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
  Future<List<DestinationModel>> searchDestinations(String query) async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/search?q=${Uri.encodeComponent(query)}');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson = responseBody['data'] as List<dynamic>;
        return _parseJsonArrayDestinations(destinationsJson);
      } else {
        throw ServerException(message: responseBody['message'] ?? 'Search failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DestinationModel>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  }) async {
    try {
      final String authHeader = await _getAuthHeader();
      final Uri uri = Uri.parse('$_baseURL/similar?category=${Uri.encodeComponent(category)}&exclude=$excludeDestinationId');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        final List<dynamic> destinationsJson = responseBody['data'] as List<dynamic>;
        return _parseJsonArrayDestinations(destinationsJson);
      } else {
        throw ServerException(message: responseBody['message'] ?? 'Failed to get similar destinations');
      }
    } catch (e) {
      rethrow;
    }
  }
}

List<DestinationModel> _parseJsonArrayDestinations(
  List<dynamic> jsonArrayDestinations,
) {
  return jsonArrayDestinations
      .map((item) => DestinationModel.fromJson(item as Map<String, dynamic>))
      .toList();
}
