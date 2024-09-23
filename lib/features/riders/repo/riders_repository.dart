import 'package:buoy/core/constants.dart';
import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/locate/model/location.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RidersRepository {
  SupabaseQueryBuilder ridersTable = Supabase.instance.client.from('riders');
  SupabaseQueryBuilder locationUpdatesTable =
      Supabase.instance.client.from('location_updates');

  Future<void> createRider(Rider rider) async {
    try {
      await ridersTable.insert(rider.toMap());
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to create rider'),
      );
      await Sentry.captureException(
        error,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

// Update rider
  Future<Either<Failure, Rider>> updateRider(Rider rider) async {
    try {
      final response =
          await ridersTable.update(rider.toMap()).eq('id', rider.id!).select();
      return Right(Rider.fromMap(response.first));
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to update rider'),
      );
      await Sentry.captureException(
        error,
        stackTrace: StackTrace.current,
      );
      return Left(DatabaseFailure('Failed to update rider'));
    }
  }

  Future<Rider> fetchRider(String riderId) async {
    try {
      final response = await ridersTable.select().eq('id', riderId).single();

      return Rider.fromMap(response);
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to fetch rider'),
      );
      await Sentry.captureException(
        error,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Future<List<Rider>> fetchRidersWithinBounds(LatLngBounds bounds) async {
    try {
      final locationResponse = await supabase.rpc('riders_in_view', params: {
        'min_lat': bounds.southWest.latitude,
        'max_lat': bounds.northEast.latitude,
        'min_long': bounds.southWest.longitude,
        'max_long': bounds.northEast.longitude,
      });

      if (locationResponse.isEmpty) {
        return []; // No riders found in the bounds
      }
      // Step 2: Extract rider IDs from location updates
      final riderIds =
          locationResponse.map((location) => location['id'] as String).toList();

      // Step 3: Fetch rider details based on rider IDs
      final ridersResponse = await ridersTable
          .select()
          .inFilter('id', riderIds)
          .eq('location_status', 'sharing')
          .select();
      // Step 4: Map the results to Rider models and attach location
      List<Rider> riders = ridersResponse.map((rider) {
        final matchingLocation = locationResponse.firstWhere(
          (location) => location['id'] == rider['id'],
        );
        return Rider.fromMap(rider).copyWith(
          currentLocation: Location(
            userId: rider['id'] as String,
            latitude: matchingLocation['latitude'],
            longitude: matchingLocation['longitude'],
            timeStamp: 'Just now',
          ),
        );
      }).toList();

      return riders;
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to fetch riders'),
      );
      await Sentry.captureException(
        error,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Stream<List<Rider>> streamRiderLocations(List<Rider> riders) {
    return locationUpdatesTable.stream(primaryKey: ['user_id']).map((payload) {
      // Assuming payload.newRecord contains the updated location data
      final locationData = payload;

      List<Rider> ridersWithLocation = riders.map((rider) {
        final matchingLocation = locationData.firstWhere(
          (location) => location['user_id'] == rider.id,
        );
        return rider.copyWith(
          currentLocation: Location(
            userId: matchingLocation['user_id'] as String,
            latitude: matchingLocation['latitude'],
            longitude: matchingLocation['longitude'],
            timeStamp: 'Just now',
          ),
        );
      }).toList();

      return ridersWithLocation;
    }).handleError((error) async {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to stream rider locations'),
      );
      await Sentry.captureException(
        error,
        stackTrace: StackTrace.current,
      );
      return [];
    });
  }

  Future<List<Rider>> fetchRiders(List<String> riderIds) async {
    try {
      final ridersResponse =
          await ridersTable.select().inFilter('id', riderIds).select();

      // Step 1: Fetch location updates within the bounds
      final locationResponse =
          await locationUpdatesTable.select().inFilter('user_id', riderIds);

      // Step 4: Map the results to Rider models and attach location
      return ridersResponse.map((rider) {
        // **Check if there's a matching location**
        final matchingLocation = locationResponse.firstWhereOrNull(
          (location) => location['user_id'] == rider['id'],
        );

        // **Return Rider with or without location, depending on if it's found**
        return Rider.fromMap(rider).copyWith(
          currentLocation: matchingLocation != null
              ? Location(
                  userId: rider['id'] as String,
                  latitude: matchingLocation['latitude'],
                  longitude: matchingLocation['longitude'],
                  timeStamp: 'Just now',
                )
              : null, // **Handle case where there's no location**
        );
      }).toList();
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to fetch riders'),
      );
      await Sentry.captureException(
        error,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }
}
