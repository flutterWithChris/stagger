part of 'block_records_bloc.dart';

sealed class BlockRecordsEvent extends Equatable {
  const BlockRecordsEvent();

  @override
  List<Object> get props => [];
}

class FetchBlockRecords extends BlockRecordsEvent {}

class BlockUser extends BlockRecordsEvent {
  final String userId;

  const BlockUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class UnblockUser extends BlockRecordsEvent {
  final String userId;

  const UnblockUser(this.userId);

  @override
  List<Object> get props => [userId];
}
