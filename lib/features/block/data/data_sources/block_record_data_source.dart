import 'package:buoy/features/block/data/models/block_record.dart';
import 'package:buoy/features/block/entitities/block_record.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class BlockRecordDataSource {
  final blockTable = sb.Supabase.instance.client.from('blocks');
  Future<BlockRecord> blockUser(String userId) {
    try {
      return blockTable
          .upsert({
            'user_id': sb.Supabase.instance.client.auth.currentUser!.id,
            'blocked_user_id': userId,
          })
          .select()
          .then((value) {
            return BlockRecord.fromMap(value.first);
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      return await blockTable.delete().eq('blocked_user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BlockRecordEntity>> getBlockedUsers() async {
    try {
      final response = await blockTable.select();
      return response.map((e) => BlockRecord.fromMap(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}