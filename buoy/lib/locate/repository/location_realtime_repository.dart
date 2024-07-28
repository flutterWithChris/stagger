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

  Future<Location> encrpytLocationData(Location location) async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    String magnolia = await storage.read(key: 'magnolia') as String;
    final key = encrpyt.Key(base64Url.decode(magnolia));
    final iv = encrpyt.IV.fromLength(16);

    final encrypter = encrpyt.Encrypter(encrpyt.AES(key));

    final encryptedLatitude = encrypter.encrypt(location.latitude, iv: iv);
    final encryptedLongitude = encrypter.encrypt(location.longitude, iv: iv);
    final encryptedLocationString = location.locationString != null
        ? encrypter.encrypt(location.locationString!, iv: iv)
        : null;
    final encryptedCity = location.city != null
        ? encrypter.encrypt(location.city!, iv: iv)
        : null;
    final encryptedState = location.state != null
        ? encrypter.encrypt(location.state!, iv: iv)
        : null;

    return location.copyWith(
      latitude: encryptedLatitude.base64,
      longitude: encryptedLongitude.base64,
      locationString: encryptedLocationString?.base64,
      city: encryptedCity?.base64,
      state: encryptedState?.base64,
    );
  }
}
