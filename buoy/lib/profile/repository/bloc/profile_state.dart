part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {
  final User? user;
  const ProfileState({this.user});
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
