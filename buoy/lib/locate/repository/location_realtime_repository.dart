import 'dart:convert';

import 'package:buoy/locate/model/location.dart';
import 'package:buoy/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrpyt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LocationRealtimeRepository {
  final SupabaseClient _supabase = supabase;

  Future<void> sendLocationUpdate(Location location) async {
    try {
      await _supabase.from('location_updates').upsert([
        location.toJson(),
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
}
