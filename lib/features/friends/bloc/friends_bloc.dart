import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buoy/features/friends/repository/friend_repository.dart';
import 'package:buoy/features/locate/model/location.dart';
import 'package:buoy/features/profile/repository/user_repository.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:meta/meta.dart';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendRepository _friendRepository;
  final UserRepository _userRepository;
  StreamSubscription<List<Location>>? _locationUpdatesSubscription;

  FriendsBloc(
      {required FriendRepository friendRepository,
      required UserRepository userRepository})
      : _friendRepository = friendRepository,
        _userRepository = userRepository,
        super(FriendsLoading()) {
    on<LoadFriends>(_onLoadFriends);
    on<AddFriend>(_onAddFriend);
    on<UpdateFriends>(_onUpdateFriends);
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
    // final locationUpdatesListStream =
    //     await _subscribeToFriendsLocationUpdates(friendObjects);
    // _locationUpdatesSubscription =
    //     locationUpdatesListStream.listen((locations) {
    //   print('Locations updated: $locations');
    //   if (locations.isNotEmpty) {
    //     add(UpdateFriends(friendObjects, locations));
    //   }
    // });
    emit(FriendsLoaded(friendObjects, const []));
  }

  void _onUpdateFriends(UpdateFriends event, Emitter<FriendsState> emit) async {
    if (state is! FriendsLoading) {
      emit(FriendsLoading());
    }
    print('Updating friends...');
    emit(FriendsLoaded(event.friends, event.locations));
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
      emit(const FriendsError('Friend not found'));
    }
  }

  Future<Stream<List<Location>>> _subscribeToFriendsLocationUpdates(
      List<User> friendObjects) async {
    // Create a list of streams for each friend's location updates
    final locationUpdateStreams = [
      for (final friend in friendObjects)
        _friendRepository.subscribeToFriendsLocation(friend.id!)
    ];

    // Combine all of the streams into a single stream using a StreamGroup
    final locationUpdatesStream = StreamGroup.merge(locationUpdateStreams);

    final locationUpdatesListStream = locationUpdatesStream
        .distinctUnique(
            equals: (a, b) =>
                a.userId == b.userId && a.timeStamp == b.timeStamp)
        .scan<List<Location>>(
          (List<Location> locationUpdates, Location newLocationUpdate, _) {
            locationUpdates.add(newLocationUpdate);
            return locationUpdates;
          },
          <Location>[],
        )
        .share()
        .asBroadcastStream();

    return locationUpdatesListStream;
  }

  @override
  Future<void> close() async {
    // TODO: implement close
    await _locationUpdatesSubscription?.cancel();
    return super.close();
  }
}
