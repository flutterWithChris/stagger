part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginSuccess extends LoginState {}
