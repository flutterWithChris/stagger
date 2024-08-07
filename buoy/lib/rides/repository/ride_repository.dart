import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/model/ride_participant.dart';
import 'package:buoy/shared/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class RideRepository {
  sb.SupabaseClient client = sb.Supabase.instance.client;
  sb.SupabaseQueryBuilder ridesTable =
      sb.Supabase.instance.client.from('rides');
  sb.SupabaseQueryBuilder rideParticipantsTable =
      sb.Supabase.instance.client.from('ride_participants');

  Future<Ride?> createRide(Ride ride) async {
    print('Creating ride: $ride');
    try {
      // Insert the ride into the rides table
      final rideResponse = await ridesTable.insert(ride.toJson()).select();

      // Check if the ride was successfully inserted
      if (rideResponse.first.isNotEmpty) {
        final insertedRide = rideResponse.first;
        final rideId = insertedRide['id'];

        // Insert the sender participants into the ride_participants table
        for (String senderId in ride.senderIds!) {
          await rideParticipantsTable.insert({
            'ride_id': rideId,
            'user_id': senderId,
            'role': 'sender',
          });
        }

        // Insert the receiver participants into the ride_participants table
        for (String receiverId in ride.receiverIds!) {
          await rideParticipantsTable.insert({
            'ride_id': rideId,
            'user_id': receiverId,
            'role': 'receiver',
          });
        }
      } else {
        // Handle the error when the ride insert fails
        throw Exception(
            'Failed to create ride. Please try again or contact support.');
      }
      print('Created ride: $ride');
      return Ride.fromMap(rideResponse.first);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Ride> updateRide(Ride ride) async {
    try {
      final response =
          await ridesTable.update(ride.toJson()).eq('id', ride.id!).select();
      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<sb.PostgrestResponse> deleteRide(Ride ride) async {
    try {
      return await ridesTable.delete().eq('id', ride.id!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Ride?> getRide(String rideId) async {
    try {
      final response = await ridesTable.select().eq('id', rideId).single();
      return Ride.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  Stream<Ride?> getRideStream(String rideId) {
    return ridesTable
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((data) => data.isNotEmpty ? Ride.fromMap(data.first) : null);
  }

  // Stream of rides created by the user
  Stream<List<Ride>> getMyCreatedRidesStream(String userId) {
    return client
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          return data.map((json) => Ride.fromJson(json)).toList();
        });
  }

  // Stream of rides where the user is a participant
  Stream<List<Ride>>? getParticipantRidesStream(String userId) {
    client
        .from('ride_participants')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          final rideIds =
              data.map((json) => json['ride_id'].toString()).toList();
          print('Ride Ids: $rideIds');
          return client
              .from('rides')
              .stream(primaryKey: ['id'])
              .inFilter('id', rideIds)
              .map((ridesData) {
                return ridesData.map((json) => Ride.fromJson(json)).toList();
              });
        });
    return null;
  }

  Future<List<Ride>?> getMyRides(String userId) async {
    try {
      List<Map<String, dynamic>> response =
          await ridesTable.select().eq('user_id', userId);

      return response.map((e) => Ride.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Stream of rides created by the user (where the user is the sender)
  Stream<List<Ride>> getMyRidesStream(String userId) {
    print('Getting my rides for user: $userId');
    return ridesTable
        .stream(primaryKey: ['id'])
        .eq('user_id', userId) // Assuming there's a created_by field
        .map((data) => data.map((e) => Ride.fromJson(e)).toList());
  }

  // Stream of rides where the user is a participant as a receiver
  sb.SupabaseStreamBuilder getMyParticipantsStream(String userId) {
    print('Getting received rides for user: $userId');

    // Stream of participants where user is involved (either sender or receiver)
    return rideParticipantsTable
        .stream(primaryKey: ['id']).eq('user_id', userId);
  }

  Stream<List<RideParticipant>> getRideParticipantsStream(String rideId) {
    final supabase = sb.Supabase.instance.client;

    return supabase
        .from('ride_participants')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .map((data) =>
            data.map((item) => RideParticipant.fromMap(item)).toList());
  }

  // Stream of all participants in a ride
  Future<List<RideParticipant>?>? getRideParticipants(String rideId) async {
    try {
      print('Getting ride participants for ride: $rideId');
      var response = await rideParticipantsTable.select().eq('ride_id', rideId);

      print('Ride Participants: $response');

      return response.map((e) => RideParticipant.fromMap(e)).toList();
    } catch (e) {
      print(e);
      showErrorSnackbar('Error loading ride participants');
      rethrow;
    }
    return null;
  }

  Stream<
      (
        List<Ride> myRides,
        List<Ride> receivedRides,
        List<RideParticipant> allParticipants
      )> getReceivedRides(String userId) {
    print('Getting received rides for user: $userId');

    final userRideParticipantsStream = sb.Supabase.instance.client
        .from('ride_participants')
        .stream(primaryKey: ['id']).eq('user_id', userId);

    final ridesStream =
        sb.Supabase.instance.client.from('rides').stream(primaryKey: ['id']);

    return CombineLatestStream.combine2(
      userRideParticipantsStream,
      ridesStream,
      (userParticipants, rides) async* {
        List<Ride> receivedRides = [];
        List<Ride> myCreatedRides = [];

        print('User Participants: $userParticipants');

        if (userParticipants.isNotEmpty) {
          final receivedRideIds = userParticipants
              .where((p) => p['role'] == 'receiver')
              .map((p) => p['ride_id'])
              .toList();

          final myRideIds = userParticipants
              .where((p) => p['role'] == 'sender')
              .map((p) => p['ride_id'])
              .toList();

          if (receivedRideIds.isNotEmpty) {
            final receivedRidesData =
                rides.where((ride) => receivedRideIds.contains(ride['id']));
            receivedRides =
                receivedRidesData.map((e) => Ride.fromJson(e)).toList();
          }

          if (myRideIds.isNotEmpty) {
            final myRidesData =
                rides.where((ride) => myRideIds.contains(ride['id']));
            myCreatedRides = myRidesData.map((e) => Ride.fromJson(e)).toList();
          }

          final List<Object> allRelevantRideIds = [
            ...receivedRideIds,
            ...myRideIds
          ];

          if (allRelevantRideIds.isNotEmpty) {
            final allParticipantsStream = sb.Supabase.instance.client
                .from('ride_participants')
                .stream(primaryKey: ['id']).inFilter(
                    'ride_id', allRelevantRideIds);

            await for (final participants in allParticipantsStream) {
              final allParticipants =
                  participants.map((e) => RideParticipant.fromMap(e)).toList();
              print(
                  'All Participants: ${allParticipants.map((e) => e.id).toList()}');
              yield (myCreatedRides, receivedRides, allParticipants);
            }
          } else {
            yield (myCreatedRides, receivedRides, <RideParticipant>[]);
          }
        } else {
          yield (myCreatedRides, receivedRides, <RideParticipant>[]);
        }
      },
    ).asyncExpand((data) => data);
  }

  Future<Ride?> updateArrivalStatus(
      Ride ride, String userId, ArrivalStatus arrivalStatus) async {
    try {
      final response = await rideParticipantsTable
          .update({'arrival_status': arrivalStatus.name})
          .eq('ride_id', ride.id!)
          .eq('user_id', userId)
          .select();

      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }
}
