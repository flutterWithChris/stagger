import 'package:buoy/locate/model/public_key_entry.dart';
import 'package:supabase/supabase.dart';

import '../../shared/constants.dart';

class PublicKeyRepository {
  final SupabaseClient _supabase = supabase;

  // Future<String?> getPublicKey(String userId) async {
  //   try {
  //     final response = await _supabase
  //         .from('public_keys')
  //         .select('public_key')
  //         .eq('user_id', userId)
  //         .single();
  //     return response.data['public_key'] as String;
  //   } catch (e) {
  //     print('Error getting public key: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> storePublicKey(PublicKeyEntry publicKeyEntry) async {
  //   try {
  //     await _supabase.from('public_keys').upsert([
  //       publicKeyEntry.toMap(),
  //     ], onConflict: 'user_id');
  //   } catch (e) {
  //     print('Error storing public key: $e');
  //     rethrow;
  //   }
  // }
}
