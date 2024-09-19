import 'package:equatable/equatable.dart';

abstract class BlockRecordEntity extends Equatable {
  final String? id;
  final String? userId;
  final String? blockedUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const BlockRecordEntity({
    this.id,
    this.userId,
    this.blockedUserId,
    this.createdAt,
    this.updatedAt,
  });
  @override
  List<Object?> get props => [id, userId, blockedUserId, createdAt, updatedAt];
}
