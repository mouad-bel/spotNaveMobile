import 'dart:convert';

import 'package:spotnav/core/errors/exceptions.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SavedDestinationLocalDataSource {
  Future<void> save(SavedDestinationModel destination);
  Future<void> remove(String destinationId);
  Future<List<SavedDestinationModel>> fetchSaved();
  Future<bool> isSaved(String destinationId);
}

class SavedDestinationLocalDataSourceImpl
    implements SavedDestinationLocalDataSource {
  static const String _kCachedSavedDestinations = 'cached_saved_destinations';

  final SharedPreferences _sharedPreferences;

  const SavedDestinationLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  Future<List<SavedDestinationModel>> _readAllSavedDestinations() async {
    try {
      final savedDestinationsJsonString = _sharedPreferences.getString(
        _kCachedSavedDestinations,
      );
      if (savedDestinationsJsonString == null ||
          savedDestinationsJsonString.isEmpty) {
        return [];
      }

      return compute(_parseSavedDestinationJson, savedDestinationsJsonString);
    } on FormatException catch (e) {
      throw DataParsingException(
        message: 'Data corruption: Failed to parse saved destinations JSON',
        error: e,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to read saved destinations from local storage',
        error: e,
      );
    }
  }

  Future<void> _writeAllSavedDestinations(
    List<SavedDestinationModel> destinations,
  ) async {
    try {
      final jsonString = await compute(
        _parseSavedDestinationModel,
        destinations,
      );
      await _sharedPreferences.setString(_kCachedSavedDestinations, jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Failed to write saved destinations to local storage',
        error: e,
      );
    }
  }

  @override
  Future<void> save(SavedDestinationModel destination) async {
    try {
      final savedDestinations = await _readAllSavedDestinations();
      if (!savedDestinations.any((model) => model.id == destination.id)) {
        savedDestinations.add(destination);
        await _writeAllSavedDestinations(savedDestinations);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to save destination', error: e);
    }
  }

  @override
  Future<void> remove(String destinationId) async {
    try {
      final savedDestinations = await _readAllSavedDestinations();
      savedDestinations.removeWhere((model) => model.id == destinationId);
      await _writeAllSavedDestinations(savedDestinations);
    } catch (e) {
      throw CacheException(message: 'Failed to remove destination', error: e);
    }
  }

  @override
  Future<List<SavedDestinationModel>> fetchSaved() async {
    try {
      return _readAllSavedDestinations();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get saved destinations',
        error: e,
      );
    }
  }

  @override
  Future<bool> isSaved(String destinationId) async {
    try {
      final savedDestinations = await _readAllSavedDestinations();
      return savedDestinations.any((model) => model.id == destinationId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to check if destination is saved',
        error: e,
      );
    }
  }
}

List<SavedDestinationModel> _parseSavedDestinationJson(
  String jsonStringSavedDestination,
) {
  final jsonList = jsonDecode(jsonStringSavedDestination) as List<dynamic>;
  return jsonList.map((jsonMap) {
    return SavedDestinationModel.fromJson(jsonMap as Map<String, dynamic>);
  }).toList();
}

String _parseSavedDestinationModel(
  List<SavedDestinationModel> savedDestination,
) {
  final List<Map<String, dynamic>> jsonList = savedDestination
      .map((model) => model.toJson())
      .toList();
  return jsonEncode(jsonList);
}
