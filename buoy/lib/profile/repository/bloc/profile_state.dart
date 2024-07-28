part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {
  final User? user;
  const ProfileState({this.user});
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  @override
  final User user;
  const ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
