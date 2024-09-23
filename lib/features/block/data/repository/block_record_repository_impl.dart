import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/block/data/data_sources/block_record_data_source.dart';
import 'package:buoy/features/block/data/models/block_record.dart';
import 'package:buoy/features/block/domain/repository/block_repository.dart';
import 'package:buoy/features/block/domain/usecases/block_user_usecase.dart';
import 'package:buoy/features/block/domain/usecases/get_blocked_users_usecase.dart';
import 'package:buoy/features/block/domain/usecases/unblock_user_usecase.dart';
import 'package:buoy/features/block/entitities/block_record.dart';
import 'package:dartz/dartz.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BlockRecordRepositoryImpl extends BlockRecordRepository {
  final BlockRecordDataSource blockRecordDataSource;

  BlockRecordRepositoryImpl(
    this.blockRecordDataSource,
  ) : super();

  @override
  Future<Either<ServerFailure, List<BlockRecordEntity>>>
      getBlockedUsers() async {
    try {
      return await blockRecordDataSource.getBlockedUsers().then((value) {
        return Right(value);
      });
    } catch (e) {
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<ServerFailure, void>> unblockUser(String userId) async {
    try {
      return await (blockRecordDataSource.unblockUser(userId))
          .then((value) => Right(value));
    } catch (e) {
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<ServerFailure, BlockRecordEntity>> blockUser(
      String userId) async {
    try {
      return await blockRecordDataSource.blockUser(userId).then((value) {
        return Right(value);
      });
    } catch (e) {
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(ServerFailure(e.toString()));
    }
  }
}
