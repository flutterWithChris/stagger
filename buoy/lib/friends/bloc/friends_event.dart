part of 'friends_bloc.dart';

@immutable
abstract class FriendsEvent {}

class LoadFriends extends FriendsEvent {}

class AddFriend extends FriendsEvent {
  final String email;

  AddFriend(this.email);
}

class RemoveFriend extends FriendsEvent {
  final String friendId;

  RemoveFriend(this.friendId);
}

class UpdateFriend extends FriendsEvent {
  final User friend;

  UpdateFriend(this.friend);
}
