part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class AuthFailed extends AuthState {
  final String message;

  const AuthFailed(this.message);

  @override
  List<Object> get props => [message];
}

class RegistrationSuccess extends AuthState {
  final UserModel registeredUser;
  const RegistrationSuccess(this.registeredUser);

  @override
  List<Object> get props => [registeredUser];
}

class ProfileUpdated extends AuthState {
  final UserModel updatedUser;
  const ProfileUpdated(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}
