import 'package:buoy/shared/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LocationRealtimeRepository {
  final SupabaseClient _supabase = supabase;

  Future<void> sendLocationUpdate({
    required double latitude,
    required double longitude,
  }) async {
    // Delete the existing location data
    await supabase
        .from('location_updates')
        .delete()
        .eq('user_id', _supabase.auth.currentUser!.id);

    // TODO: Handle errors
    // if (deleteResponse.error != null) {
    //   print(
    //       'Error deleting old location data: ${deleteResponse.error!.message}');
    //   return;
    // }
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
