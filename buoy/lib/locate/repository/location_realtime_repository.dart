import 'package:buoy/shared/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LocationRealtimeRepository {
  final SupabaseClient _supabase = supabase;

  Future<void> sendLocationUpdate({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _supabase.from('location_updates').insert([
      {
        'user_id': _supabase.auth.currentUser!.id,
        'latitude': '$latitude',
        'longitude': '$longitude',
        'timeStamp': DateTime.now().toIso8601String(),
      }
    ]);
  }
}
