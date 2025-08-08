import 'dart:io';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:spotnav/data/repositories/auth_repository.dart';
import 'package:spotnav/data/repositories/destination_repository.dart';
import 'package:spotnav/data/repositories/saved_destination_repository.dart';
import 'package:spotnav/data/repositories/firebase_auth_repository.dart';
import 'package:spotnav/data/repositories/firebase_destination_repository.dart';
import 'package:spotnav/data/repositories/firebase_saved_destination_repository.dart';
import 'package:spotnav/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

// Adapter to make FirebaseAuthRepository compatible with AuthRepository interface
class FirebaseAuthRepositoryAdapter implements AuthRepository {
  final FirebaseAuthRepository _firebaseAuthRepository;

  FirebaseAuthRepositoryAdapter(this._firebaseAuthRepository);

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) {
    return _firebaseAuthRepository.login(email, password);
  }

  @override
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
  ) {
    return _firebaseAuthRepository.register(name, email, password);
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus() {
    return _firebaseAuthRepository.checkAuthStatus();
  }

  @override
  Future<void> logout() {
    return _firebaseAuthRepository.logout();
  }

  @override
  Future<void> updateProfile(UserModel user) {
    return _firebaseAuthRepository.updateProfile(user);
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) {
    return _firebaseAuthRepository.uploadProfileImage(imageFile, userId);
  }

  @override
  Future<void> deleteAccount() {
    return _firebaseAuthRepository.deleteAccount();
  }
}

// Adapter to make FirebaseDestinationRepository compatible with DestinationRepository interface
class FirebaseDestinationRepositoryAdapter implements DestinationRepository {
  final FirebaseDestinationRepository _firebaseDestinationRepository;

  FirebaseDestinationRepositoryAdapter(this._firebaseDestinationRepository);

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchAll() {
    return _firebaseDestinationRepository.fetchAll();
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamAll() {
    return _firebaseDestinationRepository.streamAll();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchPopular() {
    return _firebaseDestinationRepository.fetchPopular();
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamPopular() {
    return _firebaseDestinationRepository.streamPopular();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchNearby(
    double latitude,
    double longitude,
    double radius,
  ) {
    return _firebaseDestinationRepository.fetchNearby(latitude, longitude, radius);
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamNearby(
    double latitude,
    double longitude,
    double radius,
  ) {
    return _firebaseDestinationRepository.streamNearby(latitude, longitude, radius);
  }

  @override
  Future<Either<Failure, DestinationModel>> findById(String id) {
    return _firebaseDestinationRepository.findById(id);
  }

  @override
  Stream<Either<Failure, DestinationModel?>> streamById(String id) {
    return _firebaseDestinationRepository.streamById(id);
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchByCategory(String category) {
    return _firebaseDestinationRepository.fetchByCategory(category);
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamByCategory(String category) {
    return _firebaseDestinationRepository.streamByCategory(category);
  }

  @override
  Future<Either<Failure, List<String>>> fetchAllCategories() {
    return _firebaseDestinationRepository.fetchAllCategories();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> searchDestinations(String query) {
    return _firebaseDestinationRepository.searchDestinations(query);
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> fetchTodaysTopSpots() {
    return _firebaseDestinationRepository.fetchTodaysTopSpots();
  }

  @override
  Stream<Either<Failure, List<DestinationModel>>> streamTodaysTopSpots() {
    return _firebaseDestinationRepository.streamTodaysTopSpots();
  }

  @override
  Future<Either<Failure, List<DestinationModel>>> getSimilarDestinations({
    required String category,
    required String excludeDestinationId,
  }) {
    return _firebaseDestinationRepository.getSimilarDestinations(
      category: category,
      excludeDestinationId: excludeDestinationId,
    );
  }
}

// Adapter to make FirebaseSavedDestinationRepository compatible with SavedDestinationRepository interface
class FirebaseSavedDestinationRepositoryAdapter implements SavedDestinationRepository {
  final FirebaseSavedDestinationRepository _firebaseSavedDestinationRepository;

  FirebaseSavedDestinationRepositoryAdapter(this._firebaseSavedDestinationRepository);

  @override
  Future<Either<Failure, void>> save(SavedDestinationModel destination) {
    return _firebaseSavedDestinationRepository.save(destination);
  }

  @override
  Future<Either<Failure, void>> remove(String destinationId) {
    return _firebaseSavedDestinationRepository.remove(destinationId);
  }

  @override
  Future<Either<Failure, List<SavedDestinationModel>>> fetchSaved() {
    return _firebaseSavedDestinationRepository.fetchSaved();
  }

  @override
  Future<Either<Failure, bool>> isSaved(String destinationId) {
    return _firebaseSavedDestinationRepository.isSaved(destinationId);
  }
} 
