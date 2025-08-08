import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:spotnav/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'auth_state.dart';

// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStartedEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterSubmittedEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class LoggedOutEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final UserModel user;

  const UpdateProfileEvent(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteAccountEvent extends AuthEvent {
  const DeleteAccountEvent();

  @override
  List<Object> get props => [];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static final _logger = Logger('AuthBloc');

  final AuthRepository _repository;

  AuthBloc({required AuthRepository authRepository})
    : _repository = authRepository,
      super(AuthInitial()) {
    _logger.info('AuthBloc initialized with AuthRepository.');
    on<AppStartedEvent>(_onAppStarted);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<LoggedOutEvent>(_onLoggedOut);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onAppStarted(
    AppStartedEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Event: AppStarted - Checking authentication status.');
    emit(AuthLoading());
    final result = await _repository.checkAuthStatus();
    result.fold(
      (failure) {
        _logger.warning('AppStarted: Unauthenticated - ${failure.message}');
        emit(Unauthenticated(message: failure.message));
      },
      (userModel) {
        _logger.info('AppStarted: Authenticated user: ${userModel.email}');
        emit(Authenticated(userModel));
      },
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Event: LoginSubmitted for email: ${event.email}');
    emit(AuthLoading());
    final result = await _repository.login(event.email, event.password);
    result.fold(
      (failure) {
        _logger.severe(
          'LoginSubmitted: Authentication failed: ${failure.message}',
        );
        emit(AuthFailed(failure.message));
      },
      (userModel) {
        _logger.info('LoginSubmitted: User logged in: ${userModel.email}');
        emit(Authenticated(userModel));
      },
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Event: RegisterSubmitted for email: ${event.email}');
    emit(AuthLoading());
    final result = await _repository.register(
      event.name,
      event.email,
      event.password,
    );
    result.fold(
      (failure) {
        _logger.severe(
          'RegisterSubmitted: Registration failed: ${failure.message}',
        );
        emit(AuthFailed(failure.message));
      },
      (userModel) {
        _logger.info('RegisterSubmitted: User registered: ${userModel.email}');
        emit(RegistrationSuccess(userModel));
      },
    );
  }

  Future<void> _onLoggedOut(
    LoggedOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Event: LoggedOut - Clearing session.');
    emit(AuthLoading());
    await _repository.logout();
    _logger.info('LoggedOut: Session cleared, user unauthenticated.');
    emit(const Unauthenticated());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Event: UpdateProfile for user: ${event.user.email}');
    emit(AuthLoading());
    
    try {
      // Update user profile in repository
      await _repository.updateProfile(event.user);
      _logger.info('UpdateProfile: Profile updated successfully');
      // Emit authenticated state with updated user (this will trigger UI rebuild)
      emit(Authenticated(event.user));
    } catch (e) {
      _logger.severe('UpdateProfile: Failed to update profile: $e');
      emit(AuthFailed('Failed to update profile: $e'));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Event: DeleteAccount');
    emit(AuthLoading());
    
    try {
      // Delete account in repository
      await _repository.deleteAccount();
      _logger.info('DeleteAccount: Account deleted successfully');
      emit(const Unauthenticated());
    } catch (e) {
      _logger.severe('DeleteAccount: Failed to delete account: $e');
      emit(AuthFailed('Failed to delete account: $e'));
    }
  }

  // Helper method to upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      _logger.info('UploadProfileImage: Starting upload for user: $userId');
      _logger.info('UploadProfileImage: File path: ${imageFile.path}');
      _logger.info('UploadProfileImage: File exists: ${await imageFile.exists()}');
      
      final result = await _repository.uploadProfileImage(imageFile, userId);
      _logger.info('UploadProfileImage: Upload successful, URL: $result');
      return result;
    } catch (e) {
      _logger.severe('UploadProfileImage: Failed to upload image: $e');
      rethrow;
    }
  }

  // Helper method to delete account
  Future<void> deleteAccount() async {
    try {
      _logger.info('DeleteAccount: Starting account deletion');
      await _repository.deleteAccount();
      _logger.info('DeleteAccount: Account deleted successfully');
    } catch (e) {
      _logger.severe('DeleteAccount: Failed to delete account: $e');
      rethrow;
    }
  }
}
