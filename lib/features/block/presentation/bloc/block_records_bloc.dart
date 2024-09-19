import 'package:bloc/bloc.dart';
import 'package:buoy/features/block/domain/repository/block_repository.dart';
import 'package:buoy/features/block/domain/usecases/block_user_usecase.dart';
import 'package:buoy/features/block/domain/usecases/get_blocked_users_usecase.dart';
import 'package:buoy/features/block/domain/usecases/unblock_user_usecase.dart';
import 'package:buoy/features/block/entitities/block_record.dart';
import 'package:equatable/equatable.dart';

part 'block_records_event.dart';
part 'block_records_state.dart';

class BlockRecordsBloc extends Bloc<BlockRecordsEvent, BlockRecordsState> {
  final GetBlockedUsersUsecase getBlockedUsersUsecase;
  final BlockUserUsecase blockUserUsecase;
  final UnblockUserUsecase unblockUserUsecase;

  BlockRecordsBloc({
    required this.getBlockedUsersUsecase,
    required this.blockUserUsecase,
    required this.unblockUserUsecase,
  }) : super(BlockRecordsInitial()) {
    on<FetchBlockRecords>(_onFetchBlockRecords);
    on<BlockUser>(_onBlockUser);
    on<UnblockUser>(_onUnblockUser);
  }

  void _onFetchBlockRecords(
    FetchBlockRecords event,
    Emitter<BlockRecordsState> emit,
  ) async {
    emit(BlockRecordsLoading());
    final result = await getBlockedUsersUsecase();
    result.fold(
      (failure) => emit(BlockRecordsError(failure.message)),
      (blockRecords) => emit(BlockRecordsLoaded(blockRecords)),
    );
  }

  void _onBlockUser(
    BlockUser event,
    Emitter<BlockRecordsState> emit,
  ) async {
    try {
      final result = await blockUserUsecase(event.userId);
      result.fold(
        (failure) {
          print(failure.message);
          emit(BlockRecordsError(failure.message));
        },
        (blockRecord) => emit(BlockRecordsUpdated([blockRecord])),
      );
    } catch (e) {
      print(e);
    }
  }

  void _onUnblockUser(
    UnblockUser event,
    Emitter<BlockRecordsState> emit,
  ) async {
    final result = await unblockUserUsecase(event.userId);
    result.fold(
      (failure) => emit(BlockRecordsError(failure.message)),
      (_) => emit(const BlockRecordsUpdated([])),
    );
  }
}
