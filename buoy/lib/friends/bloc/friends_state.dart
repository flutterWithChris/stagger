part of 'friends_bloc.dart';

@immutable
abstract class FriendsState {
  final List<User> friends;
  final List<Location> locations;
  const FriendsState({
    this.friends = const [],
    this.locations = const [],
  });
}

class FriendsInitial extends FriendsState {}

class FriendsLoaded extends FriendsState {
  @override
  final List<User> friends;
  @override
  final List<Location> locations;

  const FriendsLoaded(this.friends, this.locations);
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);
}

class FriendsLoading extends FriendsState {}
