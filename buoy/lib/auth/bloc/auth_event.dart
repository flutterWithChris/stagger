part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthUserChanged extends AuthEvent {
  final supabase.User? user;

  const AuthUserChanged(this.user);
}
