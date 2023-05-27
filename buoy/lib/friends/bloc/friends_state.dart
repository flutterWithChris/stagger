part of 'friends_bloc.dart';

@immutable
abstract class FriendsState {
  final List<User> friends;
  const FriendsState({
    this.friends = const [],
  });
}

class FriendsInitial extends FriendsState {}

class FriendsLoaded extends FriendsState {
  @override
  final List<User> friends;

  const FriendsLoaded(this.friends);
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);
}

class FriendsLoading extends FriendsState {}
