import 'package:buoy/rides/model/ride.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class RideRepository {
  sb.SupabaseClient client = sb.Supabase.instance.client;
  SupabaseQueryBuilder ridesTable = sb.Supabase.instance.client.from('rides');
  SupabaseQueryBuilder rideParticipantsTable =
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

  Future<sb.PostgrestResponse> updateRide(Ride ride) async {
    try {
      return await ridesTable.upsert(ride.toJson());
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

  Future<List<Ride>?> getMyRides(String userId) async {
    try {
      List<Map<String, dynamic>> response =
          await ridesTable.select().eq('user_id', userId);

      return response.map((e) => Ride.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<(List<Ride> myRides, List<Ride> receivedRides)> getReceivedRides(
      String userId) {
    print('Getting received rides for user: $userId');

    // Stream from ride_participants table
    final rideParticipantsStream =
        rideParticipantsTable.stream(primaryKey: ['id']).eq('user_id', userId);

    // Stream from rides table
    final ridesStream = ridesTable.stream(primaryKey: ['id']);

    // Combine both streams
    return CombineLatestStream.combine2(
      rideParticipantsStream,
      ridesStream,
      (participants, rides) async {
        List<Ride> receivedRides = [];
        List<Ride> myCreatedRides = [];

        if (participants.isNotEmpty) {
          // Extract ride IDs
          final receivedRideIds = participants
              .where((p) => p['role'] == 'receiver')
              .map((p) => p['ride_id'])
              .toList();

          final myRideIds = participants
              .where((p) => p['role'] == 'sender')
              .map((p) => p['ride_id'])
              .toList();

          // Fetch the corresponding rides
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
        }

        return (myCreatedRides, receivedRides);
      },
    ).asyncMap((data) async => data);
  }
}
