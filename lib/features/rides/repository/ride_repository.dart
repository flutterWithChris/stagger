import 'package:buoy/features/rides/model/ride.dart';
import 'package:buoy/features/rides/model/ride_participant.dart';
import 'package:buoy/core/constants.dart';
import 'package:flutter_map/flutter_map.dart';
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
      final rideResponse = await ridesTable.insert(ride.toSupabase()).select();
      print('Ride Response: $rideResponse');
      // Check if the ride was successfully inserted
      if (rideResponse.first.isNotEmpty) {
        final insertedRide = rideResponse.first;
        final rideId = insertedRide['id'];

        // Insert the sender participants into the ride_participants table
        if (ride.senderIds != null) {
          for (String senderId in ride.senderIds!) {
            await rideParticipantsTable.insert({
              'id': senderId,
              'ride_id': rideId,
              'user_id': senderId,
              'role': 'sender',
            });
          }
        }

        // Insert the receiver participants into the ride_participants table
        if (ride.receiverIds != null) {
          for (String receiverId in ride.receiverIds!) {
            await rideParticipantsTable.insert({
              'id': receiverId,
              'ride_id': rideId,
              'user_id': receiverId,
              'role': 'receiver',
            });
          }
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
  Stream<List<RideParticipant>> getMyParticipantsStream(String userId) {
    print('Getting received rides for user: $userId');

    return rideParticipantsTable
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .handleError((error) {
          print('Error fetching participants: $error');
          return []; // Return an empty list in case of error
        })
        .map((data) => data.isNotEmpty
            ? data.map((data) => RideParticipant.fromMap(data)).toList()
            : []); // Return empty list if no data
  }

  // Stream rides within bounds
  Stream<List<Ride>> getRidesStream() {
    return ridesTable.stream(primaryKey: ['id']).map(
        (data) => data.map((e) => Ride.fromJson(e)).toList());
  }

  Stream<List<RideParticipant>> getRideParticipantsStream(String rideId) {
    final supabase = sb.Supabase.instance.client;

    return supabase
        .from('ride_participants')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .asyncMap((participants) async {
          if (participants.isNotEmpty) {
            // Fetch user data for each participant
            final futures = participants.map((participant) async {
              final userId =
                  participant['user_id']; // Assuming user_id is the field
              final userData = await supabase
                  .from('users')
                  .select('first_name, photo_url')
                  .eq('id', userId)
                  .single();

              if (userData.isNotEmpty) {
                // Add user data to participant
                participant['first_name'] = userData['first_name'];
                participant['photo_url'] = userData['photo_url'];
              }

              return RideParticipant.fromMap(participant);
            }).toList();
            print('Ride Participants: $futures');
            // Wait for all user data to be fetched
            return await Future.wait(futures);
          } else {
            print('No ride participants found.');
            return <RideParticipant>[];
          }
        });
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

  // Finish ride by moving the ride & pariticipants to the past_rides & past_ride_participants tables respectively and deleting them from the rides & ride_participants tables
  // Update the ride status to 'completed'
  Future<Ride?> finishRide(Ride ride) async {
    try {
      // Add the ride to the past_rides table
      final pastRideResponse = await client
          .from('past_rides')
          .insert(ride.copyWith(status: RideStatus.completed).toJson())
          .select();
      // Check if the ride was successfully inserted
      if (pastRideResponse.first.isNotEmpty) {
        final insertedRide = pastRideResponse.first;
        final rideId = insertedRide['id'];

        // Update the ride status to 'completed'
        await client
            .from('rides')
            .update({'status': RideStatus.completed.name}).eq('id', ride.id!);

        // Insert the sender participants into the past_ride_participants table
        for (RideParticipant rideParticipant in ride.rideParticipants!) {
          print('Archiving ride participant: $rideParticipant');
          await client
              .from('past_ride_participants')
              .insert(rideParticipant.copyWith(rideId: rideId).toMap());
        }

        // Delete the ride from the rides table
        await client.from('rides').delete().eq('id', ride.id!);

        // Delete the participants from the ride_participants table
        await client.from('ride_participants').delete().eq('ride_id', ride.id!);

        return Ride.fromMap(pastRideResponse.first);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return null;
  }

  Future<Ride?> cancelRide(Ride ride) async {
    try {
      final response = await ridesTable.delete().eq('id', ride.id!);
      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<Ride?> updateRideStatus(Ride ride, RideStatus status) async {
    try {
      final response = await ridesTable
          .update({'status': status.name})
          .eq('id', ride.id!)
          .select();
      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }

  // Accept ride request
  Future<Ride?> acceptRideRequest(Ride ride, String userId) async {
    try {
      final response = await rideParticipantsTable
          .update({
            'arrival_status': ArrivalStatus.stopped.name,
            'participation_status': ParticipationStatus.accepted.name
          })
          .eq('ride_id', ride.id!)
          .eq('user_id', userId)
          .select();
      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }

  // Decline ride request
  Future<Ride?> declineRideRequest(Ride ride, String userId) async {
    try {
      final response = await rideParticipantsTable
          .update({'participation_status': ParticipationStatus.rejected.name})
          .eq('ride_id', ride.id!)
          .eq('user_id', userId)
          .select();
      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }

  // Join Ride
  Future<Ride?> joinRide(Ride ride, String userId) async {
    try {
      final response = await rideParticipantsTable.insert(RideParticipant(
        id: userId,
        rideId: ride.id,
        userId: userId,
        role: 'receiver',
        arrivalStatus: ArrivalStatus.stopped,
        participationStatus: ParticipationStatus.accepted,
      ).toMap());

      return Ride.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Ride>> fetchRidesWithinBounds(LatLngBounds bounds) async {
    try {
      final ridesWithinBounds = await supabase.rpc('rides_in_view', params: {
        'min_lat': bounds.southWest.latitude,
        'max_lat': bounds.northEast.latitude,
        'min_long': bounds.southWest.longitude,
        'max_long': bounds.northEast.longitude,
      });

      print('Rides Within Bounds Response: $ridesWithinBounds');

      if (ridesWithinBounds.isEmpty) {
        return []; // No riders found in the bounds
      }
      // Step 2: Extract rider IDs from location updates
      final rideIds =
          ridesWithinBounds.map((ride) => ride['id'] as String).toList();

      print('Rider IDs: $rideIds');

      // Step 3: Fetch rider details based on rider IDs
      final ridesResponse =
          await ridesTable.select().inFilter('id', rideIds).select();
      print('Fetched rides within bounds: $ridesResponse');
      // Step 4: Map the results to Rider models and attach location
      List<Ride> rides = ridesResponse.map((ride) {
        return Ride.fromMap(ride);
      }).toList();

      print('Riders Witin Bounds: $rides');

      return rides;
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
