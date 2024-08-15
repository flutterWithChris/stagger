import 'package:buoy/locate/model/location.dart';
import 'package:buoy/riders/model/rider.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RidersRepository {
  SupabaseQueryBuilder ridersTable = Supabase.instance.client.from('riders');
  SupabaseQueryBuilder locationUpdatesTable =
      Supabase.instance.client.from('location_updates');

  Future<List<Rider>> fetchRidersWithinBounds(LatLngBounds bounds) async {
    try {
      final southwest = bounds.southWest;
      final northeast = bounds.northEast;

      // Step 1: Fetch location updates within the bounds
      final locationResponse = await locationUpdatesTable
          .select()
          .gt('latitude', southwest.latitude)
          .lt('latitude', northeast.latitude)
          .gt('longitude', southwest.longitude)
          .lt('longitude', northeast.longitude);

      print('Location Response: ${locationResponse.length}');

      if (locationResponse.isEmpty) {
        return []; // No riders found in the bounds
      }
      // Step 2: Extract rider IDs from location updates
      final riderIds = locationResponse
          .map((location) => location['user_id'] as String)
          .toList();

      // Step 3: Fetch rider details based on rider IDs
      final ridersResponse = await ridersTable
          .select('*')
          .inFilter('id', riderIds)
          .eq('location_status', 'sharing')
          .select();

      // Step 4: Map the results to Rider models and attach location
      return ridersResponse.map((rider) {
        final matchingLocation = locationResponse.firstWhere(
          (location) => location['user_id'] == rider['id'],
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
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<Rider>> fetchRiders(List<String> riderIds) async {
    try {
      print('Fetching riders: $riderIds');
      final response =
          await ridersTable.select().inFilter('id', riderIds).select();
      return response.map((rider) => Rider.fromMap(rider)).toList();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
