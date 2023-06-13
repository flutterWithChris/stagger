import 'package:buoy/locate/model/location.dart';
import 'package:buoy/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LocationRealtimeRepository {
  final SupabaseClient _supabase = supabase;

  Future<void> sendLocationUpdate(Location location) async {
    try {
      // Delete the existing location data
      var existingData = await supabase
          .from('location_updates')
          .delete()
          .eq('user_id', _supabase.auth.currentUser!.id);
      print('existingData: $existingData');
      // TODO: Handle errors

      final response = await _supabase.from('location_updates').insert([
        location.toJson(),
      ]);
    } catch (e) {
      print('Error sending location update: $e');
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(
            'Error sending location update: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
      throw e;
    }
  }

  /// Send Location Obect to Supabase
}
