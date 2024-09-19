import 'package:buoy/features/block/entitities/block_record.dart';

class BlockRecord extends BlockRecordEntity {
  const BlockRecord({
    super.id,
    super.userId,
    super.blockedUserId,
    super.createdAt,
    super.updatedAt,
  });

  BlockRecord copyWith({
    String? id,
    String? userId,
    String? blockedUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlockRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BlockRecord.fromMap(Map<String, dynamic> map) {
    return BlockRecord(
      id: map['id'],
      userId: map['user_id'],
      blockedUserId: map['blocked_user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'blocked_user_id': blockedUserId,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }

  @override
  String toString() {
    return 'BlockRecord(id: $id, userId: $userId, blockedUserId: $blockedUserId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
