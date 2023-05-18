part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

@immutable
class AuthState extends Equatable {
  final AuthStatus? status;
  final supabase.User? user;
  const AuthState({this.status, this.user});
  @override
  List<Object?> get props => [status, user];

  AuthState copyWith({AuthStatus? status}) {
    return AuthState(status: status ?? this.status);
  }

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.unknown);
  }

  factory AuthState.authenticated(supabase.User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }
}
