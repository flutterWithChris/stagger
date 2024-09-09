import 'dart:convert';

import 'package:buoy/features/locate/model/location.dart';
import 'package:buoy/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrpyt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LocationRealtimeRepository {
  final SupabaseClient _supabase = supabase;

  Future<void> sendLocationUpdate(Location location) async {
    try {
      print('-Sent location update-');
      await _supabase.from('location_updates').upsert([
        location
            .copyWith(
                location: 'POINT(${location.longitude} ${location.latitude})')
            .toJson(),
      ], onConflict: 'user_id');
    } catch (e) {
      print('Error updating location: $e');
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text(
            'Error updating location!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  Future<void> deleteLocationUpdate(String userId) async {
    try {
      print('-Deleted location update-');
      await _supabase.from('location_updates').delete().eq('user_id', userId);
    } catch (e) {
      print('Error deleting location: $e');
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text(
            'Error deleting location!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }
}
