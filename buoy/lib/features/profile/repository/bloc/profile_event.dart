part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile(this.userId);
}

class UpdateProfile extends ProfileEvent {
  final User user;
  UpdateProfile(this.user);
}
