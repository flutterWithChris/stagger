part of 'block_records_bloc.dart';

sealed class BlockRecordsState extends Equatable {
  final List<BlockRecordEntity>? blockRecords;
  const BlockRecordsState({this.blockRecords});

  @override
  List<Object?> get props => [blockRecords];
}

final class BlockRecordsInitial extends BlockRecordsState {}

final class BlockRecordsLoading extends BlockRecordsState {}

final class BlockRecordsLoaded extends BlockRecordsState {
  @override
  final List<BlockRecordEntity> blockRecords;

  const BlockRecordsLoaded(this.blockRecords);

  @override
  List<Object> get props => [blockRecords];
}

final class BlockRecordsError extends BlockRecordsState {
  final String message;

  const BlockRecordsError(this.message);

  @override
  List<Object> get props => [message];
}

final class BlockRecordsEmpty extends BlockRecordsState {}

final class BlockRecordsUpdated extends BlockRecordsState {
  @override
  final List<BlockRecordEntity> blockRecords;

  const BlockRecordsUpdated(this.blockRecords);

  @override
  List<Object> get props => [blockRecords];
}
