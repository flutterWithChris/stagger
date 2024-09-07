import 'dart:async';

import 'package:buoy/features/locate/model/location.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class FriendRepository {
  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  /// Fetch a users friends.
  ///  SELECT friend_id FROM Friendships WHERE user_id = ?
  Future<List<dynamic>?> getFriendList() async {
    try {
      print('current user id: ${_client.auth.currentUser!.id}');
      final response = await _client
          .from('friendships')
          .select('friend_id')
          .eq('user_id', _client.auth.currentUser!.id);
      print('Friend list: $response');
      return response;
    } catch (e) {
      print(e);
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Error fetching friend ids'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  /// Get list of user objects for a list of friend ids.
  /// SELECT * FROM Users WHERE id IN ?
  Future<List<User>?> getFriends(Map<String, String> friendsList) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', friendsList.keys.toList());
      print('Friend objects: $response');
      return response.map((e) => User.fromMap(e)).toList();
    } catch (e) {
      print(e);
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Error fetching friends'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  /// Add a friend to the current user's friend list.
  /// INSERT INTO Friendships (user_id, friend_id) VALUES (?, ?)
  Future<void> addFriend(User friend) async {
    try {
      await _client.from('friendships').insert({
        'user_id': _client.auth.currentUser!.id,
        'friend_id': friend.id,
        'status': 'pending',
      });
    } catch (e) {
      print(e);
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Error adding friend'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Subscribe to friend's location updates as Location
  Stream<Location> subscribeToFriendsLocation(String friendId) {
    return _client
        .from('location_updates')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', friendId)
        .map((event) => Location.fromJson(event[0]))
        .asBroadcastStream();
  }
}
