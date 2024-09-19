import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/block/data/data_sources/block_record_data_source.dart';
import 'package:buoy/features/block/domain/usecases/get_blocked_users_usecase.dart';
import 'package:buoy/features/block/entitities/block_record.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:dartz/dartz.dart';

abstract class BlockRecordRepository {
  Future<Either<ServerFailure, BlockRecordEntity>> blockUser(String userId);
  Future<Either<ServerFailure, void>> unblockUser(String userId);
  Future<Either<ServerFailure, List<BlockRecordEntity>>> getBlockedUsers();
}
