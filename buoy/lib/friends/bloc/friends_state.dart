part of 'friends_bloc.dart';

@immutable
abstract class FriendsState {
  final Stream<List<Location>>? locationUpdatesStream;

  final List<User> friends;
  const FriendsState({
    this.friends = const [],
    this.locationUpdatesStream,
  });
}

class FriendsInitial extends FriendsState {}

class FriendsLoaded extends FriendsState {
  @override
  final List<User> friends;
  @override
  final Stream<List<Location>> locationUpdatesStream;

  const FriendsLoaded(this.friends, this.locationUpdatesStream);
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);
}

class FriendsLoading extends FriendsState {}
