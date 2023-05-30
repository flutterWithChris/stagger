import 'package:bloc/bloc.dart';
import 'package:buoy/friends/repository/friend_repository.dart';
import 'package:buoy/profile/repository/user_repository.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:meta/meta.dart';
import 'package:async/async.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendRepository _friendRepository;
  final UserRepository _userRepository;
  FriendsBloc(
      {required FriendRepository friendRepository,
      required UserRepository userRepository})
      : _friendRepository = friendRepository,
        _userRepository = userRepository,
        super(FriendsLoading()) {
    on<LoadFriends>(_onLoadFriends);
    on<AddFriend>(_onAddFriend);
  }

  void _onLoadFriends(LoadFriends event, Emitter<FriendsState> emit) async {
    print('Loading friends...');
    final List<dynamic> friends = await _friendRepository.getFriendList() ?? [];
    print('Friends in bloc $friends');
    final List<User> friendObjects = [];
    if (friends.isNotEmpty) {
      for (int i = 0; i < friends.length; i++) {
        print('Loading friend: ${friends[i]['friend_id']}');
        final User friend =
            await _userRepository.getUserById(friends[i]['friend_id']) ??
                User();
        friendObjects.add(friend);
      }
    }
    print('Friends loaded: $friendObjects');

    /// Subscribe to friends location updates.
    // Create a list of streams for each friend's location updates
    final locationUpdateStreams = [
      for (final friend in friendObjects)
        _friendRepository.subscribeToFriendsLocation(friend.id!)
    ];

// Combine all of the streams into a single stream using a StreamGroup
    final locationUpdatesStream = StreamGroup.merge(locationUpdateStreams);

    emit(FriendsLoaded(friendObjects, locationUpdatesStream));
  }

  void _onAddFriend(AddFriend event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    print('Adding friend...');
    final User? friend = await _userRepository.getUserByEmail(event.email);
    if (friend != null) {
      await _friendRepository.addFriend(friend);
      print('Friend added');
      add(LoadFriends());
    } else {
      print('Friend not found');
      emit(FriendsError('Friend not found'));
    }
  }
}
